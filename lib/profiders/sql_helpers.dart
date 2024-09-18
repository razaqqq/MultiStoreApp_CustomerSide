// ignore_for_file: avoid_print

import 'package:multi_store_app_customer/profiders/product_class.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class SQLHelper {
  /////////////////////////////////
  ///////// GET DATABSE //////////
  ///////////////////////////////
  static Database? _database;

  static get getDatabase async {
    if (_database != null) return _database;
    print("Creating Database");
    _database = await initDatabase();
    print("Dattabase Has Been Created");

    return _database;
  }

  //////////////////////////////////////////////
  //////////// INITIALIZE DATABASE ////////////
//////////////////////////////////////////////
//////////// CREATE & UPGRADE ///////////////

  static Future<Database> initDatabase() async {
    print('Init Database Function Called');
    String path = p.join(await getDatabasesPath(), 'multi_store_customer_database.db');
    return await openDatabase(path,
        version: 1, onCreate: _onCreate);
  }

  static Future _onCreate(Database db, int version) async {
    print('OnCreate FUnction Called');
    Batch batch = db.batch();
    batch.execute('''
CREATE TABLE cart_items (
  documentId TEXT PRIMARY KEY,
  productName TEXT,
  price DOUBLE,
  qty INTEGER,
  qntty INTEGER,
  imagesUrl TEXT,
  suppId TEXT
)
''');

    batch.execute('''
CREATE TABLE wish_items (
  documentId TEXT PRIMARY KEY,
  productName TEXT,
  price DOUBLE,
  qty INTEGER,
  qntty INTEGER,
  imagesUrl TEXT,
  suppId TEXT
)
''');


    batch.commit();

    print('Oncreate Was Called');


  }

  //////////////////////////////////////////////////////
  /////////////// INSERT DATA INTO DATABASE ///////////
//////////////////////////////////////////////////////
  static Future insertItem(Product product) async {
    Database db = await getDatabase;

    await db.insert(
      'cart_items',
      product.toMap(),
    );

    print(await db.query('cart_items'));
  }

  static Future insertTodo(Todo todo) async {
    Database db = await getDatabase;
    await db.insert('todos', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print(await db.query('todos'));
  }

  static Future insertNoteRaw() async {
    Database db = await getDatabase;
    await db.rawInsert('INSERT INTO notes(title, content) VALUES(?, ?)',
        ['another name', '12345678']);
    print(await db.rawQuery('SELECT * FROM notes'));
  }

  //////////////////////////////////////////////////////
  /////////////// RETREIVE DATA FROM DATABASE /////////
//////////////////////////////////////////////////////
  static Future<List<Map>> loadItems() async {
    Database db = await getDatabase;
    return await db.query('cart_items');
  }

  static Future<List<Map>> loadTodos() async {
    Database db = await getDatabase;
    List<Map> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        value: maps[i]['value'],
      ).toMap();
    });
  }

  //////////////////////////////////////////////////////
  /////////////// UPDATE DATA IN DATABASE /////////////
//////////////////////////////////////////////////////

  static Future updateCartItem(Product newProduct, String status) async {
    Database db = await getDatabase;
    await db.rawUpdate(
        'UPDATE cart_items SET qty = ? WHERE documentId = ?',
        [ status == 'increment' ? newProduct.qty + 1 : newProduct.qty - 1, newProduct.documentId]
    );
  }

  static Future updateNoteRaw(Note newNote) async {
    Database db = await getDatabase;
    await db.rawUpdate('UPDATE notes SET title = ?, content = ? WHERE id = ?',
        [newNote.title, newNote.content, newNote.id]);
  }

  static Future updateTodoChecked(int id, int currentValue) async {
    Database db = await getDatabase;
    await db.rawUpdate('UPDATE todos SET value = ? WHERE id = ?',
        [currentValue == 0 ? 1 : 0, id]);
  }

  //////////////////////////////////////////////////////
  //////////////// DELETE DATA FROM DATABASE //////////
  ////////////////////////////////////////////////////

  static Future deleteCartItem(String id) async {
    Database db = await getDatabase;
    await db.delete('cart_items', where: 'documentId = ?', whereArgs: [id]);
  }

  static Future deleteNoteRaw(int id) async {
    Database db = await getDatabase;
    await db.rawDelete('DELETE FROM notes WHERE id = ?', [id]);
  }

  static Future deleteAllCartItems() async {
    Database db = await getDatabase;
    await db.rawDelete('DELETE FROM cart_items');
  }

  static Future deleteAllTodos() async {
    Database db = await getDatabase;
    await db.rawDelete('DELETE FROM todos');
  }
}

/////////////////////////////////////////
/////////////// NOTE CLASS //////////////
/////////////////////////////////////////
class Note {
  final int id;
  final String title;
  final String content;
  String? description;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Note{id:$id , title: $title , content:$content , description:$description}';
  }
}
///////////////////////////////////////
////////////// TOdO CLASS /////////////
///////////////////////////////////////

class Todo {
  final int? id;
  final String title;
  int value;

  Todo({this.id, required this.title, this.value = 0});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'value': value,
    };
  }

  @override
  String toString() {
    return 'Note{id:$id , title: $title , value:$value }';
  }
}

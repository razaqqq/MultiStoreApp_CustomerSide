import 'package:flutter/foundation.dart';
import 'package:multi_store_app_customer/profiders/product_class.dart';
import 'package:multi_store_app_customer/profiders/sql_helpers.dart';

class Cart extends ChangeNotifier {
  static List<Product> _listProduct = [];

  List<Product> get getItems {
    return _listProduct;
  }

  double get totalPrice {
    var total = 0.0;

    for (var item in _listProduct) {
      total += item.price * item.qty;
    }

    return total;
  }

  int? get Count {
    return _listProduct.length;
  }

  void addItem(
    String productName,
    double price,
    int qty,
    int qntty,
    String imagesUrl,
    String documentId,
    String suppId,
  ) async {
    final product = Product(
        productName: productName,
        price: price,
        qty: qty,
        qntty: qntty,
        imagesUrl: imagesUrl,
        documentId: documentId,
        suppId: suppId);

    await SQLHelper.insertItem(product).whenComplete(() {
      _listProduct.add(product);
    });

    notifyListeners();
  }

  loadCartItemProvider() async {
    List<Map> data = await SQLHelper.loadItems();
    _listProduct = data.map((product) {
      return Product(
          documentId: product['documentId'],
          productName: product['productName'],
          price: product['price'],
          qty: product['qty'],
          qntty: product['qntty'],
          imagesUrl: product['imagesUrl'],
          suppId: product['suppId']);
    }).toList();
    notifyListeners();
  }

  void increment(Product product) async {
    print("Cart Provider Increment is Called");

    await SQLHelper.updateCartItem(product, 'increment').whenComplete(() {
      product.increase();
    });

    notifyListeners();
  }

  void decrease(Product product) async {
    print("Cart Provide Decrement is Called");

    await SQLHelper.updateCartItem(product, 'decrement').whenComplete(() {
      product.decrease();
    });

    notifyListeners();
  }

  void removeItem(Product product) async {
    await SQLHelper.deleteCartItem(product.documentId).whenComplete(() {
      _listProduct.remove(product);
    });

    notifyListeners();
  }

  void clearCart() async {
    await SQLHelper.deleteAllCartItems().whenComplete(() {
      _listProduct.clear();
    });

    notifyListeners();
  }
}

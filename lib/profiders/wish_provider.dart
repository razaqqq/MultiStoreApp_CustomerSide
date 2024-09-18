
import 'package:flutter/foundation.dart';
import 'package:multi_store_app_customer/profiders/product_class.dart';


class Wish extends ChangeNotifier {
  final List<Product> _listProduct = [];

  List<Product> get getWishItems {
    return _listProduct;

  }


  int? get Count {
    return _listProduct.length;


  }

  Future<void> addWishItem(
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
    _listProduct.add(product);
    notifyListeners();
  }

  void removeItem(Product product) {
    _listProduct.remove(product);
    notifyListeners();
  }

  void clearWishList() {
    _listProduct.clear();
    notifyListeners();
  }

  void removeThis(String productId) {
    _listProduct.removeWhere((element) => element.documentId == productId);
    notifyListeners();
  }


}

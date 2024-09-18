



class Product {
  String documentId;
  String productName;
  double price;
  int qty = 1;
  int qntty;
  String imagesUrl;

  String suppId;

  Product(
      {
        required this.documentId,
        required this.productName,
        required this.price,
        required this.qty,
        required this.qntty,
        required this.imagesUrl,

        required this.suppId});

  void increase() {
    qty++;
  }

  void decrease() {
    qty--;
  }

  Map<String, dynamic> toMap() {
    return {
      'documentId' : documentId,
      'productName' : productName,
      'price' : price,
      'qty' : qty,
      'qntty' : qntty,
      'images_url' : imagesUrl,
      'supp_id' : suppId


    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Product{product_name: $productName, price: $price, qty: $qty, qntty: $qntty, images_url: $imagesUrl, supp_id: $suppId }';
  }

}
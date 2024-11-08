class Product {
  final String name; // Nome do produto
  final double price; // Preço do produto
  int quantity; // Quantidade disponível
  int sold; // Quantidade vendida

  // Construtor da classe Product
  Product({
    required this.name,
    required this.price,
    required this.quantity,
    this.sold = 0, // Inicializa a quantidade vendida como 0
  });

  // Converte um Product para Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'sold': sold,
    };
  }

  // Converte um Map para Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
      sold: map['sold'],
    );
  }

  @override
  String toString() {
    return 'Produto: $name, Preço: $price, Quantidade: $quantity, Vendido: $sold';
  }
}

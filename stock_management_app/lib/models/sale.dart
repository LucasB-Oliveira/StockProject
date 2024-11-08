class Sale {
  final int? id; // ID da venda, pode ser nulo durante a inserção
  final String productName; // Nome do produto vendido
  final int quantity; // Quantidade vendida
  final double total; // Total da venda
  final DateTime date; // Data da venda

  Sale({
    this.id,
    required this.productName,
    required this.quantity,
    required this.total,
    required this.date,
  });

  // Converte uma Sale para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Inclui o id no Map
      'productName': productName,
      'quantity': quantity,
      'total': total,
      'date': date.toIso8601String(), // Converte a data para String
    };
  }

  // Converte um Map para Sale
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'], // Lê o id do Map
      productName: map['productName'],
      quantity: map['quantity'],
      total: map['total'],
      date: DateTime.parse(map['date']), // Converte a String de volta para DateTime
    );
  }
}

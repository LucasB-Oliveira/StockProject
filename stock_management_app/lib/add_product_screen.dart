import 'package:flutter/material.dart';
import 'package:logging/logging.dart'; // Importa o pacote de logging
import '../models/product.dart'; // Certifique-se de que o caminho para o model esteja correto

class AddProductScreen extends StatefulWidget {
  final Function(Product) onAddProduct;

  const AddProductScreen({super.key, required this.onAddProduct});

  @override
  AddProductScreenState createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final Logger _logger = Logger('AddProductScreenState'); // Logger para esta classe

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do Produto'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Preço'),
            ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final price = double.tryParse(_priceController.text) ?? 0;
                final quantity = int.tryParse(_quantityController.text) ?? 0;

                if (name.isNotEmpty && price > 0 && quantity > 0) {
                  final product = Product(name: name, price: price, quantity: quantity);
                  widget.onAddProduct(product);
                  _logger.info('Produto adicionado: $product'); // Usa o logger em vez de print
                  Navigator.of(context).pop();
                } else {
                  // Exibir um alerta se os dados forem inválidos
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Erro'),
                      content: const Text('Por favor, preencha todos os campos corretamente.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Adicionar Produto'),
            ),
          ],
        ),
      ),
    );
  }
}

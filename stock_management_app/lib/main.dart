import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'add_product_screen.dart';
import 'models/product.dart';
import 'splash_screen.dart';
import 'database_helper.dart';
import 'models/sale.dart'; // Importe o modelo Sale

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Gerenciamento de Estoque',
      home: SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<Product> _products = [];
  final Map<DateTime, Map<String, Map<String, double>>> _salesHistory = {};
  final Logger _logger = Logger('HomePageState');
  final DateTime _selectedDay = DateTime.now();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData(); // Carrega dados ao iniciar
  }

  Future<void> _loadData() async {
    // Carrega produtos
    final products = await DatabaseHelper.instance.getProducts();
    setState(() {
      _products.addAll(products);
    });

    // Carrega histórico de vendas
    final sales = await DatabaseHelper.instance.getSalesHistory();
    setState(() {
      for (var sale in sales) {
        final date = sale.date;
        final productName = sale.productName;

        if (_salesHistory[date] == null) {
          _salesHistory[date] = {};
        }

        if (_salesHistory[date]!.containsKey(productName)) {
          _salesHistory[date]![productName]!['quantity'] =
              (_salesHistory[date]![productName]!['quantity'] ?? 0) + sale.quantity;
          _salesHistory[date]![productName]!['total'] =
              (_salesHistory[date]![productName]!['total'] ?? 0) + sale.total;
        } else {
          _salesHistory[date]![productName] = {
            'quantity': sale.quantity.toDouble(),
            'total': sale.total,
          };
        }
      }
    });
  }

  Future<void> _addProduct(Product product) async {
    await DatabaseHelper.instance.insertProduct(product);
    setState(() {
      _products.add(product);
    });
    _logger.info('Produto adicionado: $product');
  }

  Future<void> _sellProduct(Product product) async {
    setState(() {
      if (product.quantity > 0) {
        product.quantity--;
        product.sold++;
        _logger.info('Produto vendido: $product');

        // Registra a venda
        if (_salesHistory[_selectedDay] == null) {
          _salesHistory[_selectedDay] = {};
        }

        if (_salesHistory[_selectedDay]!.containsKey(product.name)) {
          _salesHistory[_selectedDay]![product.name]!['quantity'] =
              (_salesHistory[_selectedDay]![product.name]!['quantity'] ?? 0) + 1;
          _salesHistory[_selectedDay]![product.name]!['total'] =
              (_salesHistory[_selectedDay]![product.name]!['total'] ?? 0) + product.price;
        } else {
          _salesHistory[_selectedDay]![product.name] = {
            'quantity': 1,
            'total': product.price,
          };
        }

        // Salva a venda no banco de dados
        DatabaseHelper.instance.insertSale(Sale(
          productName: product.name,
          quantity: 1,
          total: product.price,
          date: _selectedDay,
        ));

        // Atualiza contagens de vendas
        _updateSalesCounts();

        if (product.quantity == 0) {
          _products.remove(product);
          _logger.info('Produto removido: ${product.name} (Estoque zerado)');
          DatabaseHelper.instance.deleteProduct(product.name);
        } else {
          DatabaseHelper.instance.updateProduct(product);
        }
      } else {
        _showAlert('Estoque insuficiente para venda.');
      }
    });
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
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

  void _updateSalesCounts() {
    // Atualize seus totais de vendas como desejado
  }

  void _showSalesScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SalesScreen(
          salesHistory: _salesHistory,
          onClearHistory: _clearSalesHistory,
          onGoBack: _goBackToHome,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _showSalesScreen();
    } else if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddProductScreen(onAddProduct: _addProduct),
        ),
      );
    }
  }

  void _clearSalesHistory() {
    setState(() {
      _salesHistory.clear();
      _logger.info('Histórico de vendas limpo.');
    });
    DatabaseHelper.instance.clearSalesHistory(); // Limpa o histórico do banco de dados
  }

  void _goBackToHome() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Estoque'),
      ),
      body: _products.isEmpty
          ? const Center(child: Text('Nenhum produto cadastrado.'))
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Preço: \$${product.price}, Quantidade: ${product.quantity}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.sell),
                    onPressed: () {
                      _sellProduct(product);
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Vendas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Adicionar Produto',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Tela de histórico de vendas
class SalesScreen extends StatelessWidget {
  final Map<DateTime, Map<String, Map<String, double>>> salesHistory;
  final Function onClearHistory;
  final Function onGoBack;

  const SalesScreen({
    super.key,
    required this.salesHistory,
    required this.onClearHistory,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Vendas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Limpar Histórico'),
                  content: const Text('Você tem certeza de que deseja limpar o histórico de vendas?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        onClearHistory();
                        onGoBack();
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Limpar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: salesHistory.length,
        itemBuilder: (context, index) {
          DateTime date = salesHistory.keys.elementAt(index);
          Map<String, Map<String, double>> products = salesHistory[date] ?? {};
          double totalDaySales = 0;

          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text('Vendas em ${date.day}/${date.month}/${date.year}'),
              subtitle: const Text('Clique para ver os itens vendidos.'),
              children: products.entries.map((entry) {
                String productName = entry.key;
                double quantitySold = entry.value['quantity'] ?? 0;
                double totalPrice = entry.value['total'] ?? 0;
                totalDaySales += totalPrice;

                return ListTile(
                  title: Text('$productName - Quantidade: $quantitySold'),
                  subtitle: Text('Total: \$${totalPrice.toStringAsFixed(2)}'),
                );
              }).toList()..add(
                ListTile(
                  title: const Text('Total do Dia:'),
                  subtitle: Text('\$${totalDaySales.toStringAsFixed(2)}'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

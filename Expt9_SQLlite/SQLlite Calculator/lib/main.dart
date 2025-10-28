import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Calculator (SQLite)",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = "";
  String _result = "0";
  final dbHelper = DBHelper();

  final List<String> _buttons = [
    "C",
    "⌫",
    "÷",
    "×",
    "7",
    "8",
    "9",
    "-",
    "4",
    "5",
    "6",
    "+",
    "1",
    "2",
    "3",
    "=",
    "0",
    ".",
    "(",
    ")",
    "H",
  ];

  void _onButtonPressed(String value) async {
    if (value == "C") {
      setState(() {
        _expression = "";
        _result = "0";
      });
    } else if (value == "⌫") {
      setState(() {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      });
    } else if (value == "=") {
      await _evaluate();
    } else if (value == "H") {
      await _showHistory();
    } else {
      setState(() {
        _expression += value;
      });
    }
  }

  Future<void> _evaluate() async {
    if (_expression.isEmpty) {
      setState(() => _result = "0");
      return;
    }

    try {
      // Clean up expression
      String exp = _expression
          .replaceAll("×", "*")
          .replaceAll("÷", "/")
          .replaceAll(" ", "");

      Parser parser = Parser();
      Expression expression = parser.parse(exp);
      ContextModel cm = ContextModel();
      double eval = expression.evaluate(EvaluationType.REAL, cm);

      setState(() {
        _result = eval.toString();
      });

      // Save to SQLite
      await dbHelper.insertCalculation(_expression, _result);
    } catch (e) {
      setState(() {
        _result = "Error";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Expression! Check your input."),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint("Evaluation error: $e");
    }
  }

  Future<void> _showHistory() async {
    final history = await dbHelper.fetchHistory();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12),
          height: 220,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "History",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await dbHelper.clearHistory();
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: history.isEmpty
                    ? const Center(child: Text("No history yet"))
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          return ListTile(
                            title: Text(item['expression']),
                            subtitle: Text("= ${item['result']}"),
                            trailing: const Icon(
                              Icons.history,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    dbHelper.closeDB();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Calculator (SQLite)"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // Display area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(2),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _expression,
                      style: const TextStyle(fontSize: 28, color: Colors.grey),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _result,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 310),
                child: GridView.builder(
                  padding: const EdgeInsets.all(4), // Reduced from 8 to 4
                  itemCount: _buttons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    mainAxisSpacing: 4, // Add spacing between rows
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final btnText = _buttons[index];
                    return CalcButton(
                      text: btnText,
                      color: _getButtonColor(btnText),
                      onTap: () => _onButtonPressed(btnText),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getButtonColor(String text) {
    if (text == "C") return Colors.red;
    if (text == "=") return Colors.green;
    if (text == "H") return Colors.purple;
    if (["÷", "×", "-", "+", "⌫"].contains(text)) return Colors.orange;
    return Colors.indigo;
  }
}

class CalcButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const CalcButton({
    super.key,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
    );
  }
}

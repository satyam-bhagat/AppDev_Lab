import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Calculator",
      debugShowCheckedModeBanner: false,
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

  final List<String> _buttons = [
    "C", "⌫", "÷", "×",
    "7", "8", "9", "-",
    "4", "5", "6", "+",
    "1", "2", "3", "=",
    "0", ".", "(", ")",
  ];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _expression = "";
        _result = "0";
      } else if (value == "⌫") {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == "=") {
        _evaluate();
      } else {
        _expression += value;
      }
    });
  }

  void _evaluate() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(
        _expression.replaceAll("×", "*").replaceAll("÷", "/"),
      );
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      _result = eval.toString();
    } catch (e) {
      _result = "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Calculator"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Display area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.grey,
                      ),
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

          // Buttons grid
          Expanded(
            flex: 5,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400, // 👈 Limit calculator width
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _buttons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // always 4 columns
                    childAspectRatio: 1,
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
          )

        ],
      ),
    );
  }

  Color _getButtonColor(String text) {
    if (text == "C") return Colors.red;
    if (text == "=") return Colors.green;
    if (["÷", "×", "-", "+", "⌫"].contains(text)) return Colors.orange;
    return Colors.blue;
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
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
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

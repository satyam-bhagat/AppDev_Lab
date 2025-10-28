import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:math_expressions/math_expressions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Proper Firebase initialization for all platforms
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA1tkyxHVluksWoHwAsOKRcbcu2dhnMBII",
        authDomain: "calculator-b9b75.firebaseapp.com",
        projectId: "calculator-b9b75",
        storageBucket: "calculator-b9b75.firebasestorage.app",
        messagingSenderId: "493704530227",
        appId: "1:493704530227:web:29b2e8a72376ce93f65646",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  ];

  // ✅ Save each calculation to Firestore (optimized for speed)
  Future<void> _saveCalculation(String expression, String result) async {
    try {
      // Use batch write for better performance
      final batch = _firestore.batch();
      final docRef = _firestore.collection("calculations").doc();

      batch.set(docRef, {
        "expression": expression,
        "result": result,
        "timestamp": FieldValue.serverTimestamp(),
      });

      await batch.commit();
      debugPrint("✅ Calculation saved to Firestore");
    } catch (e) {
      debugPrint("❌ Error saving calculation: $e");
    }
  }

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
      // Use GrammarParser instead of deprecated Parser
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(
        _expression.replaceAll("×", "*").replaceAll("÷", "/"),
      );
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      _result = eval.toString();

      // ✅ Save to Firestore after every successful calculation (async, non-blocking)
      _saveCalculation(_expression, _result);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
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
          ),
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

// 🔹 History Screen — shows saved calculations
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Calculation History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection("calculations")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No calculations yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final expr = data["expression"] ?? "";
              final res = data["result"] ?? "";
              final time = data["timestamp"]?.toDate()?.toString() ?? "";

              return ListTile(
                title: Text(expr),
                subtitle: Text("= $res"),
                trailing: Text(
                  time.split(".").first,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 🔹 Calculator Button Widget
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

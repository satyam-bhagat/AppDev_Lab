import 'package:flutter/material.dart';
import 'page2.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();

  String gender = "Male"; // default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Step 1: Personal Information")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: "Enter your first name"),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: "Enter your last name"),
            ),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter your age"),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Select Gender:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                Radio(
                  value: "Male",
                  groupValue: gender,
                  onChanged: (val) => setState(() => gender = val.toString()),
                ),
                const Text("Male"),
                Radio(
                  value: "Female",
                  groupValue: gender,
                  onChanged: (val) => setState(() => gender = val.toString()),
                ),
                const Text("Female"),
                Radio(
                  value: "Other",
                  groupValue: gender,
                  onChanged: (val) => setState(() => gender = val.toString()),
                ),
                const Text("Other"),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Page2(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      age: ageController.text,
                    ),
                  ),
                );
              },
              child: const Text("Next"),
            )
          ],
        ),
      ),
    );
  }
}

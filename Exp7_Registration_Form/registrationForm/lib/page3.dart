import 'package:flutter/material.dart';

class Page3 extends StatefulWidget {
  final String firstName, lastName, age, email, phone, password;
  const Page3({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final companyController = TextEditingController();
  final jobTitleController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipController = TextEditingController();

  String department = "Engineering";
  String experience = "Fresher";
  String country = "India";

  final departments = ["Engineering", "HR", "Finance", "Sales"];
  final experiences = ["Fresher", "1-3 years", "3-5 years", "5+ years"];
  final countries = ["India", "USA", "UK", "Germany", "Canada"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Step 3: Employment & Address")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: companyController,
              decoration: const InputDecoration(labelText: "Enter your company name"),
            ),
            TextField(
              controller: jobTitleController,
              decoration: const InputDecoration(labelText: "Enter your job title"),
            ),
            DropdownButtonFormField(
              value: department,
              items: departments.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => department = val.toString()),
              decoration: const InputDecoration(labelText: "Select your department"),
            ),
            DropdownButtonFormField(
              value: experience,
              items: experiences.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => experience = val.toString()),
              decoration: const InputDecoration(labelText: "Select experience level"),
            ),
            const Divider(),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Enter your full address"),
            ),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: "Enter city"),
            ),
            TextField(
              controller: stateController,
              decoration: const InputDecoration(labelText: "Enter state"),
            ),
            TextField(
              controller: zipController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter ZIP code"),
            ),
            DropdownButtonFormField(
              value: country,
              items: countries.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => country = val.toString()),
              decoration: const InputDecoration(labelText: "Select country"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Account Created"),
                    content: Text(
                      "Welcome ${widget.firstName} ${widget.lastName}!\n\n"
                          "Email: ${widget.email}\nPhone: ${widget.phone}\n"
                          "Company: ${companyController.text}\nDepartment: $department\n"
                          "City: ${cityController.text}, $country",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      )
                    ],
                  ),
                );
              },
              child: const Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}

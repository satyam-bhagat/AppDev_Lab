import 'package:catalog_app/core/store.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  String _paymentMethod = 'card';

  @override
  void dispose() {
    _fullNameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = VxState.store as MyStore;
    final items = store.cart.items;
    final subtotal = store.cart.totalPrice.toDouble();
    final shipping = items.isEmpty ? 0.0 : 10.0;
    final total = subtotal + shipping;

    final isWide = MediaQuery.of(context).size.width >= 900;

    final shippingForm = Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              "Shipping Address".text.xl2.bold.make(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address1Controller,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address2Controller,
                decoration: const InputDecoration(
                  labelText: 'Street Address 2',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_work_outlined),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _zipController,
                      decoration: const InputDecoration(
                        labelText: 'ZIP Code',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              "Payment Method".text.xl.semiBold.make(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'card',
                      groupValue: _paymentMethod,
                      title: const Text('Credit/Debit Card'),
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'paypal',
                      groupValue: _paymentMethod,
                      title: const Text('PayPal'),
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final summary = Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            "Order Summary".text.xl2.bold.make(),
            const SizedBox(height: 16),
            ...items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(i.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text("\$${i.price.toStringAsFixed(2)}"),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              children: [
                const Expanded(child: Text('Shipping')),
                Text("\$${shipping.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                    child: Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Text("\$${total.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: items.isEmpty
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Payment flow not integrated.')),
                      );
                    },
              child: const Text('Pay Now'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel Order'),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: shippingForm),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: summary),
                ],
              )
            : ListView(
                children: [
                  shippingForm,
                  const SizedBox(height: 16),
                  summary,
                ],
              ),
      ),
    );
  }
}

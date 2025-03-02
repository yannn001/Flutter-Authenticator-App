import 'package:flutter/material.dart';

class ManualAddScreen extends StatelessWidget {
  const ManualAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountController = TextEditingController();
    final issuerController = TextEditingController();
    final secretController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Account Name'),
            _buildTextField(accountController, 'e.g., myemail@example.com'),
            const SizedBox(height: 16),
            _buildLabel('Issuer'),
            _buildTextField(issuerController, 'e.g., Google, Facebook'),
            const SizedBox(height: 16),
            _buildLabel('Secret Key'),
            _buildTextField(
              secretController,
              'Paste your secret key here',
              isSecret: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'account': accountController.text.trim(),
                    'issuer': issuerController.text.trim(),
                    'secret': secretController.text.trim(),
                  });
                },
                child: const Text(
                  'Save Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isSecret = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: isSecret,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

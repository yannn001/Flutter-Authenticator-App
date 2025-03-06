import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_authenticator/screens/manual_add_screen.dart';
import 'package:flutter_authenticator/screens/qr_scanner_screen.dart';
import 'package:flutter_authenticator/utils/storage_utils.dart';
import 'package:flutter_authenticator/widgets/otp_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String> accounts = {};
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadAccounts();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  Future<void> loadAccounts() async {
    accounts = await getAccounts();
    setState(() {});
  }

  Future<bool> showDeleteConfirmationDialog(
    BuildContext context,
    String issuer,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text(
                  'Delete Account',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'Are you sure you want to delete the account "$issuer"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        actionsPadding: const EdgeInsets.only(right: 12),
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontFamily: 'Arial'),
            children: [
              TextSpan(
                text: '2F',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'Authenticator',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          FloatingActionButton(
            onPressed: () => showAddAccountOptions(context),
            mini: true,
            backgroundColor: Colors.grey[900],
            child: const Icon(Icons.add),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 15, 15, 15),
      body:
          accounts.isEmpty
              ? _buildEmptyState()
              : ListView(
                children:
                    accounts.entries.map((entry) {
                      final account = entry.key;
                      final data = entry.value.split('::');
                      final issuer = data[0];
                      final secret = data[1];

                      return OtpTile(
                        account: account,
                        issuer: issuer,
                        secret: secret,
                        confirmDelete: () async {
                          return await showDeleteConfirmationDialog(
                            context,
                            issuer,
                          );
                        },
                        onDelete: () async {
                          setState(() {
                            accounts.remove(account);
                          });
                          try {
                            await deleteAccount(account);
                          } catch (error) {
                            if (kDebugMode) {
                              print("Failed to delete account: $error");
                            }
                            loadAccounts();
                          }
                        },
                      );
                    }).toList(),
              ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 80, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'No accounts added yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white60,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add your first account',
            style: TextStyle(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  void showAddAccountOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildOption(
                  context,
                  icon: Icons.qr_code_scanner,
                  label: 'Scan QR Code',
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QRScannerScreen(),
                      ),
                    );
                    if (result != null) {
                      await saveAccount(
                        result['account'],
                        result['secret'],
                        result['issuer'],
                      );
                      loadAccounts();
                    }
                  },
                ),
                const SizedBox(height: 8),
                _buildOption(
                  context,
                  icon: Icons.keyboard,
                  label: 'Add Manually',
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManualAddScreen(),
                      ),
                    );
                    if (result != null) {
                      await saveAccount(
                        result['account'],
                        result['secret'],
                        result['issuer'],
                      );
                      loadAccounts();
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

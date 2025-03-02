import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => controller.switchCamera(),
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_hasScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes[0].rawValue != null) {
                final String rawValue = barcodes[0].rawValue!;
                _processQrCode(rawValue);
              }
            },
          ),
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Align QR code within the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processQrCode(String code) {
    try {
      setState(() {
        _hasScanned = true;
      });

      Uri uri = Uri.parse(code);

      if (uri.scheme == 'otpauth') {
        final path =
            uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;

        final List<String> parts =
            path.contains(':') ? path.split(':') : [path];

        String issuer = '';
        String account = '';

        if (parts.length > 1) {
          issuer = parts[0];
          account = parts[1];
        } else {
          account = parts[0];
        }

        if (uri.queryParameters.containsKey('issuer')) {
          issuer = uri.queryParameters['issuer']!;
        }

        final secret = uri.queryParameters['secret'] ?? '';

        // Debug logging
        if (kDebugMode) {
          print('Parsed URI: ${uri.toString()}');
          print('Issuer: $issuer');
          print('Account: $account');
          print('Secret: $secret');
        }

        if (secret.isEmpty) {
          showError('Invalid QR code: missing secret parameter');
          return;
        }

        final result = {'account': account, 'issuer': issuer, 'secret': secret};
        Navigator.pop(context, result);
      } else {
        showError('Invalid QR code format. Expected otpauth URL.');
      }
    } catch (e) {
      showError('Error processing QR code: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _hasScanned = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

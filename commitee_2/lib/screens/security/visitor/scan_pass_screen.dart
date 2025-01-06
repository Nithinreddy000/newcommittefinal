import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../providers/visitor_pass_provider.dart';
import '../../../models/visitor_pass.dart';

class ScanPassScreen extends StatefulWidget {
  const ScanPassScreen({super.key});

  @override
  State<ScanPassScreen> createState() => _ScanPassScreenState();
}

class _ScanPassScreenState extends State<ScanPassScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Visitor Pass'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final List<Barcode> barcodes = capture.barcodes;
      for (final barcode in barcodes) {
        final data = jsonDecode(barcode.rawValue ?? '');
        final pass = VisitorPass.fromQRData(data);
        
        final isValid = await context.read<VisitorPassProvider>().verifyPass(pass.id);
        
        if (mounted) {
          if (isValid) {
            _showSuccessDialog(pass);
          } else {
            _showErrorDialog('Invalid or expired pass');
          }
        }
        break;
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Invalid QR code');
      }
    }

    setState(() => _isProcessing = false);
  }

  void _showSuccessDialog(VisitorPass pass) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Valid Pass'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visitor: ${pass.visitorName}'),
            Text('Flat: ${pass.flatNumber}'),
            Text('Purpose: ${pass.purpose}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
} 
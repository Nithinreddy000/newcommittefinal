import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../providers/visitor_provider.dart';
import '../../../models/visitor.dart';
import '../../../services/auth_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Visitor QR'),
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
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => controller.switchCamera(),
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
    
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      try {
        final data = Uri.decodeFull(barcode.rawValue ?? '');
        _handleScan(data);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visitor entry recorded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid QR code'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    
    setState(() => _isProcessing = false);
  }

  void _handleScan(String data) {
    final visitor = Visitor(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Scanned Visitor',
      purpose: 'QR Entry',
      flatNumber: data,
      entryTime: DateTime.now(),
      contactNumber: '',
      approvedBy: 'Security',
    );
    
    context.read<VisitorProvider>().addVisitor(visitor);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
} 
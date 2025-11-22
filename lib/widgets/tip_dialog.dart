import 'package:flutter/material.dart';
import '../services/tip_service.dart';

class TipDialog extends StatelessWidget {
  final Tip tip;
  final VoidCallback onClose;

  const TipDialog({
    super.key,
    required this.tip,
    required this.onClose,
  });

  static Future<void> showTipIfAvailable(BuildContext context) async {
    final tipService = TipService();
    final tip = await tipService.getNextUnseenTip();
    
    if (tip != null && context.mounted) {
      _showTipDialog(context, tip, tipService);
    }
  }

  static void _showTipDialog(BuildContext context, Tip tip, TipService tipService) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => TipDialog(
        tip: tip,
        onClose: () async {
          await tipService.markTipAsSeen(tip.id);
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon und Titel
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange[700],
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Wusstest du schon, dass...?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Tip-Text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Text(
                tip.text,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Verstanden',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

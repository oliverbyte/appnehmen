import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/storage_service.dart';
import '../screens/help_screen.dart';

class InstallBanner extends StatefulWidget {
  const InstallBanner({super.key});

  @override
  State<InstallBanner> createState() => _InstallBannerState();
}

class _InstallBannerState extends State<InstallBanner> {
  final _storageService = StorageService();
  bool _isDismissed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBannerStatus();
  }

  Future<void> _checkBannerStatus() async {
    final hasSeenPrompt = await _storageService.hasSeenInstallPrompt();
    setState(() {
      _isDismissed = hasSeenPrompt;
      _isLoading = false;
    });
  }

  Future<void> _dismissBanner() async {
    await _storageService.setInstallPromptSeen();
    setState(() {
      _isDismissed = true;
    });
  }

  void _openHelpScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HelpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Don't show on non-web platforms or if dismissed or still loading
    if (!kIsWeb || _isDismissed || _isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openHelpScreen,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'App installieren? Hier erfährst du wie!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _dismissBanner,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

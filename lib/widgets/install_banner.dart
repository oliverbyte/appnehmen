// Appnehmen - Weight Loss Tracking PWA
// Copyright (c) 2025 Oliver Byte
// Licensed under the MIT License - see LICENSE file for details

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/storage_service.dart';

class InstallBanner extends StatefulWidget {
  const InstallBanner({super.key});

  @override
  State<InstallBanner> createState() => _InstallBannerState();
}

class _InstallBannerState extends State<InstallBanner> {
  final _storageService = StorageService();
  bool _isDismissed = false;
  bool _isExpanded = false;
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

  @override
  Widget build(BuildContext context) {
    // Don't show on non-web platforms or if dismissed or still loading
    if (!kIsWeb || _isDismissed || _isLoading) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact header (always visible)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'App installieren für bessere Erfahrung',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
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
          
          // Expanded content
          if (_isExpanded)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Benefits
                  _buildBenefit(Icons.cloud_off, 'Offline verfügbar'),
                  const SizedBox(height: 8),
                  _buildBenefit(Icons.speed, 'Schneller Zugriff'),
                  const SizedBox(height: 8),
                  _buildBenefit(Icons.phone_iphone, 'Wie eine native App'),
                  const SizedBox(height: 16),
                  
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  // Instructions
                  Text(
                    'So installierst du:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInstruction('iOS', 'Teilen → "Zum Home-Bildschirm"'),
                  const SizedBox(height: 4),
                  _buildInstruction('Android', 'Menü (⋮) → "App installieren"'),
                  const SizedBox(height: 4),
                  _buildInstruction('Desktop', 'Klick auf ⊕ in der Adresszeile'),
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _dismissBanner,
                        child: Text(
                          'Nicht mehr anzeigen',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _dismissBanner,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                        ),
                        child: const Text('Verstanden'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.green.shade700),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildInstruction(String platform, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$platform: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

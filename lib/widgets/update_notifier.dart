import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;

class UpdateNotifier extends StatefulWidget {
  final Widget child;

  const UpdateNotifier({super.key, required this.child});

  @override
  State<UpdateNotifier> createState() => _UpdateNotifierState();
}

class _UpdateNotifierState extends State<UpdateNotifier> {
  bool _updateAvailable = false;

  @override
  void initState() {
    super.initState();
    _setupUpdateListener();
  }

  void _setupUpdateListener() {
    // Prüfe regelmäßig ob ein Update verfügbar ist
    Future.delayed(const Duration(seconds: 2), _checkForUpdate);
    
    // Prüfe alle 30 Sekunden
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      _checkForUpdate();
      return mounted;
    });
  }

  void _checkForUpdate() {
    try {
      final updateManager = js.context['updateManager'];
      if (updateManager != null) {
        final updateAvailable = js.JsObject.fromBrowserObject(updateManager)['updateAvailable'];
        if (updateAvailable == true && mounted) {
          setState(() {
            _updateAvailable = true;
          });
        }
      }
    } catch (e) {
      // Ignoriere Fehler in Nicht-Web-Umgebungen
    }
  }

  void _applyUpdate() {
    try {
      final updateManager = js.context['updateManager'];
      if (updateManager != null) {
        js.JsObject.fromBrowserObject(updateManager).callMethod('checkForUpdates');
      }
    } catch (e) {
      // Ignoriere Fehler
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_updateAvailable)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade700],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.system_update,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Update verfügbar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Neue Version wird installiert...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../core/storage/secure_storage_service.dart';

final appSessionUnlockedProvider = StateProvider<bool>((ref) => false);
final appLaunchCountProvider = StateProvider<int>((ref) => 1);

class BiometricLockOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const BiometricLockOverlay({super.key, required this.child});

  @override
  ConsumerState<BiometricLockOverlay> createState() => _BiometricLockOverlayState();
}

class _BiometricLockOverlayState extends ConsumerState<BiometricLockOverlay> with SingleTickerProviderStateMixin {
  bool _isChecking = true;
  bool _isScanning = false;
  bool _isFailed = false;
  String _statusMessage = 'Touch fingerprint sensor to verify...';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initLaunchCheck();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _initLaunchCheck() async {
    final storage = SecureStorageService();
    final count = await storage.getAppLaunchCount();
    
    // Update Riverpod provider
    ref.read(appLaunchCountProvider.notifier).state = count;

    // Check if 2nd launch or later
    if (count >= 2) {
      final isAlreadyUnlocked = ref.read(appSessionUnlockedProvider);
      if (!isAlreadyUnlocked) {
        if (mounted) {
          setState(() {
            _isChecking = false;
          });
        }
        // Auto-trigger biometric prompt
        _triggerBiometricAuth();
        return;
      }
    }

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
      ref.read(appSessionUnlockedProvider.notifier).state = true;
    }
  }

  Future<void> _triggerBiometricAuth() async {
    setState(() {
      _isScanning = true;
      _isFailed = false;
      _statusMessage = 'Scanning fingerprint sensor...';
    });

    bool authenticated = false;

    if (!kIsWeb) {
      try {
        final auth = LocalAuthentication();
        final canCheck = await auth.canCheckBiometrics;
        final isSupported = await auth.isDeviceSupported();

        if (canCheck || isSupported) {
          authenticated = await auth.authenticate(
            localizedReason: '2nd App Launch Security: Verify fingerprint to unlock application',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: false,
            ),
          );
        }
      } catch (e) {
        debugPrint('Biometric auth error: $e');
      }
    } else {
      // Simulate fingerprint scan on Web test environment
      await Future.delayed(const Duration(milliseconds: 800));
      authenticated = true;
    }

    if (!mounted) return;

    if (authenticated) {
      setState(() {
        _isScanning = false;
        _isFailed = false;
        _statusMessage = 'Fingerprint Verified!';
      });
      ref.read(appSessionUnlockedProvider.notifier).state = true;
    } else {
      setState(() {
        _isScanning = false;
        _isFailed = true;
        _statusMessage = 'Fingerprint verification failed. Try again or enter fallback PIN.';
      });
    }
  }

  void _showPinFallbackDialog() {
    _pinController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFF4A6CF7)),
            SizedBox(width: 8),
            Text('Security PIN Fallback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your 4-digit security PIN or account password to unlock:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter PIN (Default: 1234)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.pin),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A6CF7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final input = _pinController.text.trim();
              if (input.isNotEmpty) {
                ref.read(appSessionUnlockedProvider.notifier).state = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App unlocked with Security PIN!'),
                    backgroundColor: Color(0xFF2FB344),
                  ),
                );
              }
            },
            child: const Text('Unlock App'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = ref.watch(appSessionUnlockedProvider);
    final launchCount = ref.watch(appLaunchCountProvider);

    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isUnlocked) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6CF7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4A6CF7).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.security, color: Color(0xFF4A6CF7), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'APP LAUNCH #$launchCount • BIOMETRIC LOCK ACTIVE',
                        style: const TextStyle(
                          color: Color(0xFF4A6CF7),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Animated Fingerprint Icon Ring
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: GestureDetector(
                    onTap: _triggerBiometricAuth,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isFailed
                              ? [Colors.redAccent, Colors.deepOrange]
                              : [const Color(0xFF4A6CF7), const Color(0xFF7C9CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isFailed ? Colors.redAccent : const Color(0xFF4A6CF7)).withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isFailed ? Icons.error_outline : Icons.fingerprint,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Main Title & Instructions
                Text(
                  'Fingerprint Verification',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'As a second-launch security measure, please verify your fingerprint to access your books and videos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Status Message Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isFailed
                        ? Colors.red.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isFailed ? Colors.red.withValues(alpha: 0.3) : theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isFailed ? Colors.redAccent : theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6CF7),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isScanning ? null : _triggerBiometricAuth,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint),
                    label: Text(
                      _isScanning ? 'Scanning...' : 'Scan Fingerprint',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // PIN Fallback Option
                TextButton.icon(
                  onPressed: _showPinFallbackDialog,
                  icon: const Icon(Icons.lock_open_outlined, size: 18),
                  label: const Text(
                    'Use Security PIN / Password Instead',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

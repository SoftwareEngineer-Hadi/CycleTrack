import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/models.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../app_lock.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  String? _error;
  bool _biometricBusy = false;
  bool _autoBiometricAttempted = false;
  final _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric(auto: true));
  }

  bool get _biometricEnabled =>
      ref.read(settingsMapProvider)[SettingsKeys.biometricEnabled] == 'true';

  Future<void> _tryBiometric({bool auto = false}) async {
    if (_biometricBusy) return;
    if (!_biometricEnabled) return;
    if (auto && _autoBiometricAttempted) return;
    if (auto) _autoBiometricAttempted = true;

    setState(() {
      _biometricBusy = true;
      if (!auto) _error = null;
    });

    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        if (!auto && mounted) {
          setState(() => _error = 'Biometrics not available on this device');
        }
        return;
      }

      final biometrics = await _auth.getAvailableBiometrics();
      if (biometrics.isEmpty) {
        if (!auto && mounted) {
          setState(
            () => _error = 'No fingerprint or face enrolled on this device',
          );
        }
        return;
      }

      final ok = await _auth.authenticate(
        localizedReason: 'Unlock CycleTrack',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (ok && mounted) {
        ref.read(appLockProvider.notifier).state = false;
      }
    } on LocalAuthException catch (e) {
      if (!mounted || auto) return;
      final message = switch (e.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled =>
          null,
        LocalAuthExceptionCode.noBiometricHardware =>
          'No biometric hardware on this device',
        LocalAuthExceptionCode.noBiometricsEnrolled =>
          'Enroll a fingerprint or face in device settings',
        LocalAuthExceptionCode.biometricLockout ||
        LocalAuthExceptionCode.temporaryLockout =>
          'Too many attempts — use your PIN',
        _ => 'Biometric unlock failed — use your PIN',
      };
      if (message != null) setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _biometricBusy = false);
    }
  }

  Future<void> _submit() async {
    final hash =
        ref.read(settingsMapProvider)[SettingsKeys.pinHash];
    if (hash == null) {
      ref.read(appLockProvider.notifier).state = false;
      return;
    }
    if (hashPin(_pin) == hash) {
      ref.read(appLockProvider.notifier).state = false;
    } else {
      setState(() {
        _error = 'Incorrect PIN';
        _pin = '';
      });
    }
  }

  void _digit(String d) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length >= 4) {
      _maybeAutoSubmit();
    }
  }

  Future<void> _maybeAutoSubmit() async {
    final hash =
        ref.read(settingsMapProvider)[SettingsKeys.pinHash];
    if (hash == null) return;
    if (hashPin(_pin) == hash) {
      ref.read(appLockProvider.notifier).state = false;
    } else if (_pin.length == 6) {
      setState(() {
        _error = 'Incorrect PIN';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;
    final settings = ref.watch(settingsMapProvider);
    final showBiometric = settings[SettingsKeys.biometricEnabled] == 'true';

    ref.listen(settingsMapProvider, (prev, next) {
      if (next[SettingsKeys.biometricEnabled] == 'true' &&
          !_autoBiometricAttempted &&
          !_biometricBusy) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _tryBiometric(auto: true),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.lock_outline,
                  size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('CycleTrack is locked',
                  style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                showBiometric
                    ? 'Use biometrics or enter your PIN'
                    : 'Enter your PIN to continue',
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? theme.colorScheme.primary
                          : colors.border,
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: TextStyle(color: theme.colorScheme.error)),
              ],
              const Spacer(),
              for (final row in [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
                ['bio', '0', 'del'],
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final key in row)
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: key == 'bio'
                              ? IconButton(
                                  onPressed: showBiometric && !_biometricBusy
                                      ? () => _tryBiometric()
                                      : null,
                                  icon: Icon(
                                    Icons.fingerprint,
                                    size: 32,
                                    color: showBiometric
                                        ? theme.colorScheme.primary
                                        : colors.border,
                                  ),
                                )
                              : key == 'del'
                                  ? IconButton(
                                      onPressed: () {
                                        if (_pin.isEmpty) return;
                                        setState(() => _pin =
                                            _pin.substring(0, _pin.length - 1));
                                      },
                                      icon: const Icon(Icons.backspace_outlined),
                                    )
                                  : TextButton(
                                      onPressed: () => _digit(key),
                                      child: Text(key,
                                          style: theme
                                              .textTheme.headlineMedium),
                                    ),
                        ),
                    ],
                  ),
                ),
              TextButton(onPressed: _submit, child: const Text('Unlock')),
            ],
          ),
        ),
      ),
    );
  }
}

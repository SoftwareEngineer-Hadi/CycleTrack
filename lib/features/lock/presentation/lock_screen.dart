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
  bool _triedBiometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  Future<void> _tryBiometric() async {
    if (_triedBiometric) return;
    _triedBiometric = true;
    final settings = ref.read(settingsMapProvider);
    if (settings[SettingsKeys.biometricEnabled] != 'true') return;

    final auth = LocalAuthentication();
    try {
      final ok = await auth.authenticate(
        localizedReason: 'Unlock CycleTrack',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (ok && mounted) {
        ref.read(appLockProvider.notifier).state = false;
      }
    } catch (_) {
      // Fall through to PIN entry.
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
      // Auto-submit when length matches stored PIN (4–6). Wait until 4+.
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
                'Enter your PIN to continue',
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
                                  onPressed: _tryBiometric,
                                  icon: const Icon(Icons.fingerprint,
                                      size: 32),
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

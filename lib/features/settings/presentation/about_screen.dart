import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.cycleColors;

    return Scaffold(
      appBar: AppBar(title: const Text('About & privacy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('CycleTrack', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Version 1.0.0', style: theme.textTheme.bodySmall),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Privacy-first by design',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'CycleTrack works fully offline. Your logs stay in an '
                    'encrypted local database on this device. Cloud backup is '
                    'optional and encrypts data on-device before upload — '
                    'the server never sees plaintext cycle data.',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Not medical advice',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Predictions are statistical estimates based on your '
                    'logged history. They are not a substitute for medical '
                    'advice, diagnosis, or contraception counseling.',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your controls', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '• Use anonymously — no account required\n'
                    '• App lock with PIN / biometrics\n'
                    '• Export CSV for clinic visits\n'
                    '• One-tap delete of local + cloud data',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

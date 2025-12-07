import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp_sample/data/repositories/device_security/providers/device_security_status_provider.dart';
import 'package:freerasp_sample/domains/value_object/device_security_status.dart';
import 'package:freerasp_sample/presentations/screens/home/screen.dart';
import 'package:go_router/go_router.dart';

part 'screen.part_async_data.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  static const name = 'LoginScreen';
  static const path = '/login';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSecurityStatus = ref.watch(deviceSecurityStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: Center(
        child: switch (asyncSecurityStatus) {
          AsyncValue(value: final status?) =>
            _SecurityStatusView(status: status),
          AsyncError(:final error) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text('エラーが発生しました: $error'),
              ],
            ),
          AsyncLoading() => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('初期化中...'),
              ],
            ),
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp_sample/data/repositories/device_security/providers/device_security_repository_provider.dart';
import 'package:freerasp_sample/data/repositories/device_security/providers/device_security_status_provider.dart';
import 'package:freerasp_sample/domains/value_object/device_security_status.dart';
import 'package:freerasp_sample/presentations/screens/login/screen.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  static const name = 'HomeScreen';
  static const path = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 不正が検知されたらログイン画面に戻す
    ref.listen(
      deviceSecurityStatusProvider,
      (previous, next) async {
        if (next.value case DeviceSecurityStatusThreat()) {
          // データ削除のモック処理
          await mockDeleteAllData();
          // ログイン画面に遷移
          if (!context.mounted) return;
          context.go(LoginScreen.path);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text('アイテム ${index + 1}'),
            subtitle: const Text('これはサンプルのリストアイテムです'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('アイテム ${index + 1} がタップされました')),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 脅威検知をシミュレート (実験のためにこの関数の実行を許可する)
          // ignore: invalid_use_of_visible_for_testing_member
          ref.read(deviceSecurityRepositoryProvider()).simulateThreatDetection(
                'シミュレートされた脅威',
              );
        },
        tooltip: '脅威をシミュレート',
        child: const Icon(Icons.warning),
      ),
    );
  }
}

Future<void> mockDeleteAllData() async {
  // データ削除をシミュレート
  await Future<void>.delayed(const Duration(microseconds: 300));
}

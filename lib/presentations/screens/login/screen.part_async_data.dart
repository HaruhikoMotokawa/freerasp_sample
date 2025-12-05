part of 'screen.dart';

class _SecurityStatusView extends StatelessWidget {
  const _SecurityStatusView({required this.status});

  final DeviceSecurityStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      DeviceSecurityStatusChecking() => const _CheckingView(),
      DeviceSecurityStatusSafe() => const _SafeView(),
      DeviceSecurityStatusThreat(:final message) =>
        _ThreatView(message: message),
    };
  }
}

class _CheckingView extends StatelessWidget {
  const _CheckingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('セキュリティチェック中...'),
      ],
    );
  }
}

class _SafeView extends StatelessWidget {
  const _SafeView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 64,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        const Text(
          'セキュリティチェック完了',
          style: TextStyle(
            fontSize: 16,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            // ログイン処理
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 12,
            ),
            child: Text(
              'ログイン',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThreatView extends StatelessWidget {
  const _ThreatView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.block,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        const Text(
          'このアプリは使用できません',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'セキュリティ上の問題が検出されました。\n$message',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

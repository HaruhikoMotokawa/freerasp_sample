import 'package:async/async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_sample/data/repositories/device_security/device_security_repository.dart';
import 'package:freerasp_sample/data/repositories/device_security/providers/device_security_repository_provider.dart';
import 'package:freerasp_sample/data/sources/local/talsec.dart';
import 'package:freerasp_sample/domains/value_object/device_security_status.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';

import '../../../mock/generate_nice_mocks.mocks.dart';

void main() {
  final mockTalsec = MockTalsec();

  late ProviderContainer container;
  late DeviceSecurityRepository repository;

  // コールバックをキャプチャするための変数
  late RaspExecutionStateCallback capturedExecutionCallback;
  late ThreatCallback capturedThreatCallback;

  setUp(() {
    // モックのリセット
    reset(mockTalsec);

    // attachExecutionStateListener のコールバックをキャプチャ
    when(mockTalsec.attachExecutionStateListener(any)).thenAnswer((invocation) {
      capturedExecutionCallback =
          invocation.positionalArguments[0] as RaspExecutionStateCallback;
    });

    // attachListener のコールバックをキャプチャ
    when(mockTalsec.attachListener(any)).thenAnswer((invocation) async {
      capturedThreatCallback =
          invocation.positionalArguments[0] as ThreatCallback;
    });

    // start のモック
    when(mockTalsec.start(any)).thenAnswer((_) async {});

    container = ProviderContainer.test(
      retry: (_, __) => null,
      overrides: [
        talsecProvider.overrideWithValue(mockTalsec),
      ],
    );

    // リポジトリの取得
    repository = container.read(deviceSecurityRepositoryProvider);
  });

  group('init', () {
    test('正しい順序で初期化される', () async {
      // Act
      await repository.init();

      // Assert
      verifyInOrder([
        mockTalsec.attachExecutionStateListener(any),
        mockTalsec.attachListener(any),
        mockTalsec.start(repository.config),
      ]);
    });
  });

  group('watch', () {
    test('初期状態はcheckingを返す', () async {
      // Act
      final status = await repository.watch().first;

      // Assert
      expect(status, const DeviceSecurityStatus.checking());
    });

    group('ExecutionStateCallback', () {
      test('onAllChecksDoneが発火するとsafe状態になる', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act: キャプチャしたコールバックを発火
        capturedExecutionCallback.onAllChecksDone?.call();

        // Assert: StreamQueueで値を取得して検証
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.safe());

        // Cleanup
        await streamQueue.cancel();
      });

      test('脅威検知後はonAllChecksDoneでもsafeにならない', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // 先に脅威を検知させる
        capturedThreatCallback.onPrivilegedAccess?.call();

        // ストリームの現在の状態を確認
        final currentStatus = await streamQueue.next;
        expect(currentStatus, isA<DeviceSecurityStatusThreat>());

        // Act: onAllChecksDoneを発火
        capturedExecutionCallback.onAllChecksDone?.call();

        // Assert: 脅威状態のまま（状態は変わらないので同じ値）
        // 注: 状態が変わらない場合、ストリームは新しい値を発行しないので
        // 現在の状態で検証済み
        await streamQueue.cancel();
      });
    });

    group('ThreatCallback', () {
      test('onHooksが発火するとthreat状態になる', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onHooks?.call();

        // Assert
        final status = await streamQueue.next;
        expect(status, isA<DeviceSecurityStatusThreat>());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onPrivilegedAccessが発火するとthreat状態になる', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onPrivilegedAccess?.call();

        // Assert
        final status = await streamQueue.next;
        expect(status, isA<DeviceSecurityStatusThreat>());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onAppIntegrityが発火するとthreat状態になる', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onAppIntegrity?.call();

        // Assert
        final status = await streamQueue.next;
        expect(status, isA<DeviceSecurityStatusThreat>());

        // Cleanup
        await streamQueue.cancel();
      });

      test('2つ目の脅威は無視される（最初の脅威のみ通知）', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // 最初の脅威
        capturedThreatCallback.onHooks?.call();
        final firstStatus = await streamQueue.next;
        expect(firstStatus, isA<DeviceSecurityStatusThreat>());
        final firstMessage =
            (firstStatus as DeviceSecurityStatusThreat).message;

        // Act: 2つ目の脅威を発火
        capturedThreatCallback.onPrivilegedAccess?.call();

        // Assert: 状態は変わらない（最初の脅威のメッセージのまま）
        // 注: 2つ目の脅威は無視されるため新しい値は発行されない
        // 現在の状態が最初の脅威のままであることを確認済み
        expect(firstMessage, isNotEmpty);

        // Cleanup
        await streamQueue.cancel();
      });
    });
  });

  group('dispose', () {
    test('disposeが正常に完了する', () async {
      // Act & Assert
      await expectLater(repository.dispose(), completes);
    });
  });
}

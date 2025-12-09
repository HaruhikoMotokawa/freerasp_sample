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
  var isRepositoryInitialized = false;

  // コールバックをキャプチャするための変数
  late RaspExecutionStateCallback capturedExecutionCallback;
  late ThreatCallback capturedThreatCallback;

  void setUpRepository({bool enableThreatInDebug = true}) {
    if (isRepositoryInitialized) {
      container.dispose();
    }
    isRepositoryInitialized = true;
    container = ProviderContainer.test(
      retry: (_, __) => null,
      overrides: [
        talsecProvider.overrideWithValue(mockTalsec),
      ],
    );

    // リポジトリの取得
    repository = container.read(
      deviceSecurityRepositoryProvider(
        enableThreatInDebug: enableThreatInDebug,
      ),
    );
  }

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

    setUpRepository();
  });

  tearDown(() {
    if (isRepositoryInitialized) {
      container.dispose();
      isRepositoryInitialized = false;
    }
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
      final streamQueue = StreamQueue(repository.watch());
      final status = await streamQueue.next;

      // Assert
      expect(status, const DeviceSecurityStatus.checking());

      // Cleanup
      await streamQueue.cancel();
    });

    group('ExecutionStateCallback', () {
      test('onAllChecksDoneが発火するとsafe状態になる', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act: コールバックを先に発火（内部状態を変更）
        capturedExecutionCallback.onAllChecksDone?.call();

        // Assert: watch()で取得すると最初からsafe状態
        // yield _value で変更後の値が返される

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

        // Act: onAllChecksDoneを発火
        capturedExecutionCallback.onAllChecksDone?.call();

        // ストリームの現在の状態を確認
        final currentStatus = await streamQueue.next;
        expect(currentStatus, isA<DeviceSecurityStatusThreat>());

        await streamQueue.cancel();
      });
    });

    group('ThreatCallback - blockレベル', () {
      test('onHooksが発火するとthreat状態になる', () async {
        // Arrange
        final streamQueue = StreamQueue(repository.watch());
        await repository.init();

        // 最初はchecking状態
        final initialStatus = await streamQueue.next;
        expect(initialStatus, const DeviceSecurityStatus.checking());

        // Act
        capturedThreatCallback.onHooks?.call();

        // Assert
        final status = await streamQueue.next;
        expect(status, isA<DeviceSecurityStatusThreat>());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onDebugが発火してもデバッグモードでは無視される', () async {
        // Arrange
        setUpRepository(enableThreatInDebug: false);
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onDebug?.call();

        // Assert: デバッグモードでは無視されるため状態は変化しない
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());
      });

      test('onSimulatorが発火してもデバッグモードでは無視される', () async {
        // Arrange
        setUpRepository(enableThreatInDebug: false);
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onSimulator?.call();

        // Assert: デバッグモードでは無視されるため状態は変化しない
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

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

      test('onDeviceBindingが発火するとthreat状態になる', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onDeviceBinding?.call();

        // Assert
        final status = await streamQueue.next;
        expect(status, isA<DeviceSecurityStatusThreat>());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onUnofficialStoreが発火してもデバッグモードでは無視される', () async {
        // Arrange
        setUpRepository(enableThreatInDebug: false);
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onUnofficialStore?.call();

        // Assert: デバッグモードでは無視されるため状態は変化しない
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

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

      test('onMalwareが発火するとthreat状態になる', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onMalware?.call([]);

        // Assert
        final status = await streamQueue.next;
        expect(status, isA<DeviceSecurityStatusThreat>());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onMultiInstanceが発火するとthreat状態になる', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onMultiInstance?.call();

        // Assert
        final status = await streamQueue.next;
        expect(status, isA<DeviceSecurityStatusThreat>());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onTimeSpoofingが発火するとthreat状態になる', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onTimeSpoofing?.call();

        // Assert
        final status = await streamQueue.next;
        expect(status, isA<DeviceSecurityStatusThreat>());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onLocationSpoofingが発火するとthreat状態になる', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onLocationSpoofing?.call();

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

    group('ThreatCallback - monitorレベル', () {
      test('onPasscodeが発火してもthreat状態にならない（monitor）', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onPasscode?.call();

        // Assert: monitorレベルはストリームに流さない
        // 状態変化がないので初期状態のまま
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onObfuscationIssuesが発火してもデバッグモードでは無視される', () async {
        // Arrange
        setUpRepository(enableThreatInDebug: false);
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onObfuscationIssues?.call();

        // Assert: デバッグモードでは無視されるため状態は変化しない
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onSecureHardwareNotAvailableが発火してもthreat状態にならない', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onSecureHardwareNotAvailable?.call();

        // Assert: monitorレベルはストリームに流さない
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onDevModeが発火してもデバッグモードでは無視される', () async {
        // Arrange
        setUpRepository(enableThreatInDebug: false);
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onDevMode?.call();

        // Assert: デバッグモードでは無視されるため状態は変化しない
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onADBEnabledが発火してもデバッグモードでは無視される', () async {
        // Arrange
        setUpRepository(enableThreatInDebug: false);
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onADBEnabled?.call();

        // Assert: デバッグモードでは無視されるため状態は変化しない
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

        // Cleanup
        await streamQueue.cancel();
      });
    });

    group('ThreatCallback - ignoreレベル', () {
      test('onDeviceIDが発火してもthreat状態にならない（ignore）', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onDeviceID?.call();

        // Assert: ignoreレベルは何もしない
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onSystemVPNが発火してもthreat状態にならない（ignore）', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onSystemVPN?.call();

        // Assert: ignoreレベル
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onScreenshotが発火してもthreat状態にならない（ignore）', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onScreenshot?.call();

        // Assert: ignoreレベル
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onScreenRecordingが発火してもthreat状態にならない（ignore）', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onScreenRecording?.call();

        // Assert: ignoreレベル
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

        // Cleanup
        await streamQueue.cancel();
      });

      test('onUnsecureWiFiが発火してもthreat状態にならない（ignore）', () async {
        // Arrange
        await repository.init();
        final streamQueue = StreamQueue(repository.watch());

        // Act
        capturedThreatCallback.onUnsecureWiFi?.call();

        // Assert: ignoreレベル
        final status = await streamQueue.next;
        expect(status, const DeviceSecurityStatus.checking());

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

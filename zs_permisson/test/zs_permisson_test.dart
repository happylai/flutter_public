import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zs_permisson/zs_permisson.dart';

void main() {
  const MethodChannel channel = MethodChannel('zs_permisson');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
  });
}

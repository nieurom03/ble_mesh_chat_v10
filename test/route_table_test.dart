import 'package:flutter_test/flutter_test.dart';
import 'package:ble_mesh_chat/services/route_table.dart';

void main() {
  test('learns the lower metric route', () {
    final r = RouteTable();
    r.learn(destination: 'D', nextHop: 'B', metric: 4);
    r.learn(destination: 'D', nextHop: 'C', metric: 2);
    expect(r.nextHop('D'), 'C');
  });

  test('expired routes disappear', () {
    final r = RouteTable();
    r.learn(
      destination: 'D',
      nextHop: 'B',
      metric: 1,
      lifetime: const Duration(milliseconds: 1),
    );
    Future.delayed(const Duration(milliseconds: 5), () {
      expect(r.nextHop('D'), isNull);
    });
  });
}

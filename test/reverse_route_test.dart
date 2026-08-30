import 'package:flutter_test/flutter_test.dart';
import 'package:ble_mesh_chat/services/route_table.dart';

void main() {
  test('D can learn reverse route to A from received frame path', () {
    final d = RouteTable();

    // D received a frame from C whose source was A and hop count is 2.
    d.learn(
      destination: 'A',
      nextHop: 'C',
      metric: 3,
      sequence: 10,
    );

    expect(d.nextHop('A'), 'C');
  });

  test('newer route sequence replaces lower quality old route', () {
    final r = RouteTable();
    r.learn(destination: 'A', nextHop: 'C', metric: 1, sequence: 1);
    r.learn(destination: 'A', nextHop: 'B', metric: 5, sequence: 2);

    expect(r.nextHop('A'), 'B');
  });
}

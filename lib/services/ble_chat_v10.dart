import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kMeshServiceUuid = '8F9E0001-5A4D-4C0A-9B8F-000000000001';
const kRequestUuid = '8F9E0002-5A4D-4C0A-9B8F-000000000001';
const kControlUuid = '8F9E0003-5A4D-4C0A-9B8F-000000000001';
const kMessageUuid = '8F9E0004-5A4D-4C0A-9B8F-000000000001';

bool _uuidEquals(UUID a, String b) =>
    a.toString().replaceAll('-', '').toUpperCase() ==
    b.replaceAll('-', '').toUpperCase();

class DiscoveredPhone {
  final Peripheral peripheral;
  final String name;
  final int rssi;
  DateTime lastSeen;
  bool connecting;
  bool connected;

  DiscoveredPhone({
    required this.peripheral,
    required this.name,
    required this.rssi,
    DateTime? lastSeen,
    this.connecting = false,
    this.connected = false,
  }) : lastSeen = lastSeen ?? DateTime.now();
}

class IncomingConnectionRequest {
  final Central central;
  final String remoteNodeId;
  final String remoteName;

  const IncomingConnectionRequest({
    required this.central,
    required this.remoteNodeId,
    required this.remoteName,
  });
}

class V10ChatMessage {
  final String id;
  final String fromNodeId;
  final String text;
  final DateTime time;
  final bool mine;

  const V10ChatMessage({
    required this.id,
    required this.fromNodeId,
    required this.text,
    required this.time,
    required this.mine,
  });
}

class BleChatV10Controller extends ChangeNotifier {
  final CentralManager central = CentralManager();
  final PeripheralManager peripheral = PeripheralManager();

  final List<DiscoveredPhone> phones = [];
  final List<V10ChatMessage> messages = [];

  StreamSubscription? _centralStateSub;
  StreamSubscription? _peripheralStateSub;
  StreamSubscription? _discoveredSub;
  StreamSubscription? _centralConnectionSub;
  StreamSubscription? _notifiedSub;
  StreamSubscription? _writeRequestedSub;
  StreamSubscription? _notifyStateSub;

  BluetoothLowEnergyState bluetoothState = BluetoothLowEnergyState.unknown;
  bool scanning = false;
  bool advertising = false;
  bool connected = false;
  String? connectedName;
  String? connectedNodeId;
  String? error;

  int unreadCount = 0;
  bool isChatOpen = false;
  final _incomingMessageController =
      StreamController<V10ChatMessage>.broadcast();
  Stream<V10ChatMessage> get incomingMessages =>
      _incomingMessageController.stream;

  Peripheral? _connectedPeripheral;
  GATTCharacteristic? _requestCharacteristic;
  GATTCharacteristic? _controlCharacteristic;
  GATTCharacteristic? _messageCharacteristic;

  GATTService? _localService;
  GATTCharacteristic? _localRequestCharacteristic;
  GATTCharacteristic? _localControlCharacteristic;
  GATTCharacteristic? _localMessageCharacteristic;
  Central? _incomingCentral;

  String nodeId = 'NODE-A';
  String nodeName = 'BLE Mesh';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    nodeId =
        prefs.getString('node_id') ??
        'NODE-${DateTime.now().millisecondsSinceEpoch % 10000}';

    // Lấy tên thiết bị thực của máy làm tên mặc định
    String defaultName;
    try {
      final hostname = Platform.localHostname;
      // Loại bỏ ".local" suffix nếu có (macOS thường có đuôi này)
      defaultName = hostname.replaceAll('.local', '');
      // Giới hạn 20 ký tự
      if (defaultName.length > 20) defaultName = defaultName.substring(0, 20);
    } catch (_) {
      defaultName = nodeId;
    }

    nodeName = prefs.getString('node_name') ?? defaultName;
    await prefs.setString('node_id', nodeId);
    await prefs.setString('node_name', nodeName);

    _centralStateSub = central.stateChanged.listen((e) {
      bluetoothState = e.state;
      if (e.state == BluetoothLowEnergyState.poweredOn && !advertising) {
        startAdvertising();
      }
      notifyListeners();
    });
    _peripheralStateSub = peripheral.stateChanged.listen((e) {
      bluetoothState = e.state;
      if (e.state == BluetoothLowEnergyState.poweredOn && !advertising) {
        startAdvertising();
      }
      notifyListeners();
    });
    _discoveredSub = central.discovered.listen(_onDiscovered);
    _centralConnectionSub = central.connectionStateChanged.listen(
      _onCentralConnectionChanged,
    );
    _notifiedSub = central.characteristicNotified.listen(
      _onCentralNotification,
    );
    _writeRequestedSub = peripheral.characteristicWriteRequested.listen(
      _onPeripheralWrite,
    );
    _notifyStateSub = peripheral.characteristicNotifyStateChanged.listen(
      (_) {},
    );

    bluetoothState = central.state;
    notifyListeners();
  }

  Future<void> setNodeName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    nodeName = trimmed.length > 20 ? trimmed.substring(0, 20) : trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('node_name', nodeName);
    if (advertising) {
      await startAdvertising();
    }
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void setChatOpen(bool open) {
    isChatOpen = open;
    if (open) {
      unreadCount = 0;
    }
    notifyListeners();
  }

  void markAsRead() {
    if (unreadCount > 0) {
      unreadCount = 0;
      notifyListeners();
    }
  }

  Future<bool> authorize() async {
    try {
      final c = await central.authorize();
      return c;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> startAdvertising() async {
    try {
      await peripheral.removeAllServices();
      final service = GATTService(
        uuid: UUID.fromString(kMeshServiceUuid),
        isPrimary: true,
        includedServices: [],
        characteristics: [
          GATTCharacteristic.mutable(
            uuid: UUID.fromString(kRequestUuid),
            properties: [
              GATTCharacteristicProperty.read,
              GATTCharacteristicProperty.write,
              GATTCharacteristicProperty.writeWithoutResponse,
            ],
            permissions: [
              GATTCharacteristicPermission.read,
              GATTCharacteristicPermission.write,
            ],
            descriptors: [],
          ),
          GATTCharacteristic.mutable(
            uuid: UUID.fromString(kControlUuid),
            properties: [
              GATTCharacteristicProperty.read,
              GATTCharacteristicProperty.write,
              GATTCharacteristicProperty.writeWithoutResponse,
              GATTCharacteristicProperty.notify,
              GATTCharacteristicProperty.indicate,
            ],
            permissions: [
              GATTCharacteristicPermission.read,
              GATTCharacteristicPermission.write,
            ],
            descriptors: [],
          ),
          GATTCharacteristic.mutable(
            uuid: UUID.fromString(kMessageUuid),
            properties: [
              GATTCharacteristicProperty.read,
              GATTCharacteristicProperty.write,
              GATTCharacteristicProperty.writeWithoutResponse,
              GATTCharacteristicProperty.notify,
              GATTCharacteristicProperty.indicate,
            ],
            permissions: [
              GATTCharacteristicPermission.read,
              GATTCharacteristicPermission.write,
            ],
            descriptors: [],
          ),
        ],
      );

      await peripheral.addService(service);
      _localService = service;
      _localRequestCharacteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString().toUpperCase() == kRequestUuid.toUpperCase(),
      );
      _localControlCharacteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString().toUpperCase() == kControlUuid.toUpperCase(),
      );
      _localMessageCharacteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString().toUpperCase() == kMessageUuid.toUpperCase(),
      );

      await peripheral.startAdvertising(
        Advertisement(
          name: nodeName,
          serviceUUIDs: [UUID.fromString(kMeshServiceUuid)],
        ),
      );
      advertising = true;
      error = null;
      notifyListeners();
    } catch (e) {
      error = 'Advertising failed: $e';
      notifyListeners();
    }
  }

  Future<void> stopAdvertising() async {
    try {
      await peripheral.stopAdvertising();
    } finally {
      advertising = false;
      notifyListeners();
    }
  }

  Future<void> startScan() async {
    if (scanning) return;
    try {
      await central.stopDiscovery();
    } catch (_) {}
    phones.clear();
    scanning = true;
    error = null;
    notifyListeners();
    try {
      await central.startDiscovery(
        serviceUUIDs: [UUID.fromString(kMeshServiceUuid)],
      );
    } catch (e) {
      scanning = false;
      error = 'Scan failed: $e';
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    if (!scanning) return;
    try {
      await central.stopDiscovery();
    } finally {
      scanning = false;
      notifyListeners();
    }
  }

  void _onDiscovered(DiscoveredEventArgs e) {
    final name = (e.advertisement.name?.trim().isNotEmpty ?? false)
        ? e.advertisement.name!.trim()
        : 'BLE phone ${e.peripheral.uuid}';
    if (name == nodeName) {
      // Same app name is allowed; UUID is what uniquely identifies the peer.
    }

    final index = phones.indexWhere(
      (p) => p.peripheral.uuid == e.peripheral.uuid,
    );
    if (index >= 0) {
      final old = phones[index];
      old.lastSeen = DateTime.now();
      phones[index] = DiscoveredPhone(
        peripheral: e.peripheral,
        name: name,
        rssi: e.rssi,
        connecting: old.connecting,
        connected: old.connected,
      );
    } else {
      phones.add(
        DiscoveredPhone(peripheral: e.peripheral, name: name, rssi: e.rssi),
      );
    }
    phones.sort((a, b) => b.rssi.compareTo(a.rssi));
    notifyListeners();
  }

  Future<void> connectTo(DiscoveredPhone phone) async {
    if (phone.connecting || phone.connected) return;
    phone.connecting = true;
    error = null;
    notifyListeners();

    // iOS CoreBluetooth: phải dừng scan và advertising trước khi connect
    try {
      await stopScan();
    } catch (_) {}
    try {
      await stopAdvertising();
    } catch (_) {}

    try {
      await central.connect(phone.peripheral);
      await _prepareCentralConnection(phone.peripheral, phone.name);
      // Cập nhật trạng thái sau khi GATT setup xong
      phone.connecting = false;
      // phone.connected sẽ được set trong _onCentralNotification khi nhận connect_response
      notifyListeners();
    } catch (e) {
      phone.connecting = false;
      phone.connected = false;
      try {
        await central.disconnect(phone.peripheral);
      } catch (_) {}
      error = 'Connect failed: $e';
      debugPrint('[BLE] connectTo error: $e');
      // Khởi động lại advertising sau khi kết nối thất bại
      unawaited(startAdvertising());
      notifyListeners();
    }
  }

  Future<void> _prepareCentralConnection(
    Peripheral peripheralDevice,
    String name,
  ) async {
    final services = await central.discoverGATT(peripheralDevice);
    debugPrint(
      '[BLE] Discovered services: ${services.map((s) => s.uuid).toList()}',
    );

    GATTService? service;
    for (final s in services) {
      if (_uuidEquals(s.uuid, kMeshServiceUuid)) {
        service = s;
        break;
      }
    }
    if (service == null) {
      throw StateError(
        'Dịch vụ Mesh GATT chưa sẵn sàng. Services tìm thấy: ${services.map((s) => s.uuid).toList()}',
      );
    }

    debugPrint(
      '[BLE] Characteristics: ${service.characteristics.map((c) => c.uuid).toList()}',
    );

    GATTCharacteristic? request, control, message;
    for (final c in service.characteristics) {
      if (_uuidEquals(c.uuid, kRequestUuid)) request = c;
      if (_uuidEquals(c.uuid, kControlUuid)) control = c;
      if (_uuidEquals(c.uuid, kMessageUuid)) message = c;
    }
    if (request == null)
      throw StateError('Không tìm thấy Request characteristic');
    if (control == null)
      throw StateError('Không tìm thấy Control characteristic');
    if (message == null)
      throw StateError('Không tìm thấy Message characteristic');

    _connectedPeripheral = peripheralDevice;
    _requestCharacteristic = request;
    _controlCharacteristic = control;
    _messageCharacteristic = message;
    connectedName = name;
    connectedNodeId = peripheralDevice.uuid.toString();

    // Giãn cách để CoreBluetooth ổn định GATT table
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      await central.setCharacteristicNotifyState(
        peripheralDevice,
        control,
        state: true,
      );
      debugPrint('[BLE] Control notify ON');
    } catch (e) {
      debugPrint('[BLE] Warning: control notify error: $e');
    }

    await Future.delayed(const Duration(milliseconds: 150));
    try {
      await central.setCharacteristicNotifyState(
        peripheralDevice,
        message,
        state: true,
      );
      debugPrint('[BLE] Message notify ON');
    } catch (e) {
      debugPrint('[BLE] Warning: message notify error: $e');
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final payload = utf8.encode(
      jsonEncode({
        'type': 'connect_request',
        'nodeId': nodeId,
        'name': nodeName,
      }),
    );
    await central.writeCharacteristic(
      peripheralDevice,
      request,
      value: Uint8List.fromList(payload),
      type: GATTCharacteristicWriteType.withResponse,
    );
    debugPrint('[BLE] connect_request sent to $name');
  }

  void _onCentralConnectionChanged(
    PeripheralConnectionStateChangedEventArgs e,
  ) {
    final index = phones.indexWhere(
      (p) => p.peripheral.uuid == e.peripheral.uuid,
    );
    if (e.state == ConnectionState.disconnected) {
      if (index >= 0) {
        phones[index].connecting = false;
        phones[index].connected = false;
      }
      if (_connectedPeripheral?.uuid == e.peripheral.uuid) {
        connected = false;
        connectedName = null;
        connectedNodeId = null;
        _connectedPeripheral = null;
        _requestCharacteristic = null;
        _controlCharacteristic = null;
        _messageCharacteristic = null;
      }
      notifyListeners();
    }
  }

  void _onCentralNotification(GATTCharacteristicNotifiedEventArgs e) {
    final text = utf8.decode(e.value, allowMalformed: true);
    Map<String, dynamic>? packet;
    try {
      packet = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    if (_uuidEquals(e.characteristic.uuid, kControlUuid)) {
      if (packet['type'] == 'connect_response') {
        final accepted = packet['accepted'] == true;
        connected = accepted;
        final name = packet['name']?.toString() ?? connectedName ?? 'Peer';
        connectedName = name;
        final index = phones.indexWhere(
          (p) => p.peripheral.uuid == _connectedPeripheral?.uuid,
        );
        if (index >= 0) {
          phones[index].connecting = false;
          phones[index].connected = accepted;
        }
        if (!accepted) {
          error = 'Connection rejected by $name';
        }
        notifyListeners();
      }
      return;
    }
    if (_uuidEquals(e.characteristic.uuid, kMessageUuid) &&
        packet['type'] == 'chat') {
      final msg = V10ChatMessage(
        id:
            packet['id']?.toString() ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        fromNodeId: packet['from']?.toString() ?? 'peer',
        text: packet['text']?.toString() ?? '',
        time: DateTime.now(),
        mine: false,
      );
      messages.add(msg);
      if (!isChatOpen) {
        unreadCount++;
      }
      _incomingMessageController.add(msg);
      notifyListeners();
    }
  }

  void _onPeripheralWrite(GATTCharacteristicWriteRequestedEventArgs e) {
    final value = e.request.value;
    final text = utf8.decode(value, allowMalformed: true);
    debugPrint(
      '[BLE-P] writeRequested char=${e.characteristic.uuid} raw=$text',
    );

    Map<String, dynamic>? packet;
    try {
      packet = jsonDecode(text) as Map<String, dynamic>;
    } catch (err) {
      debugPrint('[BLE-P] JSON parse error: $err');
      unawaited(peripheral.respondWriteRequest(e.request));
      return;
    }

    unawaited(peripheral.respondWriteRequest(e.request));
    debugPrint(
      '[BLE-P] packet type=${packet['type']}, char matches kRequestUuid=${_uuidEquals(e.characteristic.uuid, kRequestUuid)}',
    );

    if (_uuidEquals(e.characteristic.uuid, kRequestUuid) &&
        packet['type'] == 'connect_request') {
      _incomingCentral = e.central;
      final request = IncomingConnectionRequest(
        central: e.central,
        remoteNodeId: packet['nodeId']?.toString() ?? e.central.uuid.toString(),
        remoteName: packet['name']?.toString() ?? 'BLE phone',
      );
      debugPrint('[BLE-P] Emitting incomingRequest from ${request.remoteName}');
      _incomingRequestController.add(request);
      return;
    }

    if (_uuidEquals(e.characteristic.uuid, kMessageUuid) &&
        packet['type'] == 'chat') {
      final msg = V10ChatMessage(
        id:
            packet['id']?.toString() ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        fromNodeId: packet['from']?.toString() ?? e.central.uuid.toString(),
        text: packet['text']?.toString() ?? '',
        time: DateTime.now(),
        mine: false,
      );
      messages.add(msg);
      if (!isChatOpen) {
        unreadCount++;
      }
      _incomingMessageController.add(msg);
      notifyListeners();
    }
  }

  final _incomingRequestController =
      StreamController<IncomingConnectionRequest>.broadcast();
  Stream<IncomingConnectionRequest> get incomingRequests =>
      _incomingRequestController.stream;

  Future<void> respondToIncomingRequest({
    required IncomingConnectionRequest request,
    required bool accepted,
  }) async {
    final centralDevice = request.central;
    final control = _localControlCharacteristic;
    if (control == null) return;

    await peripheral.notifyCharacteristic(
      centralDevice,
      control,
      value: Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'type': 'connect_response',
            'accepted': accepted,
            'nodeId': nodeId,
            'name': nodeName,
          }),
        ),
      ),
    );

    if (accepted) {
      connected = true;
      connectedName = request.remoteName;
      connectedNodeId = request.remoteNodeId;
    } else {
      connected = false;
    }
    if (!accepted) {
      _incomingCentral = null;
    }
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final value = text.trim();
    if (value.isEmpty || !connected) return;
    final packet = {
      'type': 'chat',
      'id': '${nodeId}-${DateTime.now().microsecondsSinceEpoch}',
      'from': nodeId,
      'text': value,
    };
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(packet)));

    if (_connectedPeripheral != null && _messageCharacteristic != null) {
      await central.writeCharacteristic(
        _connectedPeripheral!,
        _messageCharacteristic!,
        value: bytes,
        type: GATTCharacteristicWriteType.withResponse,
      );
    } else if (_incomingCentral != null &&
        _localMessageCharacteristic != null) {
      await peripheral.notifyCharacteristic(
        _incomingCentral!,
        _localMessageCharacteristic!,
        value: bytes,
      );
    } else {
      return;
    }

    messages.add(
      V10ChatMessage(
        id: packet['id'] as String,
        fromNodeId: nodeId,
        text: value,
        time: DateTime.now(),
        mine: true,
      ),
    );
    notifyListeners();
  }

  Future<void> disconnect() async {
    if (_connectedPeripheral != null) {
      await central.disconnect(_connectedPeripheral!);
    }
    connected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _centralStateSub?.cancel();
    _peripheralStateSub?.cancel();
    _discoveredSub?.cancel();
    _centralConnectionSub?.cancel();
    _notifiedSub?.cancel();
    _writeRequestedSub?.cancel();
    _notifyStateSub?.cancel();
    _incomingRequestController.close();
    _incomingMessageController.close();
    super.dispose();
  }
}

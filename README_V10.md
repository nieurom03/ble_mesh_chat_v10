# BLE Mesh Chat v10

v10 adds real physical-phone BLE discovery, app-level connection approval, and direct chat over GATT using `bluetooth_low_energy 6.2.1`.

## Important behavior

The Network tab does **not** list every phone whose Bluetooth radio is merely ON. It lists phones that are advertising this app's BLE Mesh service. Both phones must run this app and have Bluetooth permission enabled.

The "Accept" step is an **app-level connection request**, not an iOS system pairing dialog. The central phone connects at the BLE/GATT level, subscribes to notifications, then sends a `connect_request`; the other phone shows an in-app dialog. Only after acceptance does the UI mark the session as chat-ready.

## v10 flow

```text
Phone A                         Phone B
  |                                |
  |-- BLE advertisement ---------->|  (B advertises service)
  |                                |
  |-- scan / discover ------------>|
  |                                |
  |-- GATT connect --------------->|
  |-- subscribe control/message -->|
  |-- connect_request ------------>|
  |                                | [Accept / Reject]
  |<-- connect_response -----------|
  |                                |
  |========== CHAT ===============>|
  |<========= CHAT ================|
```

## Physical devices only

BLE does not work for this feature on iOS/Android emulators. Use two physical phones. See package documentation: https://pub.dev/packages/bluetooth_low_energy

## iOS

Add these keys to `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>BLE Mesh Chat uses Bluetooth to discover and communicate with nearby phones.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>BLE Mesh Chat uses Bluetooth to advertise this phone to nearby phones.</string>
```

For background BLE later, add the appropriate Bluetooth background modes in Xcode. v10's first milestone is foreground direct chat.

## Run

```bash
flutter pub get
flutter clean
flutter run -d "YOUR REAL IPHONE"
```

Run the app on **two real iPhones**.

### Phone B
1. Open the app.
2. Keep the app in foreground.
3. Ensure Bluetooth is ON and Bluetooth permission is allowed.
4. Leave advertising enabled.

### Phone A
1. Open `Network`.
2. Tap refresh/scan.
3. Phone B should appear with RSSI.
4. Tap `Kết nối`.

### Phone B
An in-app dialog appears:

`<Phone A> muốn kết nối với điện thoại này để chat qua BLE.`

Tap `Chấp nhận`.

### Both phones
The session becomes `Connected` and the `Chats` tab can send/receive messages.

## Next v10.x

- persistent chat history
- request timeout / cancel
- reconnect after disconnect
- multiple peer sessions
- MTU-aware framing for long messages
- encryption and authenticated node identity
- mesh forwarding A -> B -> C
- background/state restoration

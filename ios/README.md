# iOS v7

Required:
- NSBluetoothAlwaysUsageDescription
- bluetooth-central
- bluetooth-peripheral (when using local peripheral/background BLE)

Apple documents that Core Bluetooth provides both central and peripheral APIs, and that peripheral services can be disabled in background/suspended state without the peripheral background mode.

Do not assume background execution is continuous; validate on real iOS devices.

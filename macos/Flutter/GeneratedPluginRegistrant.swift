//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import bluetooth_low_energy_darwin
import device_info_plus
import shared_preferences_foundation
import sqflite_darwin

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  BluetoothLowEnergyDarwinPlugin.register(with: registry.registrar(forPlugin: "BluetoothLowEnergyDarwinPlugin"))
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BLE Mesh Chat';

  @override
  String get navChats => 'Chats';

  @override
  String get navNodes => 'Nodes';

  @override
  String get navNetwork => 'Network';

  @override
  String get navSettings => 'Settings';

  @override
  String get btOn => 'BT On';

  @override
  String get btOff => 'Off';

  @override
  String get btUnauthorized => 'Unauthorized';

  @override
  String get btUnsupported => 'Unsupported';

  @override
  String get chatsHeaderTitle => 'BLE Mesh Chat';

  @override
  String get chatsRename => 'Rename';

  @override
  String get chatsEmptyTitle => 'No conversations yet';

  @override
  String get chatsEmptySubtitle =>
      'Go to the Network tab to find and connect with nearby phones.';

  @override
  String get chatsConnectedBle => 'Connected • direct BLE';

  @override
  String chatsMine(String text) {
    return 'You: $text';
  }

  @override
  String get chatsOpenChat => 'Open chat';

  @override
  String chatsOpenChatUnread(int count) {
    return 'Open chat  •  $count new';
  }

  @override
  String get newMessage => 'New message';

  @override
  String get snackView => 'View';

  @override
  String get nodesHeaderTitle => 'Nodes';

  @override
  String get nodesHeaderSubtitle => 'Connected / visible BLE devices';

  @override
  String get nodesTagAdvertising => 'Advertising';

  @override
  String get nodesTagOffline => 'Offline';

  @override
  String get nodesTagConnected => 'Connected';

  @override
  String get nodesLegend =>
      'Your device will appear with this name to everyone in BLE range.';

  @override
  String get nodesPeer => 'Peer';

  @override
  String get networkHeaderTitle => 'Network';

  @override
  String networkScanningSubtitle(int count) {
    return 'Scanning  •  $count devices';
  }

  @override
  String get networkIdleSubtitle => 'Find phones broadcasting BLE Mesh';

  @override
  String get networkScanStart => 'Scan';

  @override
  String get networkScanStop => 'Stop';

  @override
  String get networkEmptyTitle => 'No devices found';

  @override
  String get networkScanningTitle => 'Searching…';

  @override
  String get networkEmptyHint =>
      'The other phone must have this app installed, Bluetooth enabled, and be broadcasting BLE Mesh.';

  @override
  String get networkStartScan => 'Start scanning';

  @override
  String get networkSignalStrong => 'Strong';

  @override
  String get networkSignalMedium => 'Medium';

  @override
  String get networkSignalWeak => 'Weak';

  @override
  String get networkConnect => 'Connect';

  @override
  String get networkConnecting => 'Connecting…';

  @override
  String get networkOpenChat => 'Chat';

  @override
  String get chatConnected => 'Connected via BLE';

  @override
  String get chatDisconnected => 'Disconnected';

  @override
  String chatEmptyTitle(String name) {
    return 'Say hi to $name!';
  }

  @override
  String get chatEmptySubtitle =>
      'Messages are sent directly over BLE,\nno internet required.';

  @override
  String get chatDisconnectedBanner => 'BLE connection lost';

  @override
  String get chatInputHint => 'Message…';

  @override
  String get chatInputDisabledHint => 'No connection';

  @override
  String get connectionRequestTitle => 'Connection request';

  @override
  String get connectionRequestBody => ' wants to connect and chat via BLE.';

  @override
  String get connectionRequestAccept => 'Accept';

  @override
  String get connectionRequestReject => 'Decline';

  @override
  String get editNameTitle => 'Name in Mesh';

  @override
  String get editNameSubtitle => 'Shown to people who connect with you';

  @override
  String get editNameHint => 'E.g. John\'s iPhone';

  @override
  String get editNameCancel => 'Cancel';

  @override
  String get editNameSave => 'Save';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Customize your device and connection';

  @override
  String get settingsSectionDevice => 'Your device';

  @override
  String get settingsSectionBluetooth => 'Bluetooth';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsEditName => 'Change display name';

  @override
  String get settingsEditNameSub => 'This name is sent to people who connect';

  @override
  String get settingsBtStatus => 'Bluetooth status';

  @override
  String get settingsAdvertising => 'Advertising';

  @override
  String get settingsAdvertisingOn => 'Broadcasting BLE Mesh signal';

  @override
  String get settingsAdvertisingOff => 'Not broadcasting';

  @override
  String get settingsConnection => 'Connection status';

  @override
  String settingsConnectedWith(String name) {
    return 'Connected to $name';
  }

  @override
  String get settingsNotConnected => 'Not connected';

  @override
  String get settingsDisconnect => 'Disconnect';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsProtocol => 'Protocol';

  @override
  String get settingsProtocolSub => 'BLE Mesh — direct P2P, no internet';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsSecuritySub => 'Messages stay within BLE range only';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get langVietnamese => 'Tiếng Việt';

  @override
  String get langEnglish => 'English';

  @override
  String get langSystemDefault => 'System default';

  @override
  String get settingsSectionPrivacy => 'Privacy & Security';

  @override
  String get settingsBlockedDevices => 'Blocked devices';

  @override
  String get settingsBlockedDevicesSub =>
      'Manage hidden devices and blocked messages';

  @override
  String get blockedDevicesTitle => 'Blocked Devices';

  @override
  String get blockedDevicesEmpty => 'No blocked devices';

  @override
  String get blockedDevicesEmptyHint =>
      'Blocked devices will not appear in scans and cannot send you messages or connection requests.';

  @override
  String get blockDevice => 'Block device';

  @override
  String get unblockDevice => 'Unblock';

  @override
  String blockConfirmTitle(String name) {
    return 'Block $name?';
  }

  @override
  String blockConfirmMessage(String name) {
    return 'You will no longer see $name in the network list and will not receive any messages or connection requests.';
  }

  @override
  String get blockAction => 'Block';

  @override
  String get unblockAction => 'Unblock';

  @override
  String deviceBlockedSnack(String name) {
    return '$name has been blocked';
  }

  @override
  String deviceUnblockedSnack(String name) {
    return '$name has been unblocked';
  }
}

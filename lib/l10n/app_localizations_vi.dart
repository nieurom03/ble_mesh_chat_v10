// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppL10nVi extends AppL10n {
  AppL10nVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'BLE Mesh Chat';

  @override
  String get navChats => 'Trò chuyện';

  @override
  String get navNodes => 'Nodes';

  @override
  String get navNetwork => 'Mạng lưới';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get btOn => 'BT On';

  @override
  String get btOff => 'Tắt';

  @override
  String get btUnauthorized => 'Chưa cấp quyền';

  @override
  String get btUnsupported => 'Không hỗ trợ';

  @override
  String get chatsHeaderTitle => 'BLE Mesh Chat';

  @override
  String get chatsRename => 'Đổi tên';

  @override
  String get chatsEmptyTitle => 'Chưa có cuộc trò chuyện';

  @override
  String get chatsEmptySubtitle =>
      'Vào tab Network để tìm và kết nối với điện thoại gần đây.';

  @override
  String get chatsConnectedBle => 'Connected • direct BLE';

  @override
  String chatsMine(String text) {
    return 'Bạn: $text';
  }

  @override
  String get chatsOpenChat => 'Mở chat';

  @override
  String chatsOpenChatUnread(int count) {
    return 'Mở chat  •  $count tin mới';
  }

  @override
  String get newMessage => 'Tin nhắn mới';

  @override
  String get snackView => 'Xem';

  @override
  String get nodesHeaderTitle => 'Nodes';

  @override
  String get nodesHeaderSubtitle => 'Thiết bị BLE đã kết nối / nhìn thấy';

  @override
  String get nodesTagAdvertising => 'Advertising';

  @override
  String get nodesTagOffline => 'Offline';

  @override
  String get nodesTagConnected => 'Connected';

  @override
  String get nodesLegend =>
      'Thiết bị của bạn sẽ xuất hiện với tên trên cho mọi người trong vùng BLE.';

  @override
  String get nodesPeer => 'Peer';

  @override
  String get networkHeaderTitle => 'Mạng lưới';

  @override
  String networkScanningSubtitle(int count) {
    return 'Đang quét  •  $count thiết bị';
  }

  @override
  String get networkIdleSubtitle => 'Tìm điện thoại quảng bá BLE Mesh';

  @override
  String get networkScanStart => 'Quét';

  @override
  String get networkScanStop => 'Dừng';

  @override
  String get networkEmptyTitle => 'Chưa thấy thiết bị nào';

  @override
  String get networkScanningTitle => 'Đang tìm kiếm…';

  @override
  String get networkEmptyHint =>
      'Điện thoại kia phải cài app này, bật Bluetooth và đang quảng bá BLE Mesh.';

  @override
  String get networkStartScan => 'Bắt đầu quét';

  @override
  String get networkSignalStrong => 'Mạnh';

  @override
  String get networkSignalMedium => 'Trung bình';

  @override
  String get networkSignalWeak => 'Yếu';

  @override
  String get networkConnect => 'Kết nối';

  @override
  String get networkConnecting => 'Đang kết nối…';

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
      'Tin nhắn gửi trực tiếp qua BLE,\nkhông qua internet.';

  @override
  String get chatDisconnectedBanner => 'Đã mất kết nối BLE';

  @override
  String get chatInputHint => 'Nhắn tin…';

  @override
  String get chatInputDisabledHint => 'Không có kết nối';

  @override
  String get connectionRequestTitle => 'Yêu cầu kết nối';

  @override
  String get connectionRequestBody => ' muốn kết nối để chat qua BLE.';

  @override
  String get connectionRequestAccept => 'Chấp nhận';

  @override
  String get connectionRequestReject => 'Từ chối';

  @override
  String get editNameTitle => 'Tên trong Mesh';

  @override
  String get editNameSubtitle => 'Hiển thị với người kết nối';

  @override
  String get editNameHint => 'Ví dụ: iPhone của Nam';

  @override
  String get editNameCancel => 'Hủy';

  @override
  String get editNameSave => 'Lưu';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsSubtitle => 'Tùy chỉnh thiết bị và kết nối';

  @override
  String get settingsSectionDevice => 'Thiết bị của bạn';

  @override
  String get settingsSectionBluetooth => 'Bluetooth';

  @override
  String get settingsSectionAbout => 'Thông tin';

  @override
  String get settingsEditName => 'Đổi tên hiển thị';

  @override
  String get settingsEditNameSub => 'Tên sẽ được gửi đến người kết nối';

  @override
  String get settingsBtStatus => 'Trạng thái Bluetooth';

  @override
  String get settingsAdvertising => 'Quảng bá (Advertising)';

  @override
  String get settingsAdvertisingOn => 'Đang phát tín hiệu BLE Mesh';

  @override
  String get settingsAdvertisingOff => 'Không phát tín hiệu';

  @override
  String get settingsConnection => 'Trạng thái kết nối';

  @override
  String settingsConnectedWith(String name) {
    return 'Đang kết nối với $name';
  }

  @override
  String get settingsNotConnected => 'Chưa kết nối';

  @override
  String get settingsDisconnect => 'Ngắt';

  @override
  String get settingsVersion => 'Phiên bản';

  @override
  String get settingsProtocol => 'Giao thức';

  @override
  String get settingsProtocolSub => 'BLE Mesh — direct P2P, không internet';

  @override
  String get settingsSecurity => 'Bảo mật';

  @override
  String get settingsSecuritySub => 'Tin nhắn chỉ truyền trong phạm vi BLE';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsSectionLanguage => 'Ngôn ngữ';

  @override
  String get langVietnamese => 'Tiếng Việt';

  @override
  String get langEnglish => 'English';

  @override
  String get langSystemDefault => 'Theo hệ thống';
}

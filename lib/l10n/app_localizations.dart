import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// App title shown in window/tab
  ///
  /// In vi, this message translates to:
  /// **'BLE Mesh Chat'**
  String get appTitle;

  /// Bottom nav label
  ///
  /// In vi, this message translates to:
  /// **'Trò chuyện'**
  String get navChats;

  /// Bottom nav label
  ///
  /// In vi, this message translates to:
  /// **'Nodes'**
  String get navNodes;

  /// Bottom nav label
  ///
  /// In vi, this message translates to:
  /// **'Mạng lưới'**
  String get navNetwork;

  /// Bottom nav label
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get navSettings;

  /// Bluetooth powered on badge
  ///
  /// In vi, this message translates to:
  /// **'BT On'**
  String get btOn;

  /// Bluetooth powered off
  ///
  /// In vi, this message translates to:
  /// **'Tắt'**
  String get btOff;

  /// Bluetooth unauthorized
  ///
  /// In vi, this message translates to:
  /// **'Chưa cấp quyền'**
  String get btUnauthorized;

  /// Bluetooth unsupported
  ///
  /// In vi, this message translates to:
  /// **'Không hỗ trợ'**
  String get btUnsupported;

  /// Title of the Chats tab header
  ///
  /// In vi, this message translates to:
  /// **'BLE Mesh Chat'**
  String get chatsHeaderTitle;

  /// Button label to rename device
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên'**
  String get chatsRename;

  /// Empty chats state heading
  ///
  /// In vi, this message translates to:
  /// **'Chưa có cuộc trò chuyện'**
  String get chatsEmptyTitle;

  /// Empty chats state subtitle
  ///
  /// In vi, this message translates to:
  /// **'Vào tab Network để tìm và kết nối với điện thoại gần đây.'**
  String get chatsEmptySubtitle;

  /// Chat list item subtitle when connected but no messages
  ///
  /// In vi, this message translates to:
  /// **'Connected • direct BLE'**
  String get chatsConnectedBle;

  /// Last message preview prefix for own messages
  ///
  /// In vi, this message translates to:
  /// **'Bạn: {text}'**
  String chatsMine(String text);

  /// Button to open chat screen
  ///
  /// In vi, this message translates to:
  /// **'Mở chat'**
  String get chatsOpenChat;

  /// Button to open chat screen with unread count
  ///
  /// In vi, this message translates to:
  /// **'Mở chat  •  {count} tin mới'**
  String chatsOpenChatUnread(int count);

  /// Snackbar fallback sender name
  ///
  /// In vi, this message translates to:
  /// **'Tin nhắn mới'**
  String get newMessage;

  /// Snackbar action label
  ///
  /// In vi, this message translates to:
  /// **'Xem'**
  String get snackView;

  /// Nodes tab title
  ///
  /// In vi, this message translates to:
  /// **'Nodes'**
  String get nodesHeaderTitle;

  /// Nodes tab subtitle
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị BLE đã kết nối / nhìn thấy'**
  String get nodesHeaderSubtitle;

  /// Tag when device is advertising
  ///
  /// In vi, this message translates to:
  /// **'Advertising'**
  String get nodesTagAdvertising;

  /// Tag when device is offline
  ///
  /// In vi, this message translates to:
  /// **'Offline'**
  String get nodesTagOffline;

  /// Tag when peer is connected
  ///
  /// In vi, this message translates to:
  /// **'Connected'**
  String get nodesTagConnected;

  /// Legend text below node list
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị của bạn sẽ xuất hiện với tên trên cho mọi người trong vùng BLE.'**
  String get nodesLegend;

  /// Fallback peer name
  ///
  /// In vi, this message translates to:
  /// **'Peer'**
  String get nodesPeer;

  /// Network tab title
  ///
  /// In vi, this message translates to:
  /// **'Mạng lưới'**
  String get networkHeaderTitle;

  /// Network subtitle while scanning
  ///
  /// In vi, this message translates to:
  /// **'Đang quét  •  {count} thiết bị'**
  String networkScanningSubtitle(int count);

  /// Network subtitle when not scanning
  ///
  /// In vi, this message translates to:
  /// **'Tìm điện thoại quảng bá BLE Mesh'**
  String get networkIdleSubtitle;

  /// Start scan button label
  ///
  /// In vi, this message translates to:
  /// **'Quét'**
  String get networkScanStart;

  /// Stop scan button label
  ///
  /// In vi, this message translates to:
  /// **'Dừng'**
  String get networkScanStop;

  /// Empty network state heading
  ///
  /// In vi, this message translates to:
  /// **'Chưa thấy thiết bị nào'**
  String get networkEmptyTitle;

  /// Network scanning heading
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm kiếm…'**
  String get networkScanningTitle;

  /// Empty network hint text
  ///
  /// In vi, this message translates to:
  /// **'Điện thoại kia phải cài app này, bật Bluetooth và đang quảng bá BLE Mesh.'**
  String get networkEmptyHint;

  /// Start scan filled button label
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu quét'**
  String get networkStartScan;

  /// RSSI strong label
  ///
  /// In vi, this message translates to:
  /// **'Mạnh'**
  String get networkSignalStrong;

  /// RSSI medium label
  ///
  /// In vi, this message translates to:
  /// **'Trung bình'**
  String get networkSignalMedium;

  /// RSSI weak label
  ///
  /// In vi, this message translates to:
  /// **'Yếu'**
  String get networkSignalWeak;

  /// Connect button label
  ///
  /// In vi, this message translates to:
  /// **'Kết nối'**
  String get networkConnect;

  /// Connecting state button label
  ///
  /// In vi, this message translates to:
  /// **'Đang kết nối…'**
  String get networkConnecting;

  /// Open chat button in network card
  ///
  /// In vi, this message translates to:
  /// **'Chat'**
  String get networkOpenChat;

  /// Chat appbar connected status
  ///
  /// In vi, this message translates to:
  /// **'Connected via BLE'**
  String get chatConnected;

  /// Chat appbar disconnected status
  ///
  /// In vi, this message translates to:
  /// **'Disconnected'**
  String get chatDisconnected;

  /// Empty chat heading
  ///
  /// In vi, this message translates to:
  /// **'Say hi to {name}!'**
  String chatEmptyTitle(String name);

  /// Empty chat subtitle
  ///
  /// In vi, this message translates to:
  /// **'Tin nhắn gửi trực tiếp qua BLE,\nkhông qua internet.'**
  String get chatEmptySubtitle;

  /// Disconnected banner inside chat
  ///
  /// In vi, this message translates to:
  /// **'Đã mất kết nối BLE'**
  String get chatDisconnectedBanner;

  /// Message input placeholder
  ///
  /// In vi, this message translates to:
  /// **'Nhắn tin…'**
  String get chatInputHint;

  /// Message input placeholder when disconnected
  ///
  /// In vi, this message translates to:
  /// **'Không có kết nối'**
  String get chatInputDisabledHint;

  /// Connection request dialog title
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu kết nối'**
  String get connectionRequestTitle;

  /// Connection request dialog body suffix
  ///
  /// In vi, this message translates to:
  /// **' muốn kết nối để chat qua BLE.'**
  String get connectionRequestBody;

  /// Accept button
  ///
  /// In vi, this message translates to:
  /// **'Chấp nhận'**
  String get connectionRequestAccept;

  /// Reject button
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get connectionRequestReject;

  /// Edit name dialog title
  ///
  /// In vi, this message translates to:
  /// **'Tên trong Mesh'**
  String get editNameTitle;

  /// Edit name dialog subtitle
  ///
  /// In vi, this message translates to:
  /// **'Hiển thị với người kết nối'**
  String get editNameSubtitle;

  /// Edit name text field placeholder
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: iPhone của Nam'**
  String get editNameHint;

  /// Cancel button
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get editNameCancel;

  /// Save button
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get editNameSave;

  /// Settings tab title
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// Settings tab subtitle
  ///
  /// In vi, this message translates to:
  /// **'Tùy chỉnh thiết bị và kết nối'**
  String get settingsSubtitle;

  /// Settings section header
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị của bạn'**
  String get settingsSectionDevice;

  /// Settings section header
  ///
  /// In vi, this message translates to:
  /// **'Bluetooth'**
  String get settingsSectionBluetooth;

  /// Settings section header
  ///
  /// In vi, this message translates to:
  /// **'Thông tin'**
  String get settingsSectionAbout;

  /// Edit display name tile title
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên hiển thị'**
  String get settingsEditName;

  /// Edit display name tile subtitle
  ///
  /// In vi, this message translates to:
  /// **'Tên sẽ được gửi đến người kết nối'**
  String get settingsEditNameSub;

  /// Bluetooth status tile title
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái Bluetooth'**
  String get settingsBtStatus;

  /// Advertising tile title
  ///
  /// In vi, this message translates to:
  /// **'Quảng bá (Advertising)'**
  String get settingsAdvertising;

  /// Advertising on subtitle
  ///
  /// In vi, this message translates to:
  /// **'Đang phát tín hiệu BLE Mesh'**
  String get settingsAdvertisingOn;

  /// Advertising off subtitle
  ///
  /// In vi, this message translates to:
  /// **'Không phát tín hiệu'**
  String get settingsAdvertisingOff;

  /// Connection status tile title
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái kết nối'**
  String get settingsConnection;

  /// Connected with peer subtitle
  ///
  /// In vi, this message translates to:
  /// **'Đang kết nối với {name}'**
  String settingsConnectedWith(String name);

  /// Not connected subtitle
  ///
  /// In vi, this message translates to:
  /// **'Chưa kết nối'**
  String get settingsNotConnected;

  /// Disconnect button
  ///
  /// In vi, this message translates to:
  /// **'Ngắt'**
  String get settingsDisconnect;

  /// Version tile title
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản'**
  String get settingsVersion;

  /// Protocol tile title
  ///
  /// In vi, this message translates to:
  /// **'Giao thức'**
  String get settingsProtocol;

  /// Protocol tile subtitle
  ///
  /// In vi, this message translates to:
  /// **'BLE Mesh — direct P2P, không internet'**
  String get settingsProtocolSub;

  /// Security tile title
  ///
  /// In vi, this message translates to:
  /// **'Bảo mật'**
  String get settingsSecurity;

  /// Security tile subtitle
  ///
  /// In vi, this message translates to:
  /// **'Tin nhắn chỉ truyền trong phạm vi BLE'**
  String get settingsSecuritySub;

  /// Language tile title
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get settingsLanguage;

  /// Language section header
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get settingsSectionLanguage;

  /// Vietnamese language option
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get langVietnamese;

  /// English language option
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// Follow system locale option
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get langSystemDefault;

  /// Privacy section header
  ///
  /// In vi, this message translates to:
  /// **'Quyền riêng tư & Bảo mật'**
  String get settingsSectionPrivacy;

  /// Blocked devices tile title
  ///
  /// In vi, this message translates to:
  /// **'Danh sách chặn'**
  String get settingsBlockedDevices;

  /// Blocked devices tile subtitle
  ///
  /// In vi, this message translates to:
  /// **'Quản lý thiết bị đã ẩn và tin nhắn bị chặn'**
  String get settingsBlockedDevicesSub;

  /// Blocked devices sheet title
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị đã chặn'**
  String get blockedDevicesTitle;

  /// Empty blocked devices title
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thiết bị nào bị chặn'**
  String get blockedDevicesEmpty;

  /// Empty blocked devices hint
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị bị chặn sẽ không xuất hiện khi quét và không thể gửi tin nhắn hoặc yêu cầu kết nối.'**
  String get blockedDevicesEmptyHint;

  /// Block device action
  ///
  /// In vi, this message translates to:
  /// **'Chặn thiết bị'**
  String get blockDevice;

  /// Unblock device action
  ///
  /// In vi, this message translates to:
  /// **'Bỏ chặn'**
  String get unblockDevice;

  /// Block confirmation title
  ///
  /// In vi, this message translates to:
  /// **'Chặn {name}?'**
  String blockConfirmTitle(String name);

  /// Block confirmation message
  ///
  /// In vi, this message translates to:
  /// **'Bạn sẽ không nhìn thấy {name} trong danh sách mạng và không nhận tin nhắn hoặc yêu cầu kết nối từ thiết bị này.'**
  String blockConfirmMessage(String name);

  /// Block confirm button label
  ///
  /// In vi, this message translates to:
  /// **'Chặn'**
  String get blockAction;

  /// Unblock confirm button label
  ///
  /// In vi, this message translates to:
  /// **'Bỏ chặn'**
  String get unblockAction;

  /// Snackbar after blocking a device
  ///
  /// In vi, this message translates to:
  /// **'Đã chặn {name}'**
  String deviceBlockedSnack(String name);

  /// Snackbar after unblocking a device
  ///
  /// In vi, this message translates to:
  /// **'Đã bỏ chặn {name}'**
  String deviceUnblockedSnack(String name);
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'vi':
      return AppL10nVi();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'services/ble_chat_v10.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeshChatV10App());
}

class MeshChatV10App extends StatelessWidget {
  const MeshChatV10App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BLE Mesh Chat v10',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final BleChatV10Controller ble;
  StreamSubscription? _requestSub;
  StreamSubscription? _messageSub;
  int tab = 0;

  @override
  void initState() {
    super.initState();
    ble = BleChatV10Controller();
    ble.addListener(_refresh);
    _init();
  }

  Future<void> _init() async {
    await ble.init();
    await ble.startAdvertising();
    _requestSub = ble.incomingRequests.listen((request) {
      debugPrint('[UI] incomingRequests event: ${request.remoteName}');
      if (!mounted) return;
      _showIncomingRequest(request);
    });
    _messageSub = ble.incomingMessages.listen((message) {
      if (!mounted) return;
      if (!ble.isChatOpen) {
        _showInAppNotification(message);
      }
    });
    if (mounted) setState(() {});
  }

  void _refresh() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _showInAppNotification(V10ChatMessage message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.chat_bubble,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ble.connectedName ?? 'Tin nhắn mới',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Xem',
          textColor: Theme.of(context).colorScheme.inversePrimary,
          onPressed: () {
            final peer = ble.connectedName;
            if (peer != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(ble: ble, peerName: peer),
                ),
              );
            }
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _showIncomingRequest(IncomingConnectionRequest request) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Yêu cầu kết nối'),
        content: Text(
          '${request.remoteName} muốn kết nối với thiết bị này để chat qua BLE.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Từ chối'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Chấp nhận'),
          ),
        ],
      ),
    );
    await ble.respondToIncomingRequest(
      request: request,
      accepted: accepted == true,
    );
    if (accepted == true && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(ble: ble, peerName: request.remoteName),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: tab,
          children: [
            _ChatsTab(ble: ble),
            _NodesTab(ble: ble),
            _NetworkTab(ble: ble),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: ble.unreadCount > 0,
              label: Text('${ble.unreadCount}'),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: ble.unreadCount > 0,
              label: Text('${ble.unreadCount}'),
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Chats',
          ),
          const NavigationDestination(
            icon: Icon(Icons.devices_outlined),
            selectedIcon: Icon(Icons.devices),
            label: 'Nodes',
          ),
          const NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub),
            label: 'Network',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _requestSub?.cancel();
    _messageSub?.cancel();
    ble.removeListener(_refresh);
    ble.dispose();
    super.dispose();
  }
}

class _ChatsTab extends StatelessWidget {
  final BleChatV10Controller ble;
  const _ChatsTab({required this.ble});

  @override
  Widget build(BuildContext context) {
    final peer = ble.connectedName;
    final lastMessage = ble.messages.isNotEmpty ? ble.messages.last : null;
    return Column(
      children: [
        _Header(
          title: 'BLE Mesh Chat',
          subtitle: '${ble.nodeName}  •  ${ble.bluetoothState.name}',
          actions: [
            IconButton(
              tooltip: 'Đổi tên node',
              onPressed: () => _editName(context),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const Divider(height: 1),
        if (peer != null)
          ListTile(
            leading: Stack(
              children: [
                const CircleAvatar(child: Icon(Icons.bluetooth_connected)),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    peer,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (lastMessage != null)
                  Text(
                    '${lastMessage.time.hour.toString().padLeft(2, '0')}:${lastMessage.time.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
            subtitle: Text(
              lastMessage != null
                  ? (lastMessage.mine
                        ? 'Bạn: ${lastMessage.text}'
                        : lastMessage.text)
                  : 'Connected • direct BLE',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ble.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${ble.unreadCount}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Ngắt kết nối',
                  onPressed: ble.disconnect,
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(ble: ble, peerName: peer),
              ),
            ),
          )
        else
          const Expanded(
            child: Center(
              child: Text(
                'Chưa kết nối. Vào Network để tìm điện thoại gần đây.',
              ),
            ),
          ),
        if (peer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(ble: ble, peerName: peer),
                ),
              ),
              icon: Badge(
                isLabelVisible: ble.unreadCount > 0,
                label: Text('${ble.unreadCount}'),
                child: const Icon(Icons.chat),
              ),
              label: Text(
                ble.unreadCount > 0
                    ? 'Mở chat (${ble.unreadCount} tin mới)'
                    : 'Mở chat',
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _editName(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initialName: ble.nodeName),
    );
    if (name != null && name.trim().isNotEmpty) {
      await ble.setNodeName(name.trim());
    }
  }
}

class _EditNameDialog extends StatefulWidget {
  final String initialName;
  const _EditNameDialog({required this.initialName});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tên điện thoại trong Mesh'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 20,
        decoration: const InputDecoration(hintText: 'Ví dụ: Bé Xoong'),
        onSubmitted: (val) => Navigator.pop(context, val),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _NodesTab extends StatelessWidget {
  final BleChatV10Controller ble;
  const _NodesTab({required this.ble});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Header(
          title: 'Nodes',
          subtitle: 'Thiết bị BLE đã kết nối / nhìn thấy',
        ),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: Text(ble.nodeName),
                subtitle: Text('${ble.nodeId} • local advertising'),
                trailing: Icon(
                  ble.advertising ? Icons.visibility : Icons.visibility_off,
                  color: ble.advertising ? Colors.green : Colors.grey,
                ),
              ),
              if (ble.connected)
                ListTile(
                  leading: const Icon(
                    Icons.bluetooth_connected,
                    color: Colors.green,
                  ),
                  title: Text(ble.connectedName ?? 'Peer'),
                  subtitle: Text(ble.connectedNodeId ?? 'Connected'),
                  trailing: const Text('CONNECTED'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NetworkTab extends StatelessWidget {
  final BleChatV10Controller ble;
  const _NetworkTab({required this.ble});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(
          title: 'Network',
          subtitle: ble.scanning
              ? 'Đang quét BLE Mesh • ${ble.phones.length} thiết bị'
              : 'Tìm điện thoại đang quảng bá BLE Mesh',
          actions: [
            IconButton(
              tooltip: ble.scanning ? 'Dừng quét' : 'Quét',
              onPressed: ble.scanning ? ble.stopScan : ble.startScan,
              icon: Icon(
                ble.scanning ? Icons.stop_circle_outlined : Icons.refresh,
              ),
            ),
          ],
        ),
        if (ble.error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ble.error!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Đóng',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: ble.clearError,
                ),
              ],
            ),
          ),
        Expanded(
          child: ble.phones.isEmpty
              ? _EmptyNetwork(scanning: ble.scanning)
              : RefreshIndicator(
                  onRefresh: ble.startScan,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                    itemCount: ble.phones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final phone = ble.phones[index];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.smartphone),
                          ),
                          title: Text(phone.name),
                          subtitle: Text(
                            'Bluetooth Mesh • RSSI ${phone.rssi} dBm\n${phone.peripheral.uuid}',
                          ),
                          isThreeLine: true,
                          trailing: FilledButton.tonal(
                            onPressed: phone.connecting
                                ? null
                                : phone.connected
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatPage(
                                        ble: ble,
                                        peerName: phone.name,
                                      ),
                                    ),
                                  )
                                : () => ble.connectTo(phone),
                            child: Text(
                              phone.connected
                                  ? 'Mở chat'
                                  : phone.connecting
                                  ? 'Đang kết nối…'
                                  : 'Kết nối',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _EmptyNetwork extends StatelessWidget {
  final bool scanning;
  const _EmptyNetwork({required this.scanning});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bluetooth_searching,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              scanning ? 'Đang tìm điện thoại…' : 'Chưa thấy điện thoại nào',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Điện thoại kia phải cài app này, bật Bluetooth và đang quảng bá BLE Mesh.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final BleChatV10Controller ble;
  final String peerName;
  const ChatPage({super.key, required this.ble, required this.peerName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final input = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.ble.setChatOpen(true);
    widget.ble.addListener(_refresh);
  }

  void _refresh() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _send() async {
    final text = input.text.trim();
    if (text.isEmpty) return;
    input.clear();
    await widget.ble.sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.ble.messages;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.peerName),
            Text(
              widget.ble.connected ? '● Connected via BLE' : '○ Disconnected',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('Bắt đầu cuộc trò chuyện'))
                : ListView.builder(
                    reverse: false,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final message = messages[index];
                      return Align(
                        alignment: message.mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: const BoxConstraints(maxWidth: 310),
                          decoration: BoxDecoration(
                            color: message.mine
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: message.mine
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(message.text),
                              const SizedBox(height: 4),
                              Text(
                                _time(message.time),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      enabled: widget.ble.connected,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.ble.connected ? _send : null,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    widget.ble.setChatOpen(false);
    widget.ble.removeListener(_refresh);
    input.dispose();
    super.dispose();
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const _Header({
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: actions.isEmpty
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: actions),
    );
  }
}

# BLE Mesh Chat v9 — Realistic Chat App

v9 turns the v8 mesh engine into a chat-oriented application architecture.

## User experience

```text
BLE Mesh
├── Chats
│   ├── Node D
│   ├── Node C
│   └── Node B
│
├── Nodes
│   ├── connected
│   └── offline
│
└── Network
    ├── routes
    ├── hop count
    └── connectivity
```

A chat message has:

```text
QUEUED
  ↓
SENDING
  ↓
SENT
  ↓
DELIVERED

or

FAILED
```

## Architecture

```text
Flutter UI
   ↓
ChatService
   ↓
Message repository / Outbox
   ↓
MeshV8Engine
   ↓
RouteTable + AckTracker + Reassembly
   ↓
PeerSessionManager
   ↓
BLE GATT
```

The UI does not call BLE directly.

Example:

```dart
await chatService.sendMessage(
  peerId: 'NODE-D',
  text: 'Hello D',
);
```

## v9 features

- Chat list
- Chat detail screen
- Message composer
- Message status icons
- Nodes screen
- Network diagnostics screen
- Chat service abstraction
- Conversation/message models
- Existing bidirectional mesh routing
- End-to-end ACK
- Retry tracker
- Route advertisements
- Reverse-route learning

## Important next implementation

The v9 UI is a working shell and the service boundary is established, but persistent SQLite outbox/history should be wired into `ChatService` before treating it as a production chat app.

Recommended v10:

1. SQLite message history
2. persistent outbox
3. automatic retry after app restart
4. delivered/read receipts
5. typing indicator
6. presence
7. contact/node identity
8. image/file messages
9. real MTU fragmentation
10. background BLE lifecycle

## Test

```bash
flutter pub get
flutter test
flutter run
```

Use physical phones for BLE.

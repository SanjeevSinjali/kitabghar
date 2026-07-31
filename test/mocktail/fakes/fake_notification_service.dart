import 'package:kitabghar/core/services/notifications/notification_service.dart';

/// In-memory stand-in for NotificationService so widget tests don't need
/// Hive initialized. Overrides every method NotificationsNotifier calls.
class FakeNotificationService extends NotificationService {
  final Map<String, List<NotificationRecord>> _store = {};

  @override
  Future<void> init() async {}

  @override
  List<NotificationRecord> getFor(String email) => _store[email] ?? [];

  @override
  Future<void> addFor(String email, NotificationRecord item) async {
    final list = _store.putIfAbsent(email, () => []);
    list.insert(0, item);
  }

  @override
  Future<void> markAllReadFor(String email) async {
    _store[email] =
        getFor(email).map((n) => n.copyWith(isRead: true)).toList();
  }

  @override
  Future<void> markAsReadFor(String email, String id) async {
    _store[email] = getFor(email)
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
  }

  @override
  bool hasNotificationOfType(String email, String type) =>
      getFor(email).any((n) => n.type == type);
}

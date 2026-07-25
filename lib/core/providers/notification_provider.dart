import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/services/notifications/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError(
    'notificationServiceProvider must be overridden in main.dart after NotificationService().init()',
  );
});

/// Holds the notification list for whichever user is currently logged in.
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationRecord>>(
  (ref) => NotificationsNotifier(ref.read(notificationServiceProvider)),
);

/// Convenience: number of unread notifications for the badge on the bell icon.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

class NotificationsNotifier extends StateNotifier<List<NotificationRecord>> {
  final NotificationService _service;
  String? _currentEmail;

  NotificationsNotifier(this._service) : super([]);

  void loadForUser(String email) {
    _currentEmail = email;
    state = _service.getFor(email);
  }

  void clear() {
    _currentEmail = null;
    state = [];
  }

  /// Called after a successful login OR registration. Loads this user's
  /// notification history, and — if they've never had a welcome
  /// notification before (whether brand new or an existing user who
  /// predates this feature) — adds exactly one.
  Future<void> onUserAuthenticated(String email) async {
    loadForUser(email);
    if (_service.hasNotificationOfType(email, 'welcome')) return;

    final welcome = NotificationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Welcome to Kitabghar!',
      message: 'Start exploring books from sellers near you.',
      time: DateTime.now(),
      type: 'welcome',
    );
    await _service.addFor(email, welcome);
    if (_currentEmail == email) {
      state = _service.getFor(email);
    }
  }

  Future<void> markAllRead() async {
    final email = _currentEmail;
    if (email == null) return;
    await _service.markAllReadFor(email);
    state = _service.getFor(email);
  }

  Future<void> markAsRead(String id) async {
    final email = _currentEmail;
    if (email == null) return;
    await _service.markAsReadFor(email, id);
    state = _service.getFor(email);
  }

  /// General-purpose way to add a notification for events like
  /// "profile updated", "listing approved", etc. Reuse this for any
  /// future in-app event that should notify the user.
  Future<void> addNotification(
    String email, {
    required String title,
    required String message,
    required String type,
  }) async {
    final record = NotificationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      time: DateTime.now(),
      type: type,
    );
    await _service.addFor(email, record);
    if (_currentEmail == email) {
      state = _service.getFor(email);
    }
  }
}
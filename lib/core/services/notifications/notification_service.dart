import 'package:hive_flutter/hive_flutter.dart';

/// A single notification. Stored as a plain Map in Hive (no generated
/// adapter needed) so it's easy to evolve later.
///
/// [type] is a short string key (e.g. 'welcome', 'order') used purely to
/// pick an icon in the UI layer — keeps this model free of Flutter imports.
class NotificationRecord {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final String type;
  final bool isRead;

  const NotificationRecord({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  NotificationRecord copyWith({bool? isRead}) => NotificationRecord(
        id: id,
        title: title,
        message: message,
        time: time,
        type: type,
        isRead: isRead ?? this.isRead,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'message': message,
        'time': time.toIso8601String(),
        'type': type,
        'isRead': isRead,
      };

  factory NotificationRecord.fromMap(Map map) => NotificationRecord(
        id: map['id'] as String,
        title: map['title'] as String,
        message: map['message'] as String,
        time: DateTime.parse(map['time'] as String),
        type: map['type'] as String,
        isRead: map['isRead'] as bool? ?? false,
      );
}

/// Persists notifications per user (keyed by email) in Hive, so history
/// survives app restarts and is kept separate between accounts.
class NotificationService {
  static const String _boxName = 'notifications_box';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  Box get _box => Hive.box(_boxName);

  List<NotificationRecord> getFor(String email) {
    final raw = _box.get(email) as List?;
    if (raw == null) return [];
    return raw
        .map((e) => NotificationRecord.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _saveFor(String email, List<NotificationRecord> items) async {
    await _box.put(email, items.map((e) => e.toMap()).toList());
  }

  Future<void> addFor(String email, NotificationRecord item) async {
    final items = getFor(email);
    items.insert(0, item);
    await _saveFor(email, items);
  }

  Future<void> markAllReadFor(String email) async {
    final items = getFor(email).map((n) => n.copyWith(isRead: true)).toList();
    await _saveFor(email, items);
  }

  Future<void> markAsReadFor(String email, String id) async {
    final items = getFor(email)
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    await _saveFor(email, items);
  }

  /// True if this user has ever received a notification of [type].
  /// Used to make sure the welcome notification is only ever added once,
  /// whether the user just registered or is an existing user logging in
  /// for the first time since this feature was added.
  bool hasNotificationOfType(String email, String type) {
    return getFor(email).any((n) => n.type == type);
  }
}
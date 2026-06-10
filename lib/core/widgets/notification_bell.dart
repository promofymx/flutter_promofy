import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../data/repositories/notifications_inbox_repository.dart';
import '../../features/notifications/screens/notifications_screen.dart';

/// Campana de notificaciones con badge de no-leídos.
class NotificationBell extends StatefulWidget {
  final Color color;
  const NotificationBell({super.key, this.color = AppColors.textDark});
  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _repo = NotificationsInboxRepository();
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await _repo.unreadCount();
    if (mounted) setState(() => _unread = n);
  }

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    _load(); // refrescar el contador al volver
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: widget.color),
          onPressed: _open,
        ),
        if (_unread > 0)
          Positioned(
            right: 6, top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                _unread > 9 ? '9+' : '$_unread',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

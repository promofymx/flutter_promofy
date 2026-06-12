import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_notification_model.dart';
import '../../../data/repositories/notifications_inbox_repository.dart';

/// Centro de notificaciones in-app (lo abre la campanita).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repo = NotificationsInboxRepository();
  late Future<List<UserNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getNotifications();
  }

  Future<void> _reload() async {
    setState(() => _future = _repo.getNotifications());
  }

  Future<void> _markAll() async {
    await _repo.markAllRead();
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        title: const Text('Notificaciones',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _markAll,
            child: const Text('Marcar todas',
                style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _reload,
        child: FutureBuilder<List<UserNotification>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Icon(Icons.notifications_none, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Center(child: Text('No tienes notificaciones todavía.',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500))),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, i) => _NotifTile(
                notif: items[i],
                onTap: () async {
                  final n = items[i];
                  if (!n.isRead) {
                    await _repo.markRead(n.id);
                    await _reload();
                  }
                  // Abrir la promo o el establecimiento correspondiente.
                  await NotificationService.instance
                      .navigateFromData(n.type, n.data);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final UserNotification notif;
  final VoidCallback     onTap;
  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = !notif.isRead;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread ? AppColors.primary.withAlpha(10) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _color(notif.type).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(_emoji(notif.type), style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: unread ? FontWeight.bold : FontWeight.w600,
                        color: AppColors.textDark,
                      )),
                  if (notif.body != null && notif.body!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(notif.body!,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3)),
                  ],
                  const SizedBox(height: 4),
                  Text(_timeAgo(notif.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
            if (unread)
              Container(
                margin: const EdgeInsets.only(top: 4, left: 6),
                width: 9, height: 9,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  static String _emoji(String? t) {
    switch (t) {
      case 'flash_promo':   return '⚡';
      case 'new_promo':     return '🏷️';
      case 'ad':            return '📣';
      case 'loyalty_stamp': return '🎁';
      case 'broadcast':     return '📢';
      default:              return '🔔';
    }
  }

  static Color _color(String? t) {
    switch (t) {
      case 'flash_promo':   return Colors.amber;
      case 'ad':            return Colors.blue;
      case 'loyalty_stamp': return Colors.green;
      default:              return AppColors.primary;
    }
  }

  static String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1)  return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours   < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays    < 7)  return 'Hace ${diff.inDays} d';
    return '${d.day}/${d.month}/${d.year}';
  }
}

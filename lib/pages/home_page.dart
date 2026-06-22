import 'package:flutter/material.dart';

import '../models/medicine_reminder.dart';
import '../services/notification_service.dart';
import '../services/reminder_storage.dart';
import '../widgets/empty_state.dart';
import '../widgets/reminder_card.dart';
import '../widgets/reminder_dialog.dart';
import '../widgets/summary_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MedicineReminder> _reminders = [];
  bool _loading = true;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await NotificationService.instance.init();
      final items = await ReminderStorage.load();
      if (!mounted) return;
      setState(() {
        _reminders = items;
        _loading = false;
      });
      await NotificationService.instance.syncAll(items);
    } catch (_) {
      final items = await ReminderStorage.load();
      if (!mounted) return;
      setState(() {
        _reminders = items;
        _loading = false;
      });
    }
  }

  Future<void> _persistAndSync() async {
    if (!mounted) return;
    setState(() => _syncing = true);
    await ReminderStorage.save(_reminders);
    await NotificationService.instance.syncAll(_reminders);
    if (!mounted) return;
    setState(() => _syncing = false);
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _dayName(int weekday) {
    const names = ['', 'Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];
    return names[weekday];
  }

  String _daysLabel(List<int> days) {
    if (days.length == 7) return 'Codziennie';
    final ordered = [...days]..sort();
    return ordered.map(_dayName).join(', ');
  }

  bool _isDueToday(MedicineReminder item) {
    final now = DateTime.now();
    return item.enabled && item.days.contains(now.weekday);
  }

  bool _isTakenToday(MedicineReminder item) {
    return item.takenOn.contains(_dateKey(DateTime.now()));
  }

  List<MedicineReminder> _todayItems() {
    final list = _reminders.where(_isDueToday).toList();
    list.sort((a, b) {
      final aa = a.hour * 60 + a.minute;
      final bb = b.hour * 60 + b.minute;
      return aa.compareTo(bb);
    });
    return list;
  }

  Future<void> _addOrEdit({MedicineReminder? existing}) async {
    final result = await showDialog<MedicineReminder>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ReminderDialog(existing: existing),
    );

    if (result == null) return;

    setState(() {
      if (existing == null) {
        _reminders.add(result);
      } else {
        final index = _reminders.indexWhere((e) => e.id == existing.id);
        if (index != -1) _reminders[index] = result;
      }
    });

    await _persistAndSync();
  }

  Future<void> _deleteReminder(MedicineReminder item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Usuń przypomnienie?'),
        content: Text('Czy na pewno chcesz usunąć: ${item.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anuluj')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Usuń')),
        ],
      ),
    );
    if (confirm != true) return;

    await NotificationService.instance.cancel(item);
    setState(() {
      _reminders.removeWhere((e) => e.id == item.id);
    });
    await _persistAndSync();
  }

  Future<void> _toggleTaken(MedicineReminder item) async {
    final today = _dateKey(DateTime.now());
    final updated = item.takenOn.contains(today)
        ? item.copyWith(takenOn: [...item.takenOn]..removeWhere((d) => d == today))
        : item.copyWith(takenOn: [...item.takenOn, today]);

    setState(() {
      final index = _reminders.indexWhere((e) => e.id == item.id);
      if (index != -1) _reminders[index] = updated;
    });
    await _persistAndSync();
  }

  Future<void> _toggleEnabled(MedicineReminder item, bool value) async {
    setState(() {
      final index = _reminders.indexWhere((e) => e.id == item.id);
      if (index != -1) _reminders[index] = item.copyWith(enabled: value);
    });
    await _persistAndSync();
  }

  @override
  Widget build(BuildContext context) {
    final todayItems = _todayItems();
    final upcoming = [..._reminders]
      ..sort((a, b) {
        final aa = a.hour * 60 + a.minute;
        final bb = b.hour * 60 + b.minute;
        return aa.compareTo(bb);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('MedReminder'),
        actions: [
          if (_syncing)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          IconButton(
            onPressed: () async {
              await NotificationService.instance.showTestNotification();
            },
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Test notyfikacji',
          ),
          IconButton(
            onPressed: _bootstrap,
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Dodaj lek'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _bootstrap,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SummaryCard(
                    total: _reminders.length,
                    enabled: _reminders.where((e) => e.enabled).length,
                    today: todayItems.length,
                    takenToday: todayItems.where(_isTakenToday).length,
                  ),
                  const SizedBox(height: 16),
                  const Text('Dzisiejsze dawki', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (todayItems.isEmpty)
                    const EmptyState(
                      icon: Icons.notifications_none,
                      title: 'Brak dawek na dziś',
                      subtitle: 'Dodaj lek i wybierz dni tygodnia.',
                    )
                  else
                    ...todayItems.map(
                      (item) => ReminderCard(
                        item: item,
                        daysLabel: _daysLabel(item.days),
                        isTaken: _isTakenToday(item),
                        onEdit: () => _addOrEdit(existing: item),
                        onDelete: () => _deleteReminder(item),
                        onToggleTaken: () => _toggleTaken(item),
                        onToggleEnabled: (value) => _toggleEnabled(item, value),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text('Wszystkie przypomnienia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (upcoming.isEmpty)
                    const EmptyState(
                      icon: Icons.medication_outlined,
                      title: 'Brak zapisanych leków',
                      subtitle: 'Kliknij „Dodaj lek”, aby rozpocząć.',
                    )
                  else
                    ...upcoming.map(
                      (item) => ReminderCard(
                        item: item,
                        daysLabel: _daysLabel(item.days),
                        isTaken: _isTakenToday(item),
                        onEdit: () => _addOrEdit(existing: item),
                        onDelete: () => _deleteReminder(item),
                        onToggleTaken: () => _toggleTaken(item),
                        onToggleEnabled: (value) => _toggleEnabled(item, value),
                      ),
                    ),
                  const SizedBox(height: 88),
                ],
              ),
            ),
    );
  }
}

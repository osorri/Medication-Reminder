import 'package:flutter/material.dart';
import '../models/medicine_reminder.dart';
import '../services/reminder_storage.dart';

class ReminderDialog extends StatefulWidget {
  final MedicineReminder? existing;

  const ReminderDialog({super.key, this.existing});

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _notesController;
  late TimeOfDay _time;
  late List<bool> _selectedDays;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _dosageController = TextEditingController(text: e?.dosage ?? '');
    _notesController = TextEditingController(text: e?.notes ?? '');
    _time = TimeOfDay(hour: e?.hour ?? 8, minute: e?.minute ?? 0);
    final days = e?.days ?? [1, 2, 3, 4, 5, 6, 7];
    _selectedDays = List.generate(7, (index) => days.contains(index + 1));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Podaj nazwę leku.')));
      return;
    }

    final selectedDays = <int>[];
    for (var i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) selectedDays.add(i + 1);
    }
    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wybierz co najmniej jeden dzień.')));
      return;
    }

    final old = widget.existing;
    final reminder = MedicineReminder(
      id: old?.id ?? await ReminderStorage.nextId(),
      name: name,
      dosage: _dosageController.text.trim(),
      hour: _time.hour,
      minute: _time.minute,
      days: selectedDays,
      notes: _notesController.text.trim(),
      enabled: old?.enabled ?? true,
      takenOn: old?.takenOn ?? [],
    );

    if (mounted) Navigator.pop(context, reminder);
  }

  @override
  Widget build(BuildContext context) {
    final days = const ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];

    return AlertDialog(
      title: Text(widget.existing == null ? 'Dodaj lek' : 'Edytuj lek'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nazwa leku', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dawka / opis', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notatka (opcjonalnie)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('Godzina: ${_time.format(context)}')),
                  OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule),
                    label: const Text('Wybierz'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Dni tygodnia', style: Theme.of(context).textTheme.titleSmall),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  return FilterChip(
                    label: Text(days[index]),
                    selected: _selectedDays[index],
                    onSelected: (value) {
                      setState(() => _selectedDays[index] = value);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
        FilledButton(onPressed: _save, child: const Text('Zapisz')),
      ],
    );
  }
}

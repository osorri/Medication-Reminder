import 'package:flutter/material.dart';
import '../models/medicine_reminder.dart';

class ReminderCard extends StatelessWidget {
  final MedicineReminder item;
  final String daysLabel;
  final bool isTaken;
  final ValueChanged<bool> onToggleEnabled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleTaken;

  const ReminderCard({
    super.key,
    required this.item,
    required this.daysLabel,
    required this.isTaken,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleTaken,
    required this.onToggleEnabled,
  });

  String _timeText() => '${item.hour.toString().padLeft(2, '0')}:${item.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(item.dosage.isEmpty ? 'Brak dawki' : item.dosage),
                    ],
                  ),
                ),
                Chip(label: Text(_timeText())),
              ],
            ),
            const SizedBox(height: 8),
            Text('Dni: $daysLabel'),
            if (item.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Notatka: ${item.notes}'),
            ],
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: item.enabled,
              title: const Text('Aktywne przypomnienie'),
              onChanged: onToggleEnabled,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onToggleTaken,
                  icon: Icon(isTaken ? Icons.check_circle : Icons.check_circle_outline),
                  label: Text(isTaken ? 'Wzięte' : 'Oznacz jako wzięte'),
                ),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edytuj'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Usuń'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

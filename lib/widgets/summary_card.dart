import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final int total;
  final int enabled;
  final int today;
  final int takenToday;

  const SummaryCard({
    super.key,
    required this.total,
    required this.enabled,
    required this.today,
    required this.takenToday,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.health_and_safety)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Podsumowanie', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Wszystkie leki: $total'),
                  Text('Aktywne: $enabled'),
                  Text('Na dziś: $today'),
                  Text('Wzięte dziś: $takenToday'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/features/trip_planner/presentation/widgets/slider_list_tile.dart
import 'package:flutter/material.dart';

class SliderListTile extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  const SliderListTile({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: label,
            onChanged: onChanged,
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

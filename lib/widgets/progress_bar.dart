import 'package:flutter/material.dart';
import 'app_scaffold.dart';

class MultiStepProgress extends StatelessWidget {
  final int step;
  const MultiStepProgress({super.key, required this.step});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(['Basic Information', 'Employment & Classification', 'Compensation & Documents'][step - 1] + ' · Step $step of 3', style: const TextStyle(color: muted, fontSize: 12)),
      const SizedBox(height: 9),
      Row(children: [
        for (var index = 0; index < 3; index++)
          Expanded(child: Container(margin: EdgeInsets.only(right: index == 2 ? 0 : 4), height: 4, decoration: BoxDecoration(color: index < step ? green : const Color(0xFFE1E3E6), borderRadius: BorderRadius.circular(5)))),
      ]),
    ]);
  }
}

import 'package:flutter/material.dart';

class HierarchyPicker extends StatelessWidget {
  final List<String> seriesList;
  final List<String> classList;
  final List<String> subjectList;
  final String selectedSeries;
  final String selectedClass;
  final String selectedSubject;
  final ValueChanged<String> onSeriesChanged;
  final ValueChanged<String> onClassChanged;
  final ValueChanged<String> onSubjectChanged;

  const HierarchyPicker({
    super.key,
    required this.seriesList,
    required this.classList,
    required this.subjectList,
    required this.selectedSeries,
    required this.selectedClass,
    required this.selectedSubject,
    required this.onSeriesChanged,
    required this.onClassChanged,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedSeries,
                decoration: const InputDecoration(labelText: 'Series', border: InputBorder.none),
                items: seriesList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => v != null ? onSeriesChanged(v) : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: const InputDecoration(labelText: 'Class', border: InputBorder.none),
                items: classList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => v != null ? onClassChanged(v) : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: const InputDecoration(labelText: 'Subject', border: InputBorder.none),
                items: subjectList.map((sub) => DropdownMenuItem(value: sub, child: Text(sub))).toList(),
                onChanged: (v) => v != null ? onSubjectChanged(v) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

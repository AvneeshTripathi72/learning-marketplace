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
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedSeries,
                decoration: const InputDecoration(
                  labelText: 'Series',
                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                items: seriesList
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (v) => v != null ? onSeriesChanged(v) : null,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                items: classList
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (v) => v != null ? onClassChanged(v) : null,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                items: subjectList
                    .map((sub) => DropdownMenuItem(
                          value: sub,
                          child: Text(sub, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (v) => v != null ? onSubjectChanged(v) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

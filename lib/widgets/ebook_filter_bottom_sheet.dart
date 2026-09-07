import 'package:flutter/material.dart';

class EBookFilterBottomSheet extends StatefulWidget {
  final String selectedPublication;
  final String selectedSeries;
  final String selectedClass;
  final String selectedSubject;
  final bool freeOnly;
  final Function(String pub, String series, String cls, String subject, bool freeOnly) onApply;

  const EBookFilterBottomSheet({
    super.key,
    required this.selectedPublication,
    required this.selectedSeries,
    required this.selectedClass,
    required this.selectedSubject,
    required this.freeOnly,
    required this.onApply,
  });

  @override
  State<EBookFilterBottomSheet> createState() => _EBookFilterBottomSheetState();
}

class _EBookFilterBottomSheetState extends State<EBookFilterBottomSheet> {
  late String _pub;
  late String _series;
  late String _class;
  late String _subject;
  late bool _freeOnly;

  @override
  void initState() {
    super.initState();
    _pub = widget.selectedPublication;
    _series = widget.selectedSeries;
    _class = widget.selectedClass;
    _subject = widget.selectedSubject;
    _freeOnly = widget.freeOnly;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final inputBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F7);
    final primaryAccent = isDark ? const Color(0xFF7C9CFF) : const Color(0xFF4A6CF7);
    final textPrimary = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Header
            Row(
              children: [
                Icon(Icons.tune_rounded, color: primaryAccent, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Advanced Filter Options',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pub = 'All Publications';
                      _series = 'All';
                      _class = 'All';
                      _subject = 'All';
                      _freeOnly = false;
                    });
                  },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter Options Grid
            DropdownButtonFormField<String>(
              initialValue: ['All Publications', 'Oxford Educational Press', 'Pearson India', 'S. Chand Publishing'].contains(_pub) ? _pub : 'All Publications',
              dropdownColor: sheetBg,
              decoration: InputDecoration(
                labelText: 'Publisher / Brand',
                filled: true,
                fillColor: inputBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: ['All Publications', 'Oxford Educational Press', 'Pearson India', 'S. Chand Publishing']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => val != null ? setState(() => _pub = val) : null,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: ['All', 'CBSE 2026', 'ICSE 2026', 'State Board'].contains(_series) ? _series : 'All',
                    dropdownColor: sheetBg,
                    decoration: InputDecoration(
                      labelText: 'Board / Series',
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: ['All', 'CBSE 2026', 'ICSE 2026', 'State Board']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => val != null ? setState(() => _series = val) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: ['All', 'Class 9', 'Class 10', 'Class 11', 'Class 12'].contains(_class) ? _class : 'All',
                    dropdownColor: sheetBg,
                    decoration: InputDecoration(
                      labelText: 'Grade / Class',
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: ['All', 'Class 9', 'Class 10', 'Class 11', 'Class 12']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => val != null ? setState(() => _class = val) : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: ['All', 'Mathematics', 'Science', 'English', 'Hindi', 'Physics', 'Chemistry'].contains(_subject) ? _subject : 'All',
              dropdownColor: sheetBg,
              decoration: InputDecoration(
                labelText: 'Subject Category',
                filled: true,
                fillColor: inputBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: ['All', 'Mathematics', 'Science', 'English', 'Hindi', 'Physics', 'Chemistry']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => val != null ? setState(() => _subject = val) : null,
            ),
            const SizedBox(height: 14),

            // Free Access Only Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Free Access Only', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: textPrimary)),
              subtitle: Text('Show textbooks accessible without premium subscription', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textSecondary)),
              value: _freeOnly,
              activeTrackColor: primaryAccent,
              onChanged: (val) => setState(() => _freeOnly = val),
            ),
            const SizedBox(height: 20),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  widget.onApply(_pub, _series, _class, _subject, _freeOnly);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Apply Filters', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

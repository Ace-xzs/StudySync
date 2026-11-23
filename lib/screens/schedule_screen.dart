import 'package:flutter/material.dart';

import '../models/class_schedule.dart';
import '../models/subject.dart';
import '../services/id_generator.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({
    required this.ownerId,
    required this.schedules,
    required this.subjects,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    required this.onManageSubjects,
    super.key,
  });

  final String ownerId;
  final List<ClassSchedule> schedules;
  final List<Subject> subjects;
  final Future<void> Function(ClassSchedule schedule) onAdd;
  final Future<void> Function(ClassSchedule schedule) onUpdate;
  final Future<void> Function(ClassSchedule schedule) onDelete;
  final VoidCallback onManageSubjects;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late int _selectedDay;
  bool _showWeekly = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now().weekday;
  }

  @override
  Widget build(BuildContext context) {
    final subjectNames = {
      for (final subject in widget.subjects) subject.id: subject.name,
    };
    final todaysSchedules = _sortedSchedules(
      widget.schedules.where((item) => item.dayOfWeek == _selectedDay),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Class schedule',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF20243A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: widget.subjects.isEmpty ? null : _addSchedule,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add class'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Organize your classes by day and time.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: const Color(0xFF777D90)),
        ),
        const SizedBox(height: 18),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Daily')),
            ButtonSegment(value: true, label: Text('Weekly')),
          ],
          selected: {_showWeekly},
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            setState(() => _showWeekly = selection.first);
          },
        ),
        if (!_showWeekly) ...[
          const SizedBox(height: 18),
          _DaySelector(
            selectedDay: _selectedDay,
            onSelected: (day) => setState(() => _selectedDay = day),
          ),
          const SizedBox(height: 20),
          Text(
            '${_days[_selectedDay - 1]} classes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF20243A),
            ),
          ),
          const SizedBox(height: 12),
          if (todaysSchedules.isEmpty)
            _EmptySchedule(
              hasSubjects: widget.subjects.isNotEmpty,
              onAdd: widget.subjects.isEmpty
                  ? widget.onManageSubjects
                  : _addSchedule,
            )
          else
            ...todaysSchedules.map(
              (schedule) => _ScheduleCard(
                schedule: schedule,
                subjectName:
                    subjectNames[schedule.subjectId] ?? 'Unknown subject',
                onEdit: () => _editSchedule(schedule),
                onDelete: () => _confirmDelete(schedule),
              ),
            ),
        ] else ...[
          const SizedBox(height: 20),
          if (widget.schedules.isEmpty)
            _EmptySchedule(
              hasSubjects: widget.subjects.isNotEmpty,
              onAdd: widget.subjects.isEmpty
                  ? widget.onManageSubjects
                  : _addSchedule,
            )
          else
            ...List.generate(_days.length, (index) {
              final day = index + 1;
              final daySchedules = _sortedSchedules(
                widget.schedules.where((item) => item.dayOfWeek == day),
              );
              if (daySchedules.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 4),
                    child: Text(
                      _days[index],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF20243A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ...daySchedules.map(
                    (schedule) => _ScheduleCard(
                      schedule: schedule,
                      subjectName:
                          subjectNames[schedule.subjectId] ?? 'Unknown subject',
                      onEdit: () => _editSchedule(schedule),
                      onDelete: () => _confirmDelete(schedule),
                    ),
                  ),
                ],
              );
            }),
        ],
      ],
    );
  }

  List<ClassSchedule> _sortedSchedules(Iterable<ClassSchedule> items) {
    return items.toList()..sort(
      (first, second) => first.startMinutes.compareTo(second.startMinutes),
    );
  }

  Future<void> _addSchedule() async {
    final schedule = await showDialog<ClassSchedule>(
      context: context,
      builder: (context) => _ScheduleFormDialog(
        ownerId: widget.ownerId,
        subjects: widget.subjects,
        selectedDay: _selectedDay,
      ),
    );
    if (schedule != null) await widget.onAdd(schedule);
  }

  Future<void> _editSchedule(ClassSchedule schedule) async {
    final updated = await showDialog<ClassSchedule>(
      context: context,
      builder: (context) => _ScheduleFormDialog(
        ownerId: widget.ownerId,
        subjects: widget.subjects,
        selectedDay: _selectedDay,
        existingSchedule: schedule,
      ),
    );
    if (updated != null) await widget.onUpdate(updated);
  }

  Future<void> _confirmDelete(ClassSchedule schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete class schedule?'),
        content: const Text('This class will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.onDelete(schedule);
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.selectedDay, required this.onSelected});

  final int selectedDay;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: List.generate(7, (index) {
        final day = index + 1;
        final selected = day == selectedDay;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 6 ? 0 : 6),
            child: InkWell(
              onTap: () => onSelected(day),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF3446A5) : Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  shortDays[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF777D90),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.subjectName,
    required this.onEdit,
    required this.onDelete,
  });

  final ClassSchedule schedule;
  final String subjectName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(schedule.startMinutes),
              style: const TextStyle(
                color: Color(0xFF3446A5),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              _formatTime(schedule.endMinutes),
              style: const TextStyle(color: Color(0xFF777D90), fontSize: 11),
            ),
          ],
        ),
        title: Text(
          subjectName,
          style: const TextStyle(
            color: Color(0xFF20243A),
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          schedule.classroom.isEmpty ? 'Classroom not set' : schedule.classroom,
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Class actions',
          onSelected: (action) {
            if (action == 'edit') onEdit();
            if (action == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  static String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}

class _ScheduleFormDialog extends StatefulWidget {
  const _ScheduleFormDialog({
    required this.ownerId,
    required this.subjects,
    required this.selectedDay,
    this.existingSchedule,
  });

  final String ownerId;
  final List<Subject> subjects;
  final int selectedDay;
  final ClassSchedule? existingSchedule;

  @override
  State<_ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<_ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _classroomController = TextEditingController();
  late String _subjectId;
  late int _day;
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSchedule;
    _subjectId = existing?.subjectId ?? widget.subjects.first.id;
    _day = existing?.dayOfWeek ?? widget.selectedDay;
    _start = _timeOfDay(existing?.startMinutes ?? 9 * 60);
    _end = _timeOfDay(existing?.endMinutes ?? 10 * 60);
    _classroomController.text = existing?.classroom ?? '';
  }

  @override
  void dispose() {
    _classroomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existingSchedule;
    return AlertDialog(
      title: Text(existing == null ? 'Add class' : 'Edit class'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _subjectId,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                items: widget.subjects
                    .map(
                      (subject) => DropdownMenuItem(
                        value: subject.id,
                        child: Text(subject.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _subjectId = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _day,
                decoration: const InputDecoration(
                  labelText: 'Day',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  7,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(_dayName(index + 1)),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) setState(() => _day = value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimeButton(
                      label: 'Starts',
                      value: _formatTime(_start),
                      onTap: () => _selectTime(start: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TimeButton(
                      label: 'Ends',
                      value: _formatTime(_end),
                      onTap: () => _selectTime(start: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _classroomController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Classroom',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(existing == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _selectTime({required bool start}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (selected == null) return;
    setState(() {
      if (start) {
        _start = selected;
      } else {
        _end = selected;
      }
    });
  }

  void _save() {
    final startMinutes = _start.hour * 60 + _start.minute;
    final endMinutes = _end.hour * 60 + _end.minute;
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }

    final existing = widget.existingSchedule;
    Navigator.pop(
      context,
      ClassSchedule(
        id: existing?.id ?? newRecordId(),
        ownerId: widget.ownerId,
        subjectId: _subjectId,
        dayOfWeek: _day,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        classroom: _classroomController.text.trim(),
      ),
    );
  }

  TimeOfDay _timeOfDay(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  String _formatTime(TimeOfDay time) => time.format(context);

  String _dayName(int day) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][day - 1];
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule({required this.hasSubjects, required this.onAdd});

  final bool hasSubjects;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 38),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 46,
            color: Color(0xFF6678D9),
          ),
          const SizedBox(height: 12),
          Text(
            hasSubjects
                ? 'No classes scheduled for this day'
                : 'Add a subject first',
            style: const TextStyle(
              color: Color(0xFF777D90),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(hasSubjects ? 'Add a class' : 'Manage subjects'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/class_schedule.dart';
import '../models/subject.dart';
import '../services/id_generator.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({
    required this.ownerId,
    required this.subjects,
    required this.schedules,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    super.key,
  });

  final String ownerId;
  final List<Subject> subjects;
  final List<ClassSchedule> schedules;
  final Future<void> Function(Subject subject) onAdd;
  final Future<void> Function(Subject subject) onUpdate;
  final Future<void> Function(Subject subject) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Subjects',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF20243A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _editSubject(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add subject'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Manage the subjects you are enrolled in.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: const Color(0xFF777D90)),
        ),
        const SizedBox(height: 18),
        if (subjects.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 38),
            child: Column(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  size: 46,
                  color: Color(0xFF6678D9),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No subjects added yet',
                  style: TextStyle(
                    color: Color(0xFF777D90),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _editSubject(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add your first subject'),
                ),
              ],
            ),
          )
        else
          ...subjects.map((subject) {
            final classCount = schedules
                .where((schedule) => schedule.subjectId == subject.id)
                .length;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE9ECFC),
                  child: Text(
                    subject.name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF3446A5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  subject.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '$classCount ${classCount == 1 ? 'class' : 'classes'} scheduled',
                ),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Subject actions',
                  onSelected: (action) {
                    if (action == 'edit') _editSubject(context, subject);
                    if (action == 'delete') _confirmDelete(context, subject);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _editSubject(BuildContext context, [Subject? existing]) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _SubjectFormDialog(existingName: existing?.name),
    );
    if (name == null) return;

    if (existing == null) {
      await onAdd(Subject(id: newRecordId(), ownerId: ownerId, name: name));
    } else {
      await onUpdate(existing.copyWith(name: name));
    }
  }

  Future<void> _confirmDelete(BuildContext context, Subject subject) async {
    final linkedCount = schedules
        .where((schedule) => schedule.subjectId == subject.id)
        .length;
    final detail = linkedCount == 0
        ? 'This subject will be permanently removed.'
        : 'This subject and its $linkedCount ${linkedCount == 1 ? 'class schedule' : 'class schedules'} will be permanently removed.';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete subject?'),
        content: Text(detail),
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
    if (confirmed == true) await onDelete(subject);
  }
}

class _SubjectFormDialog extends StatefulWidget {
  const _SubjectFormDialog({this.existingName});

  final String? existingName;

  @override
  State<_SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<_SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existingName != null;
    return AlertDialog(
      title: Text(editing ? 'Edit subject' : 'Add subject'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Subject name',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter a subject name'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: Text(editing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

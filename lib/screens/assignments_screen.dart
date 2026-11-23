import 'package:flutter/material.dart';

import '../models/assignment.dart';
import '../services/id_generator.dart';
import '../widgets/assignment_card.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({
    required this.ownerId,
    required this.assignments,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    required this.onChanged,
    super.key,
  });

  final String ownerId;
  final List<Assignment> assignments;
  final Future<void> Function(Assignment task) onAdd;
  final Future<void> Function(Assignment task) onUpdate;
  final Future<void> Function(Assignment task) onDelete;
  final Future<void> Function(Assignment task, bool isCompleted) onChanged;

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final visibleTasks =
        widget.assignments
            .where((task) => task.isCompleted == _showCompleted)
            .toList()
          ..sort((first, second) => first.dueDate.compareTo(second.dueDate));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tasks',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF20243A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: _addTask,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add task'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Add and manage your assignments and to-dos.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: const Color(0xFF777D90)),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Pending')),
              ButtonSegment(value: true, label: Text('Completed')),
            ],
            selected: {_showCompleted},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              setState(() => _showCompleted = selection.first);
            },
          ),
        ),
        const SizedBox(height: 18),
        if (visibleTasks.isEmpty)
          _EmptyTasks(completed: _showCompleted, onAddTask: _addTask)
        else
          ...visibleTasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AssignmentCard(
                assignment: task,
                onChanged: (value) => widget.onChanged(task, value),
                onEdit: () => _editTask(task),
                onDelete: () => _confirmDelete(task),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addTask() async {
    final task = await showDialog<Assignment>(
      context: context,
      builder: (context) => _TaskFormDialog(ownerId: widget.ownerId),
    );
    if (task != null) await widget.onAdd(task);
  }

  Future<void> _editTask(Assignment task) async {
    final updated = await showDialog<Assignment>(
      context: context,
      builder: (context) =>
          _TaskFormDialog(ownerId: widget.ownerId, existingTask: task),
    );
    if (updated != null) await widget.onUpdate(updated);
  }

  Future<void> _confirmDelete(Assignment task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be permanently removed.'),
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
    if (confirmed == true) await widget.onDelete(task);
  }
}

class _TaskFormDialog extends StatefulWidget {
  const _TaskFormDialog({required this.ownerId, this.existingTask});

  final String ownerId;
  final Assignment? existingTask;

  @override
  State<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<_TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _dueDate = task?.dueDate ?? DateTime.now();
    _priority = task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existingTask;
    return AlertDialog(
      title: Text(existing == null ? 'Add task' : 'Edit task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a task title'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due date'),
                subtitle: Text(_formatDate(_dueDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _selectDueDate,
              ),
              DropdownButtonFormField<TaskPriority>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: TaskPriority.low, child: Text('Low')),
                  DropdownMenuItem(
                    value: TaskPriority.medium,
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.high,
                    child: Text('High'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
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

  Future<void> _selectDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.existingTask;
    Navigator.pop(
      context,
      Assignment(
        id: existing?.id ?? newRecordId(),
        ownerId: widget.ownerId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: existing?.isCompleted ?? false,
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.completed, required this.onAddTask});

  final bool completed;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Column(
        children: [
          Icon(
            completed ? Icons.task_alt_rounded : Icons.assignment_outlined,
            size: 44,
            color: const Color(0xFF6678D9),
          ),
          const SizedBox(height: 12),
          Text(
            completed ? 'No completed tasks yet' : 'No pending tasks',
            style: const TextStyle(
              color: Color(0xFF777D90),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!completed) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add),
              label: const Text('Add your first task'),
            ),
          ],
        ],
      ),
    );
  }
}

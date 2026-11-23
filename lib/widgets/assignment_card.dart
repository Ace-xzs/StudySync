import 'package:flutter/material.dart';

import '../models/assignment.dart';

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    required this.assignment,
    required this.onChanged,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Assignment assignment;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (assignment.priority) {
      TaskPriority.high => const Color(0xFFD34D5C),
      TaskPriority.medium => const Color(0xFFE49A32),
      TaskPriority.low => const Color(0xFF378A69),
    };
    final priorityLabel = switch (assignment.priority) {
      TaskPriority.high => 'High',
      TaskPriority.medium => 'Medium',
      TaskPriority.low => 'Low',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Checkbox(
              value: assignment.isCompleted,
              onChanged: (value) => onChanged(value ?? false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              activeColor: const Color(0xFF3446A5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: assignment.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: assignment.isCompleted
                          ? const Color(0xFF9297A7)
                          : const Color(0xFF20243A),
                    ),
                  ),
                  if (assignment.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      assignment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: const Color(0xFF777D90)),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Text(
                    'Due ${_formatDate(assignment.dueDate)}',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: const Color(0xFF777D90)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                priorityLabel,
                style: TextStyle(
                  color: priorityColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                tooltip: 'Task actions',
                onSelected: (action) {
                  if (action == 'edit') onEdit?.call();
                  if (action == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (onDelete != null)
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

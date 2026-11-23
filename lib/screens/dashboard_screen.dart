import 'package:flutter/material.dart';

import '../models/assignment.dart';
import '../models/class_schedule.dart';
import '../models/subject.dart';
import '../widgets/assignment_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.studentName,
    required this.assignments,
    required this.schedules,
    required this.subjects,
    required this.onAssignmentChanged,
    required this.onViewTasks,
    required this.onViewSchedule,
    super.key,
  });

  final String studentName;
  final List<Assignment> assignments;
  final List<ClassSchedule> schedules;
  final List<Subject> subjects;
  final Future<void> Function(Assignment task, bool isCompleted)
  onAssignmentChanged;
  final VoidCallback onViewTasks;
  final VoidCallback onViewSchedule;

  @override
  Widget build(BuildContext context) {
    final pending = assignments.where((task) => !task.isCompleted).toList()
      ..sort((first, second) => first.dueDate.compareTo(second.dueDate));
    final todaySchedules =
        schedules
            .where((schedule) => schedule.dayOfWeek == DateTime.now().weekday)
            .toList()
          ..sort(
            (first, second) =>
                first.startMinutes.compareTo(second.startMinutes),
          );
    final subjectNames = {
      for (final subject in subjects) subject.id: subject.name,
    };
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STUDYSYNC',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF6678D9),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hello, $studentName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF20243A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_weekdays[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: const Color(0xFF777D90)),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFE5E9FB),
              child: Text(
                studentName.isEmpty ? '?' : studentName[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF3446A5),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ProgressCard(
          pendingCount: pending.length,
          completedCount: assignments.length - pending.length,
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming tasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF20243A),
              ),
            ),
            TextButton(onPressed: onViewTasks, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 8),
        if (pending.isEmpty)
          _EmptySection(
            icon: Icons.check_circle_outline,
            message: 'No pending tasks. Add one whenever you need to.',
            actionLabel: 'Go to tasks',
            onPressed: onViewTasks,
          )
        else
          ...pending
              .take(3)
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AssignmentCard(
                    assignment: task,
                    onChanged: (value) => onAssignmentChanged(task, value),
                  ),
                ),
              ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Today’s classes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF20243A),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onViewSchedule,
              child: const Text('Schedule'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (todaySchedules.isEmpty)
          _EmptySection(
            icon: Icons.calendar_month_outlined,
            message: 'No classes scheduled for today.',
            actionLabel: 'View schedule',
            onPressed: onViewSchedule,
          )
        else
          ...todaySchedules.map(
            (schedule) => _TodayClass(
              time: _formatTime(schedule.startMinutes),
              subject: subjectNames[schedule.subjectId] ?? 'Unknown subject',
              room: schedule.classroom.isEmpty
                  ? 'Classroom not set'
                  : schedule.classroom,
            ),
          ),
      ],
    );
  }

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final total = pendingCount + completedCount;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF3446A5), Color(0xFF6678D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your study progress',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ProgressMetric(value: '$pendingCount', label: 'Pending'),
              const SizedBox(width: 28),
              _ProgressMetric(value: '$completedCount', label: 'Completed'),
              const Spacer(),
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFCFD5FF),
                size: 35,
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : completedCount / total,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFE0E4FF), fontSize: 12),
        ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6678D9)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: const Color(0xFF777D90)),
              ),
            ),
            TextButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _TodayClass extends StatelessWidget {
  const _TodayClass({
    required this.time,
    required this.subject,
    required this.room,
  });

  final String time;
  final String subject;
  final String room;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            Text(
              time,
              style: const TextStyle(
                color: Color(0xFF555C73),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 3,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF6678D9),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF20243A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    room,
                    style: const TextStyle(
                      color: Color(0xFF777D90),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

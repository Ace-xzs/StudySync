import 'package:flutter/material.dart';

import '../models/assignment.dart';
import '../models/class_schedule.dart';
import '../models/student_data.dart';
import '../models/student_profile.dart';
import '../models/subject.dart';
import '../services/local_study_repository.dart';
import '../services/study_repository.dart';
import 'assignments_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'schedule_screen.dart';
import 'subjects_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final StudyRepository _repository = LocalStudyRepository();
  int _selectedIndex = 0;
  late Future<void> _startup;
  List<StudentProfile> _profiles = [];
  StudentProfile? _activeProfile;
  StudentData? _studentData;

  @override
  void initState() {
    super.initState();
    _startup = _initialize();
  }

  Future<void> _initialize() async {
    var profiles = await _repository.loadProfiles();
    if (profiles.isEmpty) {
      profiles = [await _repository.createProfile('Student')];
    }

    final savedProfileId = await _repository.loadCurrentProfileId();
    final profile = profiles.where((item) => item.id == savedProfileId);
    final activeProfile = profile.isEmpty ? profiles.first : profile.first;
    if (activeProfile.id != savedProfileId) {
      await _repository.setCurrentProfile(activeProfile.id);
    }

    final studentData = await _repository.loadStudentData(activeProfile.id);
    _profiles = profiles;
    _activeProfile = activeProfile;
    _studentData = studentData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFD34D5C),
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text('StudySync could not load your saved data.'),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF777D90)),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() => _startup = _initialize());
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final profile = _activeProfile;
        final data = _studentData;
        if (profile == null || data == null) {
          return const Scaffold(
            body: Center(child: Text('Student profile is not available.')),
          );
        }
        return _buildAppShell(profile, data);
      },
    );
  }

  Widget _buildAppShell(StudentProfile profile, StudentData data) {
    final screens = [
      DashboardScreen(
        studentName: profile.name,
        assignments: data.tasks,
        schedules: data.schedules,
        subjects: data.subjects,
        onAssignmentChanged: _setTaskCompletion,
        onViewTasks: () => setState(() => _selectedIndex = 1),
        onViewSchedule: () => setState(() => _selectedIndex = 2),
      ),
      AssignmentsScreen(
        ownerId: profile.id,
        assignments: data.tasks,
        onAdd: _addTask,
        onUpdate: _updateTask,
        onDelete: _deleteTask,
        onChanged: _setTaskCompletion,
      ),
      ScheduleScreen(
        ownerId: profile.id,
        schedules: data.schedules,
        subjects: data.subjects,
        onAdd: _addSchedule,
        onUpdate: _updateSchedule,
        onDelete: _deleteSchedule,
        onManageSubjects: () => setState(() => _selectedIndex = 3),
      ),
      SubjectsScreen(
        ownerId: profile.id,
        subjects: data.subjects,
        schedules: data.schedules,
        onAdd: _addSubject,
        onUpdate: _updateSubject,
        onDelete: _deleteSubject,
      ),
      ProfileScreen(
        profiles: _profiles,
        currentProfile: profile,
        onCreateProfile: _createProfile,
        onRenameProfile: _renameProfile,
        onSelectProfile: _switchProfile,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _saveData(StudentData updated) async {
    try {
      await _repository.saveStudentData(updated);
      if (mounted) setState(() => _studentData = updated);
    } on Exception catch (error) {
      _showError('Could not save your changes: $error');
    }
  }

  Future<void> _addTask(Assignment task) {
    final data = _studentData!;
    return _saveData(data.copyWith(tasks: [...data.tasks, task]));
  }

  Future<void> _updateTask(Assignment task) {
    final data = _studentData!;
    return _saveData(
      data.copyWith(
        tasks: data.tasks
            .map((item) => item.id == task.id ? task : item)
            .toList(),
      ),
    );
  }

  Future<void> _deleteTask(Assignment task) {
    final data = _studentData!;
    return _saveData(
      data.copyWith(
        tasks: data.tasks.where((item) => item.id != task.id).toList(),
      ),
    );
  }

  Future<void> _setTaskCompletion(Assignment task, bool isCompleted) {
    return _updateTask(task.copyWith(isCompleted: isCompleted));
  }

  Future<void> _addSubject(Subject subject) {
    final data = _studentData!;
    return _saveData(data.copyWith(subjects: [...data.subjects, subject]));
  }

  Future<void> _updateSubject(Subject subject) {
    final data = _studentData!;
    return _saveData(
      data.copyWith(
        subjects: data.subjects
            .map((item) => item.id == subject.id ? subject : item)
            .toList(),
      ),
    );
  }

  Future<void> _deleteSubject(Subject subject) {
    final data = _studentData!;
    return _saveData(
      data.copyWith(
        subjects: data.subjects.where((item) => item.id != subject.id).toList(),
        schedules: data.schedules
            .where((item) => item.subjectId != subject.id)
            .toList(),
      ),
    );
  }

  Future<void> _addSchedule(ClassSchedule schedule) {
    final data = _studentData!;
    return _saveData(data.copyWith(schedules: [...data.schedules, schedule]));
  }

  Future<void> _updateSchedule(ClassSchedule schedule) {
    final data = _studentData!;
    return _saveData(
      data.copyWith(
        schedules: data.schedules
            .map((item) => item.id == schedule.id ? schedule : item)
            .toList(),
      ),
    );
  }

  Future<void> _deleteSchedule(ClassSchedule schedule) {
    final data = _studentData!;
    return _saveData(
      data.copyWith(
        schedules: data.schedules
            .where((item) => item.id != schedule.id)
            .toList(),
      ),
    );
  }

  Future<void> _createProfile(String name) async {
    try {
      final profile = await _repository.createProfile(name);
      await _switchProfile(profile.id);
      final profiles = await _repository.loadProfiles();
      if (mounted) setState(() => _profiles = profiles);
    } on Exception catch (error) {
      _showError('Could not create the profile: $error');
    }
  }

  Future<void> _renameProfile(String profileId, String name) async {
    try {
      final updated = await _repository.renameProfile(profileId, name);
      final profiles = await _repository.loadProfiles();
      if (!mounted) return;
      setState(() {
        _profiles = profiles;
        if (_activeProfile?.id == profileId) _activeProfile = updated;
      });
    } on Exception catch (error) {
      _showError('Could not rename the profile: $error');
    }
  }

  Future<void> _switchProfile(String profileId) async {
    try {
      final profiles = await _repository.loadProfiles();
      final matches = profiles.where((item) => item.id == profileId);
      if (matches.isEmpty) throw Exception('Student profile was not found.');

      final data = await _repository.loadStudentData(profileId);
      await _repository.setCurrentProfile(profileId);
      if (!mounted) return;
      setState(() {
        _profiles = profiles;
        _activeProfile = matches.first;
        _studentData = data;
        _selectedIndex = 0;
      });
    } on Exception catch (error) {
      _showError('Could not switch profiles: $error');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

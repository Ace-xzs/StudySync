import 'package:flutter/material.dart';

import '../models/student_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.profiles,
    required this.currentProfile,
    required this.onCreateProfile,
    required this.onRenameProfile,
    required this.onSelectProfile,
    super.key,
  });

  final List<StudentProfile> profiles;
  final StudentProfile currentProfile;
  final Future<void> Function(String name) onCreateProfile;
  final Future<void> Function(String profileId, String name) onRenameProfile;
  final Future<void> Function(String profileId) onSelectProfile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF20243A),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage your local student profile.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: const Color(0xFF777D90)),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFE5E9FB),
              child: Text(
                currentProfile.name.isEmpty
                    ? '?'
                    : currentProfile.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF3446A5),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Text(
              currentProfile.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('Current profile'),
            trailing: IconButton(
              tooltip: 'Rename profile',
              onPressed: () => _renameProfile(context, currentProfile),
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Profiles on this device',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF20243A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _createProfile(context),
              icon: const Icon(Icons.add),
              label: const Text('Add profile'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...profiles.map(
          (profile) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                profile.id == currentProfile.id
                    ? Icons.person
                    : Icons.person_outline,
                color: const Color(0xFF6678D9),
              ),
              title: Text(profile.name),
              trailing: profile.id == currentProfile.id
                  ? const Icon(Icons.check_circle, color: Color(0xFF3446A5))
                  : const Icon(Icons.chevron_right_rounded),
              onTap: profile.id == currentProfile.id
                  ? null
                  : () => onSelectProfile(profile.id),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: const Color(0xFFE9ECFC),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Color(0xFF3446A5)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Local profiles keep study data separated on this device. '
                    'They do not use passwords or online accounts, so anyone '
                    'with access to this device can switch profiles. '
                    'Firebase sign-in can be added later for account security '
                    'and sync.',
                    style: TextStyle(
                      color: Color(0xFF35406F),
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createProfile(BuildContext context) async {
    final name = await _askForName(context, title: 'Add student profile');
    if (name != null) await onCreateProfile(name);
  }

  Future<void> _renameProfile(
    BuildContext context,
    StudentProfile profile,
  ) async {
    final name = await _askForName(
      context,
      title: 'Rename profile',
      initialName: profile.name,
    );
    if (name != null) await onRenameProfile(profile.id, name);
  }

  Future<String?> _askForName(
    BuildContext context, {
    required String title,
    String? initialName,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) =>
          _ProfileNameDialog(title: title, initialName: initialName),
    );
  }
}

class _ProfileNameDialog extends StatefulWidget {
  const _ProfileNameDialog({required this.title, this.initialName});

  final String title;
  final String? initialName;

  @override
  State<_ProfileNameDialog> createState() => _ProfileNameDialogState();
}

class _ProfileNameDialogState extends State<_ProfileNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Student name',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter a name' : null,
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}

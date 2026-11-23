# StudySync
# StudySync

StudySync is a Material 3 student planner built with Flutter for managing tasks, subjects, and class schedules.

## Features

- Add, edit, complete, and delete tasks.
- Organize tasks into Pending and Completed views.
- Add, edit, and delete enrolled subjects.
- Add, edit, and delete class schedules with daily and weekly views.
- Use separate local student profiles on the same device.
- Keep each profile's data saved on the device between app launches.

## Getting Started

Install the project dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Testing

Run the automated tests:

```bash
flutter test
```

Run static code analysis:

```bash
flutter analyze
```

## Data and Accounts

The current version stores data locally using `shared_preferences`.

Each profile has its own data key, and each record carries its profile owner ID.

Local profiles do not have passwords and are not secure against another person who can access the device.

Firebase Authentication and Cloud Firestore are not configured yet. The `StudyRepository` interface provides a foundation for adding remote storage and synchronization in the future.

## Technology Stack

- Flutter
- Dart
- Material 3
- Shared Preferences
72d6d3632d8c29ff5e737c65ab2c31c27ecd428f

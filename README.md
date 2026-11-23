# StudySync

StudySync is a Material 3 student planner for managing tasks, subjects, and
class schedules.

## Features

- Add, edit, complete, and delete tasks.
- Organize tasks into Pending and Completed views.
- Add, edit, and delete enrolled subjects.
- Add, edit, and delete class schedules, with daily and weekly views.
- Use separate local student profiles on the same device.
- Keep each profile's data saved on the device between app launches.

## Run the app

```shell
flutter pub get
flutter run
```

Run the tests and static checks with:

```shell
flutter test
flutter analyze
```

## Data and accounts

The current version stores data locally using `shared_preferences`. Every
profile has its own data key and each record carries that profile's owner ID.
Local profiles do not have passwords and are not secure against another person
who can use the device. Firebase Authentication and Cloud Firestore are not
configured yet; `StudyRepository` provides a boundary for adding a remote
implementation later.

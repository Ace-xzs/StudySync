import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysync/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows an empty dashboard and all five navigation tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const StudySyncApp());
    await tester.pumpAndSettle();

    expect(find.text('STUDYSYNC'), findsOneWidget);
    expect(find.text('Upcoming tasks'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Schedule'), findsWidgets);
    expect(find.text('Subjects'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('adds a task and moves it to the completed view', (tester) async {
    await tester.pumpWidget(const StudySyncApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Read biology chapter',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Review the cell section',
    );
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    expect(find.text('Read biology chapter'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();
    expect(find.text('Read biology chapter'), findsOneWidget);
  });

  testWidgets('edits and confirms deletion of a task', (tester) async {
    await tester.pumpWidget(const StudySyncApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Original title',
    );
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Task actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Updated title',
    );
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect(find.text('Updated title'), findsOneWidget);

    await tester.tap(find.byTooltip('Task actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.text('Updated title'), findsNothing);
  });

  testWidgets('adds a subject and creates a class schedule', (tester) async {
    await tester.pumpWidget(const StudySyncApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Subjects'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add subject'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Physics');
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();
    expect(find.text('Physics'), findsOneWidget);

    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add class'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Classroom'),
      'Lab 4',
    );
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Lab 4'), findsOneWidget);

    await tester.tap(find.text('Subjects'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Subject actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(find.text('Add a subject first'), findsOneWidget);
    expect(find.text('Physics'), findsNothing);
  });

  testWidgets('switching local profiles keeps their tasks separate', (
    tester,
  ) async {
    await tester.pumpWidget(const StudySyncApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Only for Student',
    );
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Alex');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('Only for Student'), findsNothing);
    expect(find.text('No pending tasks'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Student').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('Only for Student'), findsOneWidget);
  });
}

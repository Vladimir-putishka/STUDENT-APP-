# Student Assistant 🎓 — Flutter Milestone 1

A responsive student planner MVP built for the Weeks 5–7 assessment (NOT the Week 15 final capstone).

## Problem and target users
Students often track deadlines and classes in different places. Student Assistant brings today's classes and upcoming assignments into a single, simple screen.

## Features
- **Home / Dashboard:** study progress, class schedule, and assignment list.
- **Task Details:** Stack banner with overlay bookmark, assignment description, tags and deadline.
- **Interactivity:** bookmark/unbookmark a task and mark it complete/in progress with `StatefulWidget` and `setState()`.
- **Responsive layout:** scrollable screens, constrained width, `Expanded`, `Wrap`, text ellipsis, and sticky bottom button.

## Run the project
Flutter SDK is required. Since this hand-in contains source files (rather than generated platform folders):

```bash
flutter create student_assistant
cd student_assistant
```

Copy the provided `lib/` folder and `pubspec.yaml` into the newly created folder (replace existing files), then:

```bash
flutter pub get
flutter run
```

## Folder layout
```text
lib/
  main.dart
  models/student_task.dart
  screens/home_screen.dart
  screens/task_detail_screen.dart
  widgets/task_card.dart
  widgets/schedule_card.dart
```

## Milestone 1 checklist
- [x] At least two screens
- [x] Column, Row, Card, Expanded, Wrap and Stack
- [x] Working StatefulWidget / setState interaction
- [x] Responsive scrollable content, avoiding RenderFlex overflow
- [x] Clean screens/widgets folder separation
- [ ] Run on an emulator/phone to verify layout
- [ ] Push the resulting Flutter project to GitHub

## Defense script (3–5 minutes)
**Pitch (1 minute):** Student Assistant solves the problem of keeping track of assignments and class schedules. The target users are university students. The home screen shows classes and upcoming tasks, helping students stay organized.

**Live demo (2 minutes):** Show the dashboard, schedule and progress. Open a task card to view details. Tap the bookmark icon, then Mark as Completed. Go back and show that the task icon and progress counter have updated. Reopen the task and mark it In Progress to demonstrate the second state.

**Code review (1 minute):** Show `lib/screens` and `lib/widgets`. Explain that `HomeScreen` stores the tasks in a `StatefulWidget`, and `TaskDetailScreen` calls `setState()` to change the task state. Point out `Stack` on the detail banner, `Wrap` for tags, `Expanded` for the bottom button, and scroll views for smaller phones.

## Notes
This is intentionally a local-state MVP: no database, REST API, or BLoC is needed for Milestone 1. Demo tasks and schedule are sample data, not live university records.

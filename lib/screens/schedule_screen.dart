import 'package:flutter/material.dart';

import '../models/class_session.dart';
import '../services/schedule_service.dart';

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.schedule});

  final ScheduleService schedule;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int weekday = DateTime.now().weekday;

  Future<void> _edit([ClassSession? session]) async {
    final saved = await showDialog<ClassSession>(
      context: context,
      builder: (_) => _ClassEditor(
        weekday: weekday,
        session: session,
        onSave: widget.schedule.save,
      ),
    );
    if (mounted && saved != null) setState(() => weekday = saved.weekday);
  }

  Future<void> _remove(ClassSession session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this weekly class?'),
        content: Text(session.subject),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (!mounted || confirm != true) return;
    try {
      await widget.schedule.remove(session.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not remove this class. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly schedule')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _edit,
        icon: const Icon(Icons.add),
        label: const Text('Add class'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListenableBuilder(
              listenable: widget.schedule,
              builder: (context, _) {
                final sessions = widget.schedule.forWeekday(weekday);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [
                        for (var day = 1; day <= 7; day++)
                          ChoiceChip(
                            label: Text(_days[day - 1]),
                            selected: weekday == day,
                            onSelected: (_) => setState(() => weekday = day),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (sessions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Text('No classes scheduled for this day.'),
                      ),
                    for (final session in sessions)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.schedule),
                          title: Text(session.subject),
                          subtitle: Text(
                            '${ClassSession.timeOfDay(session.startMinute).format(context)}'
                            ' – ${ClassSession.timeOfDay(session.endMinute).format(context)}'
                            '${session.room.isEmpty ? '' : ' · ${session.room}'}',
                          ),
                          onTap: () => _edit(session),
                          trailing: PopupMenuButton<String>(
                            tooltip: 'Class actions',
                            onSelected: (action) {
                              if (action == 'edit') {
                                _edit(session);
                              } else {
                                _remove(session);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                  value: 'remove', child: Text('Remove')),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassEditor extends StatefulWidget {
  const _ClassEditor({
    required this.weekday,
    required this.session,
    required this.onSave,
  });

  final int weekday;
  final ClassSession? session;
  final Future<void> Function(ClassSession) onSave;

  @override
  State<_ClassEditor> createState() => _ClassEditorState();
}

class _ClassEditorState extends State<_ClassEditor> {
  final _form = GlobalKey<FormState>();
  late final _subject = TextEditingController(text: widget.session?.subject);
  late final _room = TextEditingController(text: widget.session?.room);
  late int _weekday = widget.session?.weekday ?? widget.weekday;
  late int _start = widget.session?.startMinute ?? 9 * 60;
  late int _end = widget.session?.endMinute ?? 10 * 60;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _subject.dispose();
    _room.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: ClassSession.timeOfDay(isStart ? _start : _end),
    );
    if (!mounted || picked == null) return;
    final minute = picked.hour * 60 + picked.minute;
    setState(() {
      if (isStart) {
        _start = minute;
      } else {
        _end = minute;
      }
    });
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    if (_end <= _start) {
      setState(() => _error = 'End time must be after start time.');
      return;
    }
    final session = ClassSession(
      id: widget.session?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      weekday: _weekday,
      startMinute: _start,
      endMinute: _end,
      subject: _subject.text.trim(),
      room: _room.text.trim(),
    );
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(session);
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.pop(context, session);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save this class. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.session == null ? 'Add weekly class' : 'Edit class'),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _subject,
              decoration: const InputDecoration(labelText: 'Course'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a course'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _room,
              decoration: const InputDecoration(labelText: 'Room (optional)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _weekday,
              decoration: const InputDecoration(labelText: 'Repeats every'),
              items: [
                for (var day = 1; day <= 7; day++)
                  DropdownMenuItem(value: day, child: Text(_days[day - 1])),
              ],
              onChanged:
                  _saving ? null : (value) => setState(() => _weekday = value!),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Start time'),
              subtitle: Text(ClassSession.timeOfDay(_start).format(context)),
              onTap: _saving ? null : () => _pickTime(isStart: true),
            ),
            ListTile(
              title: const Text('End time'),
              subtitle: Text(ClassSession.timeOfDay(_end).format(context)),
              onTap: _saving ? null : () => _pickTime(isStart: false),
            ),
            if (_error != null)
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Save class'),
        ),
      ],
    );
  }
}

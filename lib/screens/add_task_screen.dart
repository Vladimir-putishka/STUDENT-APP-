import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/student_task.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskService taskService;
  final StudentTask? task;

  const AddTaskScreen({
    super.key,
    required this.taskService,
    this.task,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final formKey = GlobalKey<FormState>();

  late final titleController = TextEditingController(text: widget.task?.title);
  late final subjectController = TextEditingController(text: widget.task?.subject);
  late final descriptionController =
      TextEditingController(text: widget.task?.description);

  late DateTime? selectedDate = widget.task?.deadline;
  late String selectedCategory = widget.task?.category ?? 'Development';
  bool saving = false;

  Future<void> selectDate() async {
    final initialDate = selectedDate ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year - 10),
      lastDate: DateTime(initialDate.year + 10, 12, 31),
    );

    if (mounted && date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> saveTask() async {
    if (saving || !formKey.currentState!.validate()) return;

    final oldTask = widget.task;
    final date = selectedDate;
    if (date == null && oldTask == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    final title = titleController.text.trim();
    final subject = subjectController.text.trim();
    final description = descriptionController.text.trim();
    final category = selectedCategory;
    StudentTask buildTask(StudentTask? current) => StudentTask(
          id: current?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
          title: title,
          subject: subject,
          description: description,
          dueDate: date == null
              ? oldTask!.dueDate
              : '${date.day}/${date.month}/${date.year}',
          category: category,
          color: current?.color ?? const Color(0xFF405DE6),
          isCompleted: current?.isCompleted ?? false,
          isFavorite: current?.isFavorite ?? false,
        );

    setState(() => saving = true);
    try {
      if (oldTask == null) {
        await widget.taskService.addTask(buildTask(null));
      } else {
        await widget.taskService.updateTask(oldTask.id, buildTask);
      }
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the assignment. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Assignment' : 'Edit Assignment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter title'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter subject'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                items: {'Development', 'Research', 'Exam', 'Quiz', selectedCategory}
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(
                    () => selectedCategory = value ?? 'Development',
                  );
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  selectedDate == null
                      ? widget.task?.dueDate ?? 'Select due date'
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: selectDate,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : saveTask,
                  child: Text(widget.task == null ? 'Add Assignment' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

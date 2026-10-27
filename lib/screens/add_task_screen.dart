import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/student_task.dart';
import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskService taskService;

  const AddTaskScreen({
    super.key,
    required this.taskService,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? selectedDate;
  String selectedCategory = 'Development';

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> saveTask() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    final date = selectedDate!;

    final task = StudentTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      subject: subjectController.text.trim(),
      description: descriptionController.text.trim(),
      dueDate: '${date.day}/${date.month}/${date.year}',
      category: selectedCategory,
      color: const Color(0xFF405DE6),
    );

    await widget.taskService.addTask(task);

    if (!mounted) return;

    Navigator.pop(context);
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
      appBar: AppBar(title: const Text('New Assignment')),
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
                validator: (value) =>
                value == null || value.trim().isEmpty
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
                validator: (value) =>
                value == null || value.trim().isEmpty
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
                items: ['Development', 'Research', 'Exam', 'Quiz']
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
                      ? 'Select due date'
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: selectDate,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveTask,
                  child: const Text('Add Assignment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
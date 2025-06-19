import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_notifier.dart';

class TodoDetailsScreen extends ConsumerStatefulWidget {
  final String todoId;

  const TodoDetailsScreen({super.key, required this.todoId});

  @override
  ConsumerState<TodoDetailsScreen> createState() => _TodoDetailsScreenState();
}

class _TodoDetailsScreenState extends ConsumerState<TodoDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _selectedCategory = 'Personal';
  DateTime? _selectedDueDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeControllers(Todo todo) {
    _titleController.text = todo.title;
    _descriptionController.text = todo.description;
    _selectedCategory = todo.category;
    _selectedDueDate = todo.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todoProvider);

    return todosAsync.when(
      data: (todos) {
        final todo = todos.firstWhere((t) => t.id == widget.todoId);
        if (!_isEditing) {
          _initializeControllers(todo);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Task' : 'Task Details'),
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit),
                onPressed: () {
                  if (_isEditing) {
                    if (_titleController.text.isNotEmpty) {
                      ref.read(todoProvider.notifier).updateTodo(
                            todo.copyWith(
                              title: _titleController.text,
                              description: _descriptionController.text,
                              category: _selectedCategory,
                              dueDate: _selectedDueDate,
                            ),
                          );
                    }
                  }
                  setState(() => _isEditing = !_isEditing);
                },
              ),
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text(
                            'Are you sure you want to delete this task?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(todoProvider.notifier)
                                  .deleteTodo(todo.id);
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Go back to list
                            },
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing) ...[
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'Personal',
                      'Work',
                      'Shopping',
                      'Health',
                      'Urgent',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Due Date:'),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDueDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _selectedDueDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDueDate != null
                              ? _selectedDueDate!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]
                              : 'Select Date',
                        ),
                      ),
                      if (_selectedDueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              setState(() => _selectedDueDate = null),
                        ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          todo.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Checkbox(
                        value: todo.completed,
                        onChanged: (bool? value) {
                          if (value != null) {
                            ref.read(todoProvider.notifier).updateTodo(
                                  todo.copyWith(completed: value),
                                );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      todo.category,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (todo.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(todo.description),
                    const SizedBox(height: 16),
                  ],
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Created'),
                    subtitle: Text(todo.formattedCreationDate),
                  ),
                  if (todo.dueDate != null)
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('Due Date'),
                      subtitle: Text(todo.formattedDueDate),
                      trailing: todo.isOverdue
                          ? const Chip(
                              label: Text('Overdue'),
                              backgroundColor: Colors.red,
                              labelStyle: TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

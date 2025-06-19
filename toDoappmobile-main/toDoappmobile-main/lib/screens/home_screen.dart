import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../widgets/theme_switcher.dart';
import 'todo_details_screen.dart';
import '../providers/todo_notifier.dart';
import '../providers/settings_notifier.dart';
import '../providers/auth_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoProvider);
    final settings = ref.watch(settingsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TodoSearchDelegate(ref),
              );
            },
          ),
          const ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: todosAsync.when(
        data: (todos) {
          if (todos.isEmpty) {
            return Column(
              children: [
                _buildWelcomeHeader(authState),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a new task to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final filteredTodos = todos.where((todo) =>
              (selectedCategory == null || todo.category == selectedCategory) &&
              (settings.showCompletedTodos || !todo.completed)).toList();

          if (settings.sortByDueDate) {
            filteredTodos.sort((a, b) {
              if (a.dueDate == null && b.dueDate == null) return 0;
              if (a.dueDate == null) return 1;
              if (b.dueDate == null) return -1;
              return a.dueDate!.compareTo(b.dueDate!);
            });
          }

          return Column(
            children: [
              _buildWelcomeHeader(authState),
              _buildCategoryFilter(context, ref),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTodos.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (context, index) {
                    final todo = filteredTodos[index];
                    return _buildTodoCard(context, ref, todo);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildWelcomeHeader(authState) {
    final username = authState.user ?? 'Guest';
    final letter = username.isNotEmpty ? username[0].toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(
              letter,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Welcome, $username!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(context, ref, 'All', null, selectedCategory == null),
          _buildFilterChip(context, ref, 'Personal', 'Personal', selectedCategory == 'Personal'),
          _buildFilterChip(context, ref, 'Work', 'Work', selectedCategory == 'Work'),
          _buildFilterChip(context, ref, 'Shopping', 'Shopping', selectedCategory == 'Shopping'),
          _buildFilterChip(context, ref, 'Health', 'Health', selectedCategory == 'Health'),
          _buildFilterChip(context, ref, 'Urgent', 'Urgent', selectedCategory == 'Urgent'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, WidgetRef ref, String label, String? category, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (bool selected) {
          ref.read(selectedCategoryProvider.notifier).state = category;
        },
      ),
    );
  }

  Widget _buildTodoCard(BuildContext context, WidgetRef ref, Todo todo) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(todo.id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          ref.read(todoProvider.notifier).deleteTodo(todo.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Task deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  ref.read(todoProvider.notifier).addTodo(todo);
                },
              ),
            ),
          );
        },
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/todoDetails',
              arguments: {'todoId': todo.id},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: todo.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.completed
                                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          if (todo.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              todo.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(todo.completed ? 0.5 : 0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCategoryChip(context, todo.category),
                    const Spacer(),
                    if (todo.dueDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            todo.formattedDueDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Personal';
    DateTime? selectedDueDate;
    final authState = ref.watch(authProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
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
                    selectedCategory = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => Row(
                  children: [
                    const Text('Due Date:'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => selectedDueDate = date);
                        }
                      },
                      child: Text(
                        selectedDueDate != null
                            ? selectedDueDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0]
                            : 'Select Date',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                ref.read(todoProvider.notifier).addTodo(
                      Todo(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        title: titleController.text,
                        description: descriptionController.text,
                        completed: false,
                        creationDate: DateTime.now(),
                        category: selectedCategory,
                        dueDate: selectedDueDate,
                        userId: authState.user ?? 'unknown',
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class TodoSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  TodoSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final todosAsync = ref.watch(todoProvider);

    return todosAsync.when(
      data: (todos) {
        final results = todos.where((todo) =>
            todo.title.toLowerCase().contains(query.toLowerCase()) ||
            todo.description.toLowerCase().contains(query.toLowerCase()));

        if (results.isEmpty) {
          return Center(
            child: Text(
              query.isEmpty ? 'Start typing to search' : 'No results found',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final todo = results.elementAt(index);
            return ListTile(
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration:
                      todo.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(todo.description),
              leading: Icon(
                todo.completed ? Icons.check_circle : Icons.circle_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {
                close(context, null);
                Navigator.pushNamed(
                  context,
                  '/todoDetails',
                  arguments: {'todoId': todo.id},
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}


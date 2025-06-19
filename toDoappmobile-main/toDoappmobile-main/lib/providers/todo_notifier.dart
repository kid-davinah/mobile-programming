import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import 'package:dio/dio.dart';

class TodoNotifier extends StateNotifier<AsyncValue<List<Todo>>> {
  TodoNotifier() : super(const AsyncValue.loading()) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      state = const AsyncValue.loading();
      Dio dio = Dio();
      var response = await dio.get('https://dummyjson.com/todos');
      List data = response.data['todos'];
      final todos = data.map<Todo>((json) => Todo.fromApiJson(json)).toList();
      state = AsyncValue.data(todos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTodo(Todo todo) async {
    final current = state.value ?? [];
    state = AsyncValue.data([...current, todo]);
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    final current = state.value ?? [];
    final index = current.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      final updatedList = [...current];
      updatedList[index] = updatedTodo;
      state = AsyncValue.data(updatedList);
    }
  }

  Future<void> deleteTodo(String todoId) async {
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((todo) => todo.id != todoId).toList());
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, AsyncValue<List<Todo>>>(
  (ref) => TodoNotifier(),
);

final selectedCategoryProvider = StateProvider<String?>((ref) => null); 
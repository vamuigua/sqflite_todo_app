import 'package:flutter/material.dart';
import 'package:sqflite_todo_app/models/task.dart';
import 'package:sqflite_todo_app/services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  String? _task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Sqflite App'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: _addTaskButton(),
      body: _tasksList(),
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Add Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _task = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Wash clothes...",
                      ),
                    ),
                    MaterialButton(
                      color: Theme.of(context).colorScheme.onBackground,
                      onPressed: () {
                        if (_task == null || _task?.trim() == '') return;
                        _databaseService.addTask(_task!);
                        setState(() {
                          _task = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              );
            });
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _tasksList() {
    return FutureBuilder(
      future: _databaseService.getTasks(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          List<Task> tasks = snapshot.data as List<Task>;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (ctx, index) {
              Task task = tasks[index];
              return ListTile(
                title: Text(task.content),
                trailing: Checkbox(
                  value: task.status == 1,
                  onChanged: (value) {
                    _databaseService.updateTaskStatus(
                      task.id,
                      value == true ? 1 : 0,
                    );
                    setState(() {});
                  },
                ),
                onLongPress: () {
                  _databaseService.deleteTask(task.id);
                  setState(() {});
                },
              );
            },
          );
        }

        return const Center(
          child: Text('No tasks yet'),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_with_firebase/models/todo.dart';
import 'package:flutter_with_firebase/services/database_service.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Todo-App',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          _massagesListView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayTextInputDialog();
        },
      ),
    );
  }

  Widget _massagesListView() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      width: MediaQuery.sizeOf(context).width,
      child: StreamBuilder(
          stream: _databaseService.getTodos(),
          builder: (context, snapshot) {
            List todos = snapshot.data?.docs ?? [];
            if (todos.isEmpty) {
              return const Center(
                child: Text('Add a todo'),
              );
            }
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                Todo todo = todos[index].data();
                String todoId = todos[index].id;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.primaryContainer,
                    title: Text(todo.task),
                    subtitle: Text(
                      DateFormat('dd-MM-yyyy h:mm a').format(
                        todo.updatedOn.toDate(),
                      ),
                    ),
                    trailing: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) {
                        Todo updatedTodo = todo.copyWith(
                          isDone: !todo.isDone,
                          updatedOn: Timestamp.now(),
                        );
                        _databaseService.updateTodo(todoId, updatedTodo);
                      },
                    ),
                    onLongPress: () {
                      _databaseService.deleteTodo(todoId);
                    },
                  ),
                );
              },
            );
          }),
    );
  }

  void _displayTextInputDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add a todo'),
            content: TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(
                hintText: 'Todo...',
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {
                  Todo todo = Todo(
                    task: _textEditingController.text,
                    isDone: false,
                    createdOn: Timestamp.now(),
                    updatedOn: Timestamp.now(),
                  );
                  _databaseService.addTodo(todo);
                  Navigator.pop(context);
                  _textEditingController.clear();
                },
                color: Theme.of(context).colorScheme.primary,
                textColor: Colors.white,
                child: const Text('Ok'),
              )
            ],
          );
        });
  }
}

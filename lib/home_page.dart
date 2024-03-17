import 'dart:convert';
import 'dart:ffi';

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
  // List<Todo> dara = [];
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  int totalSum = 0;
  @override
  void initState() {
    super.initState();
    calculateSum();
  }

  void calculateSum() async {
    int sum = 0;
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(TODO_COLLECTION_REF).get();

    for (var doc in querySnapshot.docs) {
      Todo todo = Todo.fromJson(doc.data() as Map<String, Object?>);
      // Assuming your documents have a field named 'value' to sum
      sum += (todo.point);
      // print(todo.point);
    }

    setState(() {
      totalSum = sum;
    });
    print(totalSum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _displayTextInputDialog,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Todo-App',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: _massagesListView(),
    );
  }

  Widget _massagesListView() {
    // Future<void> calculateSum() async {
    //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //       .collection(TODO_COLLECTION_REF)
    //       .get();
    //   // Summing up the 'point' field from each document using reduce
    //   num totalSum = querySnapshot.docs.fold(
    //     1, // Initial value for the sum
    //     (previousValue, doc) {
    //       // Add the 'point' field value of the current document to the previous sum
    //       Todo todo = Todo.fromJson(doc.data() as Map<String, Object?>);
    //       return previousValue +
    //           (todo.point); // Assuming 'point' is the field to be summed
    //     },
    //   );
    //   print(totalSum);
    // }

    // Future getData() async {
    //   QuerySnapshot qs = await FirebaseFirestore.instance
    //       .collection(TODO_COLLECTION_REF)
    //       .get();

    //   setState(() {
    //    // List<Map<String,Object?>>
    //   final json= jsonDecode(qs.docs.data());
    //     dara.fromJson() = qs.docs. as Map<String, Object?>;
    //   });
    // }

    // int getSum() {
    //   for (var doc in dara.docs) {
    //     Todo todo = Todo.fromJson(doc.data() as Map<String, Object?>);
    //     // Assuming your documents have a field named 'value' to sum
    //     sum += (todo.point);
    //     // print(todo.point);
    //   }

    //   return totalSum = sum;
    // }

    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
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
              scrollDirection: Axis.vertical,
              itemCount: todos.length,
              itemBuilder: (context, index) {
                Todo todo = todos[index].data();
                String todoId = todos[index].id;
                int point = todo.point;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.primaryContainer,
                    title: Text(todo.task),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('dd-MM-yyyy h:mm a').format(
                            todo.updatedOn.toDate(),
                          ),
                        ),
                        Text(
                          'Point:$point',
                        ),
                        Text(
                          totalSum.toString(),
                        ),
                      ],
                    ),
                    trailing: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) {
                        if (!todo.isDone) {
                          Todo updatedTodo = todo.copyWith(
                            isDone: true,
                            updatedOn: Timestamp.now(),
                            point: 1,
                          );
                          _databaseService.updateTodo(todoId, updatedTodo);
                        } else if (todo.isDone) {
                          Todo updatedTodo = todo.copyWith(
                            isDone: false,
                            updatedOn: Timestamp.now(),
                            point: 0,
                          );
                          _databaseService.updateTodo(todoId, updatedTodo);
                        }
                      },
                    ),
                    onLongPress: () {
                      // _databaseService.deleteTodo(todoId);
                      calculateSum();
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
                    point: 0,
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

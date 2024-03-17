

import 'package:cloud_firestore/cloud_firestore.dart';

// Defining a class named Todo
class Todo {
  // Fields representing properties of a todo item
  String task; // Task description
  bool isDone; // Indicates if the task is done or not
  Timestamp createdOn; // Timestamp of when the task was created
  Timestamp updatedOn;
  int point; // Timestamp of when the task was last updated

  // Constructor for initializing a Todo object
  Todo({
    required this.task,
    required this.isDone,
    required this.createdOn,
    required this.updatedOn,
    required this.point,
  });

  // Named constructor to create a Todo object from a JSON map
  Todo.fromJson(Map<String, Object?> json)
      : this(
          task: json['task']! as String,
          isDone: json['isDone']! as bool,
          createdOn: json['createdOn']! as Timestamp,
          updatedOn: json['updatedOn']! as Timestamp,
          point: json['point']! as int
        );

  // Method to create a copy of a Todo object with specified fields updated
  Todo copyWith({
    String? task,
    bool? isDone,
    Timestamp? createdOn,
    Timestamp? updatedOn,
    int? point,
  }) {
    return Todo(
        task: task ?? this.task,
        isDone: isDone ?? this.isDone,
        createdOn: createdOn ?? this.createdOn,
        updatedOn: updatedOn ?? this.updatedOn,
        point: point ?? this.point);
  }

  // Method to convert a Todo object to a JSON-compatible map
  Map<String, Object?> toJson() {
    return {
      'task': task,
      'isDone': isDone,
      'createdOn': createdOn,
      'updatedOn': updatedOn,
      'point': point
    };
  }
}

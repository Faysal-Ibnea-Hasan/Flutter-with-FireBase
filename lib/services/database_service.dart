// Importing necessary packages
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:flutter_with_firebase/models/todo.dart'; // Importing the Todo class

// Constant variable to hold the name of the Firestore collection
const String TODO_COLLECTION_REF = 'Todos';

// Class responsible for handling database interactions
class DatabaseService {
  // Instance of Firestore
  final _firestore = FirebaseFirestore.instance;

  // Collection reference for todos
  late final CollectionReference _todoRef;

  // Constructor
  DatabaseService() {
    // Initialize the collection reference with converters for the Todo class
    _todoRef = _firestore.collection(TODO_COLLECTION_REF).withConverter<Todo>(
      // Convert Firestore data to Todo object
      fromFirestore: (snapshots, _) => Todo.fromJson(snapshots.data()!),
      // Convert Todo object to Firestore data
      toFirestore: (todo, _) => todo.toJson(),
    );
  }

  // Method to get all todos as a stream
  Stream<QuerySnapshot> getTodos() {
    return _todoRef.snapshots();
  }

  // Method to add a todo
  void addTodo(Todo todo) async {
    _todoRef.add(todo);
  }

  // Method to update a todo
  void updateTodo(String todoId, Todo todo) {
    _todoRef.doc(todoId).update(todo.toJson());
  }

  // Method to delete a todo
  void deleteTodo(String todoId) {
    _todoRef.doc(todoId).delete();
  }
}

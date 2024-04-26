import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Task Manager',
      home: TaskScreen(),
    );
  }
}

class Task {
  final String id;
  final String title;
  final bool isCompleted;

  Task({required this.id, required this.title, required this.isCompleted});
}

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  const TaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.title),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Delete task functionality here
            },
          ),
        );
      },
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    // Fetch tasks from Firestore
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('tasks').get();
      setState(() {
        tasks = querySnapshot.docs
            .map((doc) => Task(
          id: doc.id,
          title: doc['title'] ?? '',
          isCompleted: doc['isCompleted'] ?? false,
        ))
            .toList();
      });
    } catch (error) {
      print('Error fetching tasks: $error');
      // Handle error (e.g., show error message to user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: tasks != null
          ? TaskList(tasks: tasks)
          : const CircularProgressIndicator(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open dialog to add new task
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

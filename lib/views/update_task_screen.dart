import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateTaskScreen extends StatefulWidget {
  final DocumentSnapshot taskSnapshot;

  const UpdateTaskScreen({super.key, required this.taskSnapshot});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  TextEditingController taskC = TextEditingController();

  @override
  void initState() {
    taskC.text = widget.taskSnapshot['title'];
    super.initState();
  }

  @override
  void dispose() {
    taskC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: taskC,
              decoration: const InputDecoration(
                hintText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16), // Replaced Gap(16) with SizedBox
            ElevatedButton(
              onPressed: () async {
                String taskTitle = taskC.text.trim();

                String uid = FirebaseAuth.instance.currentUser!.uid;
                var taskRef = FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(uid)
                    .collection('tasks')
                    .doc(widget.taskSnapshot['taskId']);

                await taskRef.update({'title': taskTitle});

                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task Updated')),
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

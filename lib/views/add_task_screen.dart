import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization package

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TextEditingController taskC = TextEditingController();

  @override
  void dispose() {
    taskC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(localizations.appTitle,
            style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: taskC,
              decoration: InputDecoration(
                hintText: localizations.taskNameHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String taskTitle = taskC.text.trim();
                String uid = FirebaseAuth.instance.currentUser!.uid;

                var taskRef = FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(uid)
                    .collection('tasks')
                    .doc();

                try {
                  await taskRef.set({
                    'title': taskTitle,
                    'createdOn': DateTime.now().millisecondsSinceEpoch,
                    'taskId': taskRef.id,
                  });

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.taskSavedMessage)),
                  );
                } catch (e) {
                  final errorMessage = e.toString();
                  final localizedErrorMessage =
                      '${localizations.taskSaveErrorMessage} $errorMessage';
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizedErrorMessage)),
                  );
                }
              },
              child: Text(localizations.saveButtonText),
            ),
          ],
        ),
      ),
    );
  }
}

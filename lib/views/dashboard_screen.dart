import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization package
import 'package:todolist_app/views/add_task_screen.dart';
import 'package:todolist_app/views/login_screen.dart';
import 'package:todolist_app/views/profile_screen.dart';
import 'package:todolist_app/views/update_task_screen.dart';

class DashboardScreen extends StatefulWidget {
  final dynamic setLocale;

  // ignore: non_constant_identifier_names
  Function(Locale locale) {
    throw UnimplementedError();
  }

  const DashboardScreen({super.key, required this.setLocale});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  CollectionReference? tasksRef;

  @override
  void initState() {
    super.initState();

    String uid = FirebaseAuth.instance.currentUser!.uid;

    tasksRef = FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('tasks');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const AddTaskScreen();
          }));
        },
        tooltip: localizations.addTaskButtonTooltip,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(localizations.dashboardTitle,
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ProfileScreen(setLocale: widget.setLocale);
              }));
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(localizations.confirmationDialogTitle),
                    content: Text(localizations.logoutConfirmation),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(localizations.noButtonText),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          await FirebaseAuth.instance.signOut();

                          if (!mounted) return;
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                              return LoginScreen(setLocale: widget.setLocale);
                            }),
                          );
                        },
                        child: Text(localizations.yesButtonText),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: tasksRef?.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child:
                      Text('No Tasks Found')); // Consider localizing this text
            }

            var listOfTasks = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: listOfTasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(listOfTasks[index]['title']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(localizations
                                          .confirmationDialogTitle),
                                      content: Text(
                                          localizations.deleteTaskConfirmation),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child:
                                              Text(localizations.noButtonText),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();

                                            await tasksRef!
                                                .doc(listOfTasks[index]
                                                    ['taskId'])
                                                .delete();

                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(localizations
                                                    .taskDeletedMessage),
                                              ),
                                            );
                                          },
                                          child:
                                              Text(localizations.yesButtonText),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return UpdateTaskScreen(
                                          taskSnapshot: listOfTasks[index]);
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

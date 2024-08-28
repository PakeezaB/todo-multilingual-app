import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization package

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required setLocale});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DocumentSnapshot? userSnapshot;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        currentUser = user;
        getUserDetails();
      } else {
        setState(() {
          currentUser = null;
          userSnapshot = null;
        });
      }
    });
  }

  Future<void> getUserDetails() async {
    if (currentUser != null) {
      String uid = currentUser!.uid;
      userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profileTitle),
      ),
      body: userSnapshot != null
          ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            userSnapshot!['gender'] == 'male'
                                ? 'https://www.example.com/male-avatar.png'
                                : 'https://www.example.com/female-avatar.png',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('${localizations.nameLabel}: ${userSnapshot!['name']}'),
                Text(
                    '${localizations.genderLabel}: ${userSnapshot!['gender']}'),
                Text('${localizations.emailLabel}: ${userSnapshot!['email']}'),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

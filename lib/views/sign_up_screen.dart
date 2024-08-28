import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController nameC, mobileC, emailC, passC, confirmC;
  String selectedGender = 'Male';

  @override
  void initState() {
    nameC = TextEditingController();
    mobileC = TextEditingController();
    emailC = TextEditingController();
    passC = TextEditingController();
    confirmC = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameC.dispose();
    mobileC.dispose();
    emailC.dispose();
    passC.dispose();
    confirmC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context); // Access localized strings

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.signUpTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameC,
              decoration: InputDecoration(
                hintText: localizations.nameHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: mobileC,
              decoration: InputDecoration(
                hintText: localizations.mobileHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailC,
              decoration: InputDecoration(
                hintText: localizations.emailHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passC,
              decoration: InputDecoration(
                hintText: localizations.passwordHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmC,
              decoration: InputDecoration(
                hintText: localizations.confirmPasswordHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CupertinoSegmentedControl<String>(
                    groupValue: selectedGender,
                    children: {
                      'Male': Text(localizations.genderMale),
                      'Female': Text(localizations.genderFemale),
                    },
                    onValueChanged: (newValue) {
                      setState(() {
                        selectedGender = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String name = nameC.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(localizations.provideNameMessage)));
                  return;
                }

                String mobile = mobileC.text.trim();
                String email = emailC.text.trim();
                String pass = passC.text.trim();
                String confirmPass = confirmC.text.trim();

                if (pass != confirmPass) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(localizations.passwordsMustMatchMessage)));
                  return;
                }

                FirebaseAuth auth = FirebaseAuth.instance;

                try {
                  UserCredential userCredential =
                      await auth.createUserWithEmailAndPassword(
                          email: email, password: pass);

                  if (userCredential.user != null) {
                    String uid = userCredential.user!.uid;

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .set({
                      'uid': uid,
                      'name': name,
                      'mobile': mobile,
                      'email': email,
                      'gender': selectedGender,
                      'photo': null,
                      'createdOn': DateTime.now().millisecondsSinceEpoch,
                    });

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(localizations.accountCreatedMessage)));
                  }
                } on FirebaseAuthException catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          '${localizations.loginError}: ${e.message ?? 'Unknown Error'}')));
                }
              },
              child: Text(localizations.registerButtonText),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.alreadyRegisteredText),
            ),
          ],
        ),
      ),
    );
  }
}

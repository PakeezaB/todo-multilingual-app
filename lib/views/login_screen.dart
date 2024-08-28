import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:todolist_app/views/dashboard_screen.dart';
import 'package:todolist_app/views/email_verification.dart';
import 'package:todolist_app/views/forgot_password_screen.dart';
import 'package:todolist_app/views/sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function(Locale) setLocale;

  const LoginScreen({super.key, required this.setLocale});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailC, passC;
  String _selectedLanguage = 'en'; // Default language

  @override
  void initState() {
    emailC = TextEditingController();
    passC = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  void _changeLanguage(String? languageCode) {
    if (languageCode != null) {
      setState(() {
        _selectedLanguage = languageCode;
      });
      widget.setLocale(Locale(languageCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.loginTitle),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            icon: const Icon(Icons.language),
            onChanged: _changeLanguage,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'de', child: Text('German')),
              DropdownMenuItem(value: 'es', child: Text('Spanish')),
              DropdownMenuItem(value: 'ur', child: Text('Urdu')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                FirebaseAuth auth = FirebaseAuth.instance;

                try {
                  UserCredential userCredentials =
                      await auth.signInWithEmailAndPassword(
                          email: emailC.text.trim(),
                          password: passC.text.trim());

                  if (userCredentials.user!.emailVerified) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            DashboardScreen(setLocale: widget.setLocale),
                      ),
                    );
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EmailVerificationScreen(),
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  final errorMessage = e.message ?? 'Unknown error';
                  final localizedErrorMessage =
                      '${localizations.loginError} $errorMessage';
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizedErrorMessage),
                    ),
                  );
                }
              },
              child: Text(localizations.loginButtonText),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ),
                );
              },
              child: Text(localizations.notRegisteredText),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text(localizations.forgotPasswordText),
            ),
          ],
        ),
      ),
    );
  }
}

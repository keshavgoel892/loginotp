import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp(
    title: 'login',
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required String title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTP Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Enter Phone Number',
                prefixText: '+',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendOTP(),
              child: const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOTP() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isNotEmpty) {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) {
          // This callback is called when the phone verification is automatically completed
          // This is for auto-verification like SMS autofill
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle the error
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Verification failed: ${e.message}'),
          ));
        },
        codeSent: (String verificationId, int? resendToken) {
          // Save the verification ID for future reference
          setState(() {
            this.verificationId = verificationId;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP Sent'),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Called when the auto-retrieval timeout is reached
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
        ),
      );
    }
  }
}

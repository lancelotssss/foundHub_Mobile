import 'package:flutter/material.dart';
import '../global/allusers.dart';
import '../theme/foundhub_theme.dart';
class RegisterState extends StatefulWidget {
  const RegisterState({
    super.key
  });
  @override State<RegisterState> createState() => Register();
}
class Register extends State<RegisterState> {
  final key = GlobalKey<FormState>();
  final fname = TextEditingController();
  final lname = TextEditingController();
  final studentId = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  String error = '';
  void createStudent() {
    if(!key.currentState!.validate()) return;
    final normalizedEmail = email.text.trim().toLowerCase();
      if(AllUsers.allUsersList.any((u) => u[
      'email'
    ] == normalizedEmail)) {
      setState(() => error = 'Email is already registered.');
      return;
    }
      if(AllUsers.allUsersList.any((u) => u[
      'studentId'
    ] == studentId.text.trim())) {
      setState(() => error = 'Student ID is already registered.');
      return;
    }
    AllUsers.allUsersList.add({
      'fname': fname.text.trim(), 'lname': lname.text.trim(),
      'fullname': '${fname.text.trim()} ${lname.text.trim()}',
      'studentId': studentId.text.trim(), 'phone': phone.text.trim(),
      'email': normalizedEmail, 'password': password.text, 'role': 'student',
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful. Please log in.')));
    Navigator.pop(context);
  }
  @override void dispose() {
      for(final c in[
      fname,
      lname,
      studentId,
      phone,
      email,
      password,
      confirm
    ]) {
      c.dispose();
    }
    super.dispose();
  }
  Widget field(TextEditingController c, String label, {
    bool obscure = false, TextInputType?type, String?Function(String?)?validate, String?placeholder
  }) => Padding(padding: const EdgeInsets.only(bottom: 12),
  child: TextFormField(controller: c, obscureText: obscure,
  keyboardType: type, decoration: InputDecoration(labelText: label, hintText: placeholder,
  border: const OutlineInputBorder()), validator: validate ??(v) => v == null || v.trim().isEmpty?'$label is required': null),
  );
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Student Registration')),
  body: Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background-register.png'),
  fit: BoxFit.cover)), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500),
  child: Form(key: key, child: ListView(padding: const EdgeInsets.all(18),
    children: [
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(16), boxShadow: const[
      BoxShadow(color: Color(0x16000000), blurRadius: 18)
    ]), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
      const Center(child: FoundHubBrand(height: 64)),
      const SizedBox(height: 14),
      const Text('Create Student Account', textAlign: TextAlign.center,
      style: TextStyle(fontSize: 23, color: FoundHubTheme.navy,
      fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      field(fname, 'First name', placeholder: 'e.g., Juan'),
      field(lname, 'Last name', placeholder: 'e.g., Dela Cruz'),
      field(studentId, 'Student ID', placeholder: 'e.g., 2022-123456'),
      field(phone, 'Phone number', placeholder: 'e.g., 09171234567', type: TextInputType.phone,
      validate: (v) => v == null ||!RegExp(r'^(09\d{9}|\+639\d{9})$').hasMatch(v.trim())?'Enter a valid PH mobile number': null),
      field(email, 'Email', placeholder: 'e.g., juan@student.edu.ph', type: TextInputType.emailAddress,
      validate: (v) => v == null ||!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim())?'Enter a valid email': null),
      field(password, 'Password', placeholder: 'At least 8 characters', obscure: true, validate: (v) => v == null || v.length < 8?'Use at least 8 characters': null),
      field(confirm, 'Confirm password', placeholder: 'Re-enter your password', obscure: true, validate: (v) => v!= password.text?'Passwords do not match': null),
      if(error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),
      const SizedBox(height: 12),
      FilledButton(onPressed: createStudent, child: const Text('Create Account')),
    ])),
  ]))))), );
}

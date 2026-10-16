import 'package:flutter/material.dart';
import '../global/activeuser.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key
  });
  @override State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController phone;
  late final TextEditingController password;
  late final TextEditingController currentPassword;
  @override void initState() {
    super.initState();
    phone = TextEditingController(text: ActiveUser.activeUser['phone']?.toString() ?? '');
    password = TextEditingController();
    currentPassword = TextEditingController();
  }
  @override void dispose() {
    phone.dispose();
    password.dispose();
    currentPassword.dispose();
    super.dispose();
  }
  void save() {
    if(!RegExp(r'^(09\d{9}|\+639\d{9})$').hasMatch(phone.text.trim())) {
      _message('Enter a valid Philippine mobile number.');
      return;
    }
    if(password.text.isNotEmpty) {
        if(currentPassword.text!= ActiveUser.activeUser[
        'password'
      ]) {
        _message('Current password is incorrect.');
        return;
      }
      if(password.text.length < 8) {
        _message('New password must be at least 8 characters.');
        return;
      }
        ActiveUser.activeUser[
        'password'
      ] = password.text;
    }
      ActiveUser.activeUser[
      'phone'
    ] = phone.text.trim();
    password.clear();
    currentPassword.clear();
    _message('Profile updated.');
  }
  void _message(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('My Account')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
    const Icon(Icons.account_circle, size: 76),
    const SizedBox(height: 10),
    Text(ActiveUser.activeUser['fullname']?.toString() ?? 'Student', style: Theme.of(context).textTheme.headlineSmall,
    textAlign: TextAlign.center),
    ListTile(title: const Text('Student ID'), subtitle: Text(ActiveUser.activeUser['studentId']?.toString() ?? 'Not provided')),
    ListTile(title: const Text('Email'), subtitle: Text(ActiveUser.activeUser['email']?.toString() ?? 'Not provided')),
    TextField(controller: phone, keyboardType: TextInputType.phone,
    decoration: const InputDecoration(labelText: 'Phone number', hintText: 'e.g., 09171234567')),
    const SizedBox(height: 18),
    const Text('Change Password (optional)'),
    TextField(controller: currentPassword, obscureText: true,
    decoration: const InputDecoration(labelText: 'Current password', hintText: 'Enter your current password')),
    TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'New password', hintText: 'Enter a new password')),
    const SizedBox(height: 16),
    FilledButton(onPressed: save, child: const Text('Save Changes')),
    const SizedBox(height: 20),
    OutlinedButton.icon(onPressed: () {
      ActiveUser.activeUser = {
      };
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }, icon: const Icon(Icons.logout), label: const Text('Log out')),
  ]));
}

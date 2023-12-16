import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AccountScreen.dart';
import 'DeviceScreen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String? adminName;

  @override
  void initState() {
    super.initState();
    fetchAdminName();
  }

  Future<void> fetchAdminName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final adminData = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();
      setState(() {
        adminName = adminData['name'];
      });
    }
  }

  Stream<bool> getRadarStatusStream() {
    // Assuming you have a 'radar_status' field in your Firebase indicating radar status
    return FirebaseFirestore.instance
        .collection('radar_status')
        .doc('status_document_id')
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VitalCareX',
          style: TextStyle(fontFamily: 'Nexa'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 8, 63, 157),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 90),
                  Text(
                    adminName ?? 'Admin',
                    style: const TextStyle(
                      fontFamily: 'Nexa',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text(
                'Devices',
                style: TextStyle(fontFamily: 'Nexa'),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle Devices screen navigation
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeviceScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_box),
              title: const Text(
                'Accounts',
                style: TextStyle(fontFamily: 'Nexa'),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle Accounts screen navigation
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text(
                'Add New Account',
                style: TextStyle(fontFamily: 'Nexa'),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle Add New Account
                openAddAccountForm(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            DashboardButton(
              title: 'Devices',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeviceScreen()),
                );
              },
            ),
            DashboardButton(
              title: 'Accounts',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountScreen()),
                );
              },
            ),
            DashboardButton(
              title: 'Add New Account',
              onPressed: () {
                openAddAccountForm(context);
              },
            ),
            // Add more buttons as needed
          ],
        ),
      ),
    );
  }

  void openAddAccountForm(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add New Account',
            style: TextStyle(
              fontFamily: 'Nexa',
              color: isDarkMode
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          content: _AddAccountForm(),
        );
      },
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const DashboardButton({
    Key? key,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16.0),
        textStyle: TextStyle(
          fontFamily: 'Nexa',
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Nexa',
          color: Colors.blue,
        ),
      ),
    );
  }
}

class _AddAccountForm extends StatefulWidget {
  @override
  __AddAccountFormState createState() => __AddAccountFormState();
}

class __AddAccountFormState extends State<_AddAccountForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email Address',
              labelStyle: TextStyle(fontFamily: 'Nexa'),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty ||
                  !value.contains('@')) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
            onSaved: (value) {
              _email = value!;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(fontFamily: 'Nexa'),
            ),
            enableSuggestions: false,
            validator: (value) {
              if (value == null || value.isEmpty || value.trim().length < 4) {
                return 'Please enter a valid username (At least 4 characters)';
              }
              return null;
            },
            onSaved: (value) {
              _username = value!;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(fontFamily: 'Nexa'),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().length < 6) {
                return 'Password must be at least 6 characters long.';
              }
              return null;
            },
            onSaved: (value) {
              _password = value!;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                addNewAccount(_email, _password, _username);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Add',
              style: TextStyle(fontFamily: 'Nexa'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addNewAccount(
      String email, String password, String username) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').add({
        'username': username,
        'email': email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account added successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add account: $error'),
        ),
      );
    }
  }
}

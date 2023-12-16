import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vr/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Accounts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<DocumentSnapshot> userAccounts = snapshot.data!.docs;
            return ListView.builder(
              itemCount: userAccounts.length,
              itemBuilder: (context, index) {
                var userData =
                    userAccounts[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(userData['username']),
                  subtitle: Text(userData['email']),
                );
              },
            );
          }
        },
      ),
    );
  }
}

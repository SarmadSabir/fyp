import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String? username;
  String? imageUrl;
  int _currentIndex = 0;
  int? breathRate;
  int? heartRate;
  late DatabaseReference _databaseReference;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _databaseReference = FirebaseDatabase.instance.ref().child('radarData');
    _databaseReference.onValue.listen((event) {
      print('Database update received: ${event.snapshot.value}');
      final data = event.snapshot.value;

      if (data is Map<dynamic, dynamic>) {
        setState(() {
          breathRate = data['BreathRate'] as int?;
          heartRate = data['HeartRate'] as int?;
        });
      }
    });
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        username = userData['username'];
        imageUrl = userData['image_url'];
      });
    }
  }

  void _changeUsername() {
    // Implement logic to change the username
    // Update the username in Firebase and refresh the UI
  }

  void _changePassword() {
    // Implement logic to change the password
    // Update the password in Firebase
  }

  void _changeDisplayPicture() async {
    //final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
    //if (pickedImage != null) {
    // Implement logic to change the display picture
    // Upload the new image to Firebase Storage and update the image URL
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VitalCareX',
          style: TextStyle(
            fontFamily: 'Nexa',
          ),
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.6),
              ),
            ),
            Column(
              children: [
                if (_currentIndex == 0)
                  if (imageUrl != null)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          const SizedBox(height: 66),
                          CircleAvatar(
                            backgroundImage: NetworkImage(imageUrl!),
                            radius: 50,
                          ),
                          const SizedBox(height: 20),
                          if (username != null)
                            Text(
                              '$username',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                                fontFamily: 'Nexa',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            'Breath Rate: ${breathRate ?? "N/A"}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: 'Nexa',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Heart Rate: ${heartRate ?? "N/A"}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: 'Nexa',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 16),
                Center(
                  child: _currentIndex == 0
                      ? Container()
                      : Container(
                          margin: const EdgeInsets.only(top: 50),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (imageUrl != null)
                                CircleAvatar(
                                  backgroundImage: NetworkImage(imageUrl!),
                                  radius: 50,
                                ),
                              const SizedBox(height: 100),
                              Container(
                                width: 300,
                                child: ElevatedButton(
                                  onPressed: _changeUsername,
                                  child: const Text(
                                    'Change Username',
                                    style: TextStyle(
                                      fontFamily: 'Nexa',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: 300,
                                child: ElevatedButton(
                                  onPressed: _changePassword,
                                  child: const Text(
                                    'Change Password',
                                    style: TextStyle(
                                      fontFamily: 'Nexa',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: 300,
                                child: ElevatedButton(
                                  onPressed: _changeDisplayPicture,
                                  child: const Text(
                                    'Change Display Picture',
                                    style: TextStyle(
                                      fontFamily: 'Nexa',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: 300,
                                child: ElevatedButton(
                                  onPressed: _changePassword,
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontFamily: 'Nexa',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

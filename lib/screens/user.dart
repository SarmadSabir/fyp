import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vr/screens/help_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  List<int> heartRateData = [];
  List<int> breathRateData = [];
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeLocalNotifications();
    _databaseReference = FirebaseDatabase.instance.ref().child('radarData');
    _databaseReference.onValue.listen((event) {
      print('Database update received: ${event.snapshot.value}');
      final data = event.snapshot.value;

      if (data is Map<dynamic, dynamic>) {
        setState(() {
          breathRate = data['BreathRate'] as int?;
          heartRate = data['HeartRate'] as int?;

          // Add the new values to the lists
          if (breathRate != null) breathRateData.add(breathRate!);
          if (heartRate != null) heartRateData.add(heartRate!);
        });
      }
    });
  }

  void _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        const InitializationSettings(
      android: initializationSettingsAndroid,
    );
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> onReceiveHeartRateNotification(int heartRate) async {
    if (heartRate < 60) {
      // Heart rate is too low, show a notification
      await showNotification(
        'Low Heart Rate Warning!',
        'Your current heart rate is too low: $heartRate bpm.',
      );
    } else if (heartRate > 100) {
      // Heart rate is too high, show a notification
      await showNotification(
        'High Heart Rate Warning!',
        'Your current heart rate is too high: $heartRate bpm.',
      );
    }
  }

  // This callback is triggered when a notification is selected by the user
  Future<void> onSelectNotification(String? payload) async {
    // Handle notification selection here
  }

  // This callback is triggered when a notification is received while the app is in the foreground
  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Handle received notification while app is in the foreground
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

  Widget _buildVitalBox(String label, int? value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blue,
              fontFamily: 'Nexa',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(left: 6),
            child: Text(
              value != null ? value.toString() : 'N/A',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.red,
                fontFamily: 'Nexa',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(
    List<int> data,
    String title,
    Color lineColor,
    Color textColor,
    Color backgroundColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Nexa',
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        Container(
          height: 140,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: backgroundColor,
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  show: false,
                  horizontalInterval: 10,
                  verticalInterval: 20,
                ),
                titlesData: const FlTitlesData(
                  show: false,
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    width: 0,
                  ),
                ),
                backgroundColor: backgroundColor,
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((entry) {
                      return FlSpot(
                          entry.key.toDouble(), entry.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    belowBarData: BarAreaData(show: false),
                    dotData: const FlDotData(show: false),
                    color: lineColor,
                    isStrokeCapRound: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _changeUsername(String newUsername) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'username': newUsername});

        // Refresh the UI
        setState(() {
          username = newUsername;
        });
      }
    } catch (e) {
      print('Error changing username: $e');
    }
  }

  void _changePassword(String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);

        // Optionally, you can show a success message or handle the UI refresh
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password changed successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {});
      }
    } catch (e) {
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error changing password: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'About Us',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Nexa',
            ),
          ),
          content: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to Our App!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nexa',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'We are final year students who built this app as our FYP project.',
                style: TextStyle(
                  fontFamily: 'Nexa',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Our app measures heartbeat values to help users monitor their health.',
                style: TextStyle(
                  fontFamily: 'Nexa',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Thank you for using our app!',
                style: TextStyle(
                  fontFamily: 'Nexa',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'By: Sarmad Sabir, Mustafa Kamal & Mian Fahad Javed.',
                style: TextStyle(
                  fontFamily: 'Nexa',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'Nexa',
                  ),
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((user) => user == null);
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  void _shareHeartbeatsOnWhatsApp() async {
    try {
      final String message =
          'My current heart rate is $heartRate bpm. Check it out!';
      final String phoneNumber =
          '+923044556379'; // Replace with the recipient's phone number

      final String whatsappUrl =
          "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}";

      // ignore: deprecated_member_use
      if (await canLaunch(whatsappUrl)) {
        // ignore: deprecated_member_use
        await launch(whatsappUrl);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      print('Error sharing heartbeats on WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                  CircleAvatar(
                    backgroundImage: imageUrl != null
                        ? NetworkImage(imageUrl!)
                        : const AssetImage('assets/default_image.png')
                            as ImageProvider<Object>,
                    radius: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username ?? 'Guest',
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
              leading: const Icon(Icons.home_outlined),
              title: const Text(
                'Home',
                style: TextStyle(fontFamily: 'Nexa'),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text(
                'Profile',
                style: TextStyle(fontFamily: 'Nexa'),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text(
                'Help',
                style: TextStyle(fontFamily: 'Nexa'),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HelpPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text(
                'About Us',
                style: TextStyle(fontFamily: 'Nexa'),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAboutUsDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                'Logout',
                style: TextStyle(fontFamily: 'Nexa'),
              ),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0),
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
                            radius: 40,
                          ),
                          const SizedBox(height: 10),
                          if (username != null)
                            Text(
                              '$username',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontFamily: 'Nexa',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 180,
                                child: _buildVitalBox('Heart Rate', heartRate),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 180,
                                child: _buildVitalBox(
                                    'Breathing Rate', breathRate),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(
                            height: 200,
                            child: _buildLineChart(
                              heartRateData,
                              'Heart Rate History',
                              const Color.fromARGB(255, 173, 36, 26),
                              Colors.red,
                              Colors.transparent,
                            ),
                          ),
                          Container(
                            height: 200,
                            child: _buildLineChart(
                              breathRateData,
                              'Breathing Rate History',
                              const Color.fromARGB(255, 15, 100, 169),
                              Colors.blue,
                              Colors.transparent,
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
                                  onPressed: () async {
                                    String? newUsername;
                                    newUsername = await showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Enter New Username',
                                            style: TextStyle(
                                                fontFamily: 'Nexa',
                                                fontSize: 20),
                                          ),
                                          content: TextField(
                                            onChanged: (value) =>
                                                newUsername = value,
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, null),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    fontFamily: 'Nexa',
                                                    fontSize: 14),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, newUsername),
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(
                                                    fontFamily: 'Nexa',
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (newUsername != null &&
                                        newUsername!.isNotEmpty) {
                                      _changeUsername(newUsername!);
                                    }
                                  },
                                  child: Text(
                                    'Change Username',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
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
                                  onPressed: () async {
                                    String? newPassword;
                                    newPassword = await showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Enter New Password',
                                            style: TextStyle(
                                                fontFamily: 'Nexa',
                                                fontSize: 20),
                                          ),
                                          content: TextField(
                                            onChanged: (value) =>
                                                newPassword = value,
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, null),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    fontFamily: 'Nexa',
                                                    fontSize: 14),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, newPassword),
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(
                                                    fontFamily: 'Nexa',
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (newPassword != null &&
                                        newPassword!.isNotEmpty) {
                                      _changePassword(newPassword!);
                                    }
                                  },
                                  child: Text(
                                    'Change Password',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
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
                                  onPressed: () {
                                    _logout(context);
                                  },
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _shareHeartbeatsOnWhatsApp,
              tooltip: 'Share Heartbeats',
              child: const Icon(Icons.share),
            )
          : null,
    );
  }
}

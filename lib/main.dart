import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vr/screens/user.dart';
import 'package:vr/screens/admin.dart';
import 'package:vr/screens/auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VitalCareX',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode:
          ThemeMode.system, // or set it to ThemeMode.light or ThemeMode.dark
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null && user.email == 'sarmadsabir7@gmail.com') {
              return const AdminScreen();
            } else {
              return UserScreen();
            }
          }

          return const AuthScreen();
        },
      ),
    );
  }
}

final ThemeData lightTheme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme:
      ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 55, 68, 165)),
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
    // Customize dark mode based on your preferences
    );

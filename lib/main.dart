import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/shipment_view_model.dart';
import 'viewmodels/auth/auth_view_model.dart';
import 'views/auth/auth_screen.dart';
import 'views/sender/sender_home_screen.dart';
import 'views/traveler/traveler_home_screen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: kIsWeb
        ? DefaultFirebaseOptions.web
        : (Platform.isLinux || Platform.isWindows)
        ? DefaultFirebaseOptions.web
        : DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ShipmentViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          if (authVM.appUser == null) {
            return const AuthScreen();
          }

          if (authVM.appUser!.role == "sender") {
            return const SenderHomeScreen();
          } else {
            return const TravelerHomeScreen();
          }
        },
      ),
    );
  }
}

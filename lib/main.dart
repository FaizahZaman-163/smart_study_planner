import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_gate.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://llbhumbbtswmchrhcjxh.supabase.co',
    anonKey: 'sb_publishable_Ob1UMKYeIZP3j6mATquYyQ_ha8NO8R0',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Study Planner',
      home: const AuthGate(),
    );
  }
}

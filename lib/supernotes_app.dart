import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supanotes/ui/pages/home_page.dart';
import 'package:supanotes/ui/pages/notes_page.dart';

class SupernotesApp extends StatelessWidget {
  static const supabaseGreen = Color.from(alpha: 1, red: 0.396, green: 0.851, blue: 0.647);
  static const bg = Color(0xff1c1c1e);
 
  const SupernotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supanotes',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: supabaseGreen,
          brightness: Brightness.dark,
          primary: supabaseGreen,
        ),
        scaffoldBackgroundColor: bg,
      ),
      // Automatically route users who have an active restored session
      home: Supabase.instance.client.auth.currentSession != null
          ? const NotesPage()
          : const HomePage(),
    );
  }
}
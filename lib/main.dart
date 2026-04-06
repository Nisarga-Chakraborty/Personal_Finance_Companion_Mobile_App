import 'package:assignment/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TabsScreen(),
      title: 'Finance App',
      theme: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color.fromARGB(255, 4, 79, 141),
          background: Colors.yellow,
          onPrimary: Colors.white,
          onBackground: Colors.black,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueGrey,
          background: Colors.black,
          onPrimary: Colors.black,
          onBackground: Colors.white,
        ),
      ),
    );
  }
}

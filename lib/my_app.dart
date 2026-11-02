
import 'package:flutter/material.dart';
import 'package:pet_app/providers/pet_provider.dart';
import 'package:provider/provider.dart';
import 'views/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return PetProvider();
      },
      child: MaterialApp(
        title: 'Pet App',
        theme: ThemeData(
          colorScheme: .fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Pet Sanctuary'),
      ),
    );
  }
}

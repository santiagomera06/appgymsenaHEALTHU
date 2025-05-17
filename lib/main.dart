import 'package:flutter/material.dart';
import 'package:healthu/routes/desafios_routes.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HEALTHU',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: DesafiosRoutes.desafios,
      onGenerateRoute: DesafiosRoutes.generateRoute,
    );
  }
}
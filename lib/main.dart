import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/add_edit_task_screen.dart';
import 'screens/about_screen.dart';
import 'providers/task_provider.dart';
import 'screens/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🔥 Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado com sucesso!');
  } catch (e) {
    print('❌ Erro ao inicializar Firebase: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: const CardTheme(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0, 
              vertical: 16.0,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/add': (context) => const AddEditTaskScreen(),
          '/edit': (context) => const AddEditTaskScreen(isEditing: true),
          '/about': (context) => const AboutScreen(),
          '/search': (context) => const SearchScreen(),
        },
      ),
    );
  }
} 
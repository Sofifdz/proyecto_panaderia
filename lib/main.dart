import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:proyecto_panaderia/Vista/VLogin.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VVentasUsuarios.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VVentas.dart';
import 'package:proyecto_panaderia/Controlador/SessionManager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _pantallaInicial = const Center(child: CircularProgressIndicator());

  @override
  void initState() {
    super.initState();
    verificarSesion();
  }

  void verificarSesion() async {
    final role = await SessionManager.obtenerRole();
    final userId = await SessionManager.obtenerUserId();
    final username = await SessionManager.obtenerUsername();
  //si se reinicia la app pero no se ha cerrado sesion ingresa a la sesion activa
    setState(() {
      if (role == 'Administrador' && userId != null && username != null) {
        _pantallaInicial = VVentasUsuarios(usuarioId: userId, username: username);
      } else if (role == 'Empleado' && userId != null && username != null) {
        _pantallaInicial = VVentas(usuarioId: userId, username: username);
      } else {
        _pantallaInicial = Login();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      locale: const Locale('es'),
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _pantallaInicial,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/CajaController.dart';
import 'package:proyecto_panaderia/Controlador/LoginController.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VVentasUsuarios.dart';
import 'package:proyecto_panaderia/Vista/Componentes/ShowDialogCaja.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VVentas.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  bool isVisible = false;
  final formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    final email = _emailcontroller.text.trim();
    final password = _passwordcontroller.text;

    try {
      final usuario = await LoginController.iniciarSesion(email, password);
      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario o contraseña incorrectos")),
        );
        return;
      }

      if (mounted) {
        if (usuario.role == 'Administrador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VVentasUsuarios(
                username: usuario.username,
                usuarioId: usuario.id,
              ),
            ),
          );
        } else if (usuario.role == 'Empleado') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VVentas(
                usuarioId: usuario.id,
                username: usuario.username,
              ),
            ),
          );

          final caja = CajaController();
          ShowDialogCaja.show(
            context: context,
            usuarioId: usuario.id,
            username: usuario.username,
            abroOcierro: 'Abro con',
            txtBoton: 'Comenzar',
            tipoOperacion: "abrir",
            controller: caja,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDarkMode
            ? const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(40.0, 150.0, 40.0, 40.0),
                child: Container(
                  height: 600,
                  padding: const EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1E1E1E)
                        : const Color.fromARGB(255, 126, 178, 202),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Icon(
                            Icons.storefront_outlined,
                            color: isDarkMode ? Colors.white70 : Colors.white,
                            size: 100,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            "Iniciar Sesión",
                            style: GoogleFonts.roboto(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Divider(
                          color: isDarkMode
                              ? Colors.white30
                              : Colors.black.withOpacity(0.3),
                          thickness: 1.2,
                          indent: 10,
                          endIndent: 10,
                        ),
                        const SizedBox(height: 20),
                        txt(context, "Correo", isDarkMode),
                        const SizedBox(height: 5),
                        txtField(
                          context,
                          _emailcontroller,
                          Icon(Icons.mail,
                              color: isDarkMode ? Colors.white70 : null),
                          null,
                          false,
                          isDarkMode,
                        ),
                        const SizedBox(height: 20),
                        txt(context, "Contraseña", isDarkMode),
                        const SizedBox(height: 5),
                        txtField(
                          context,
                          _passwordcontroller,
                          Icon(Icons.password,
                              color: isDarkMode ? Colors.white70 : null),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isVisible = !isVisible;
                              });
                            },
                            icon: Icon(
                              isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: isDarkMode ? Colors.white70 : null,
                            ),
                          ),
                          !isVisible,
                          isDarkMode,
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA6C89A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                await _login();
                              },
                              child: Text(
                                "Iniciar",
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget txt(BuildContext context, String texto, bool isDarkMode) {
    return Text(
      texto,
      style: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget txtField(
    BuildContext context,
    TextEditingController variable,
    Icon icono,
    IconButton? iconofinal,
    bool yesOrNo,
    bool isDarkMode,
  ) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Campo obligatorio";
        }
        return null;
      },
      controller: variable,
      obscureText: yesOrNo,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        prefixIcon: icono,
        suffixIcon: iconofinal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      ),
    );
  }
}

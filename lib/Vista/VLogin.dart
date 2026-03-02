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

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  bool isVisible = false;
  final formKey = GlobalKey<FormState>();

  late AnimationController _animController;
  late Animation<Offset> _slideLogo;
  late Animation<Offset> _slideFields;
  late Animation<double> _fadeFields;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _slideLogo = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideFields = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _fadeFields = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
  final size = MediaQuery.of(context).size;

  const backgroundColor = Color(0xFFF4F6F8);
  const appBarColor = Color(0xFF1F2933);
  const primaryBlue = Color(0xFF2563EB);
  const mainText = Color(0xFF111827);
  const secondaryText = Color(0xFF6B7280);

  return Scaffold(
    backgroundColor: backgroundColor,
    body: Stack(
      children: [
     
        Container(
          height: size.height * 0.25,
          decoration: const BoxDecoration(
            color: appBarColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),

        Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SlideTransition(
                  position: _slideLogo,
                  child: Container(
                    margin: const EdgeInsets.only(top: 40),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: primaryBlue,
                      size: 90,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                SlideTransition(
                  position: _slideFields,
                  child: FadeTransition(
                    opacity: _fadeFields,
                    child: Container(
                      width: size.width * 0.85,
                      padding: const EdgeInsets.symmetric(
                          vertical: 40, horizontal: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            Text(
                              "Iniciar Sesión",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: mainText,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Accede al sistema de ventas",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 15,
                                color: secondaryText,
                              ),
                            ),

                            const SizedBox(height: 35),

                            _buildTextField(
                              label: "Correo electrónico",
                              controller: _emailcontroller,
                              icon: Icons.mail_outline,
                              fieldBackground: const Color(0xFFF9FAFB),
                              iconColor: primaryBlue,
                            ),

                            const SizedBox(height: 20),

                            _buildTextField(
                              label: "Contraseña",
                              controller: _passwordcontroller,
                              icon: Icons.lock_outline,
                              isPassword: true,
                              toggleVisible: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              visible: isVisible,
                              fieldBackground: const Color(0xFFF9FAFB),
                              iconColor: primaryBlue,
                            ),

                            const SizedBox(height: 35),

                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: _login,
                                child: Text(
                                  "INGRESAR",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool isDarkMode = false,
    VoidCallback? toggleVisible,
    bool visible = false,
    Color? fieldBackground,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? !visible : false,
          validator: (value) =>
              value == null || value.isEmpty ? "Campo obligatorio" : null,
          style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: iconColor),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      visible ? Icons.visibility : Icons.visibility_off,
                      color: iconColor,
                    ),
                    onPressed: toggleVisible,
                  )
                : null,
            filled: true,
            fillColor: fieldBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

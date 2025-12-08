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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Colores adaptados según el modo
    final headerGradientColors = isDarkMode
        ? [Colors.green.shade900, Colors.green.shade700]
        : [Colors.green.shade400, Colors.green.shade200];

    final fieldBackground =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
    final containerBackground =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final iconColor = isDarkMode ? Colors.green.shade300 : Colors.green.shade700;
    final buttonColor =
        isDarkMode ? Colors.green.shade700 : Colors.green.shade300;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDarkMode ? Colors.black : Colors.grey[50],
        child: Stack(
          children: [
            // Header decorativo con gradiente verde
            Container(
              height: size.height * 0.25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: headerGradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
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
                          color: containerBackground,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black54
                                  : Colors.black26,
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          color: iconColor,
                          size: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SlideTransition(
                      position: _slideFields,
                      child: FadeTransition(
                        opacity: _fadeFields,
                        child: Container(
                          width: size.width * 0.85,
                          padding: const EdgeInsets.symmetric(
                              vertical: 40, horizontal: 25),
                          decoration: BoxDecoration(
                            color: containerBackground,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    isDarkMode ? Colors.black54 : Colors.black12,
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
                                  "Bienvenido",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Inicia sesión para continuar",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                _buildTextField(
                                  label: "Correo",
                                  controller: _emailcontroller,
                                  icon: Icons.mail_outline,
                                  isDarkMode: isDarkMode,
                                  fieldBackground: fieldBackground,
                                  iconColor: iconColor,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  label: "Contraseña",
                                  controller: _passwordcontroller,
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  isDarkMode: isDarkMode,
                                  toggleVisible: () {
                                    setState(() {
                                      isVisible = !isVisible;
                                    });
                                  },
                                  visible: isVisible,
                                  fieldBackground: fieldBackground,
                                  iconColor: iconColor,
                                ),
                                const SizedBox(height: 35),
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 5,
                                    ),
                                    onPressed: _login,
                                    child: Text(
                                      "Ingresar",
                                      style: GoogleFonts.roboto(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
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

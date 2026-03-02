import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/UsuarioController.dart';

class VAgregarPersonal extends StatefulWidget {
  final String usuarioId;
  final String username;
  const VAgregarPersonal({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VAgregarPersonal> createState() => _VAgregarPersonalState();
}

class _VAgregarPersonalState extends State<VAgregarPersonal> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isVisible = false;
  String? _selectedValue = "Empleado";

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Agregar Personal',
          style: GoogleFonts.montserrat(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _buildTextField(
                  usernameController,
                  "Nombre de usuario",
                  "Nombre es requerido",
                  primaryBlue,
                  mainText,
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  emailController,
                  "Email",
                  "Email es requerido",
                  primaryBlue,
                  mainText,
                  icon: Icons.email,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  passwordController,
                  "Contraseña",
                  "Contraseña es requerida",
                  primaryBlue,
                  mainText,
                  icon: Icons.lock,
                  isPassword: true,
                  isVisible: isVisible,
                  toggleVisibility: () {
                    setState(() => isVisible = !isVisible);
                  },
                ),
                const SizedBox(height: 25),
                _buildDropdown(primaryBlue, mainText),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                UsuarioController.registrarUsuario(
                  context: context,
                  email: emailController.text.trim(),
                  username: usernameController.text.trim(),
                  password: passwordController.text.trim(),
                  role: _selectedValue!,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Por favor completa todos los campos."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              "GUARDAR",
              style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String errorText,
    Color primaryBlue,
    Color mainText, {
    IconData? icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      style: GoogleFonts.roboto(color: mainText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.roboto(color: mainText),
        prefixIcon: icon != null ? Icon(icon, color: primaryBlue) : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: primaryBlue,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      validator: (value) => (value == null || value.isEmpty) ? errorText : null,
    );
  }

  Widget _buildDropdown(Color primaryBlue, Color mainText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: _selectedValue,
        underline: const SizedBox(),
        items: [
          DropdownMenuItem(
            value: "Empleado",
            child: Center(child: Text("Empleado", style: GoogleFonts.roboto(fontSize: 16, color: mainText))),
          ),
          DropdownMenuItem(
            value: "Administrador",
            child: Center(child: Text("Administrador", style: GoogleFonts.roboto(fontSize: 16, color: mainText))),
          ),
        ],
        onChanged: (String? newValue) => setState(() => _selectedValue = newValue),
      ),
    );
  }
}
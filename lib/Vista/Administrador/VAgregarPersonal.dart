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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.green.shade900, Colors.green.shade700]
                  : [Colors.green.shade400, Colors.green.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : Colors.black87, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Agregar Personal',
          style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save, size: 30, color: isDark ? Colors.greenAccent : Colors.green),
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
                  SnackBar(
                    content: Text("Por favor completa todos los campos."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _buildTextField(usernameController, "Nombre de usuario", "Nombre es requerido", icon: Icons.person),
                const SizedBox(height: 20),
                _buildTextField(emailController, "Email", "Email es requerido", icon: Icons.email),
                const SizedBox(height: 20),
                _buildTextField(passwordController, "Contraseña", "Contraseña es requerida",
                    icon: Icons.lock, isPassword: true, isVisible: isVisible, toggleVisibility: () {
                  setState(() => isVisible = !isVisible);
                }),
                const SizedBox(height: 25),
                _buildDropdown(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String errorText,
      {IconData? icon, bool isPassword = false, bool isVisible = false, VoidCallback? toggleVisibility}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      style: GoogleFonts.montserrat(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: isDark ? Colors.white70 : Colors.black54),
        prefixIcon: icon != null ? Icon(icon, color: isDark ? Colors.white70 : Colors.black54) : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: isDark ? Colors.white70 : Colors.black54),
                onPressed: toggleVisibility,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        filled: true,
      ),
      validator: (value) => (value == null || value.isEmpty) ? errorText : null,
    );
  }

  Widget _buildDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        border: Border.all(color: Colors.green, width: 1.5),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: _selectedValue,
        underline: const SizedBox(),
        items: [
          DropdownMenuItem(
            value: "Empleado",
            child: Center(child: Text("Empleado", style: GoogleFonts.montserrat(fontSize: 18))),
          ),
          DropdownMenuItem(
            value: "Administrador",
            child: Center(child: Text("Administrador", style: GoogleFonts.montserrat(fontSize: 18))),
          ),
        ],
        onChanged: (String? newValue) {
          setState(() => _selectedValue = newValue);
        },
      ),
    );
  }
}

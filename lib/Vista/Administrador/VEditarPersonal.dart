import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/EditarPersonalController.dart';
import 'package:proyecto_panaderia/Modelo/Usuarios.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VPersonal.dart';

class VEditarPersonal extends StatefulWidget {
  final Usuarios user;
  final String usuarioId;
  final String username;
  final Future<void> Function(Usuarios) updateUser;

  const VEditarPersonal({
    Key? key,
    required this.user,
    required this.updateUser,
    required this.usuarioId,
    required this.username,
  }) : super(key: key);

  @override
  State<VEditarPersonal> createState() => _VEditarPersonalState();
}

class _VEditarPersonalState extends State<VEditarPersonal> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final formKey = GlobalKey<FormState>();
  bool isVisible = false;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.user.email);
    usernameController = TextEditingController(text: widget.user.username);
    passwordController = TextEditingController(text: widget.user.password);
    _selectedValue = widget.user.role;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Editar Personal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
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
        actions: [
          EditarPersonalController.Editar(
            context,
            formKey,
            widget,
            emailController,
            usernameController,
            passwordController,
            _selectedValue,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email (disabled)
                  TextFormField(
                    controller: emailController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white12 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 25),

                  // Username
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white12 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Usuario es requerido";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),

                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white12 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password es requerido";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),

                  // Role Dropdown
                  Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedValue,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: "Empleado",
                          child: Center(
                              child: Text("Empleado",
                                  style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      color: isDark ? Colors.white : Colors.black87))),
                        ),
                        DropdownMenuItem(
                          value: "Administrador",
                          child: Center(
                              child: Text("Administrador",
                                  style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      color: isDark ? Colors.white : Colors.black87))),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedValue = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

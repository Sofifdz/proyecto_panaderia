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
          'Editar Personal',
          style: GoogleFonts.montserrat(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
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
              
                TextFormField(
                  controller: emailController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: GoogleFonts.roboto(color: mainText),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF2563EB)),
                  ),
                  style: GoogleFonts.roboto(color: mainText),
                ),
                const SizedBox(height: 20),

               
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    labelStyle: GoogleFonts.roboto(color: mainText),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF2563EB)),
                  ),
                  style: GoogleFonts.roboto(color: mainText),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Usuario es requerido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

               
                TextFormField(
                  controller: passwordController,
                  obscureText: !isVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: GoogleFonts.roboto(color: mainText),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF2563EB)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: primaryBlue,
                      ),
                      onPressed: () => setState(() => isVisible = !isVisible),
                    ),
                  ),
                  style: GoogleFonts.roboto(color: mainText),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password es requerido";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

              
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
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
                                    fontSize: 16, color: mainText))),
                      ),
                      DropdownMenuItem(
                        value: "Administrador",
                        child: Center(
                            child: Text("Administrador",
                                style: GoogleFonts.roboto(
                                    fontSize: 16, color: mainText))),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedValue = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
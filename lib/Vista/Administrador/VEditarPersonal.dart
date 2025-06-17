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
  var usernameController;
  var emailController;
  var passwordController;
  var rolController;
  var idcontroller;
  final formKey = GlobalKey<FormState>();

  bool isVisible = false;

  String? _selectedValue = "Empleado";

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(160, 133, 203, 144),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Color.fromARGB(255, 81, 81, 81),
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
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
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 50.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nombre es requerido";
                    }
                    return null;
                  },
                  enabled: false,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Usuario es requerido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
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
                  obscureText: !isVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password es requerido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                Container(
                  width: 400,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green,
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedValue,
                    items: [
                      DropdownMenuItem<String>(
                        value: "Empleado",
                        child: Center(
                            child: Text("Empleado",
                                style: GoogleFonts.roboto(fontSize: 20))),
                      ),
                      DropdownMenuItem<String>(
                        value: "Administrador",
                        child: Center(
                            child: Text("Administrador",
                                style: GoogleFonts.roboto(fontSize: 20))),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedValue = newValue;
                      });
                      print('Seleccionado: $newValue');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

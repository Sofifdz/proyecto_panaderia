import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/UsuarioController.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VPersonal.dart';

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
  final _emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isVisible = false;

  String? _selectedValue = "Empleado";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(160, 133, 203, 144),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Color.fromARGB(255, 81, 81, 81),
              size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.save,
                size: 30,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(150, 37, 255, 44)
                    : Colors.green,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  UsuarioController.registrarUsuario(
                    context: context,
                    email: _emailController.text.trim(),
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
              }),
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
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Nombre de usuario",
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
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email es requerido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
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
                      return "Contraseña es requerida";
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

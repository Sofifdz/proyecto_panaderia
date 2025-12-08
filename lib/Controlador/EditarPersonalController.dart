import 'package:flutter/material.dart';
import 'package:proyecto_panaderia/Modelo/Usuarios.dart';

class EditarPersonalController {
  static Widget Editar(
    BuildContext context,
    GlobalKey<FormState> formKey,
    dynamic widget,
    TextEditingController emailController,
    TextEditingController usernameController,
    TextEditingController passwordController,
    String? selectedValue,
  ) {
    return IconButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          final editUser = Usuarios(
            id: widget.user.id,
            email: emailController.text,
            username: usernameController.text,
            password: passwordController.text,
            role: selectedValue ?? "Empleado",
          );

          try {
            await widget.updateUser(editUser);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Usuario editado correctamente")),
            );
            Navigator.pop(context);
          } catch (e) {
            print("Error al editar usuario: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Falla al editar usuario")),
            );
          }
        }
      },
      icon: Icon(
        Icons.check,
        size: 30,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(150, 37, 255, 44)
            : Colors.green,
      ),
    );
  }
}

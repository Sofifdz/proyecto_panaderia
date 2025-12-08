import 'package:flutter/material.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';
import 'package:proyecto_panaderia/Controlador/AlmacenController.dart';

class EditarProductoController {
  static Widget editar({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required dynamic widget,
    required TextEditingController productonameController,
    required TextEditingController precioController,
    required TextEditingController existenciaController,
  }) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          final editProduct = Productos(
            id: widget.producto.id,
            productoname: productonameController.text,
            precio: int.parse(precioController.text),
            existencias: int.parse(existenciaController.text),
          );

          try {
            final controller = AlmacenController();
            await controller.actualizarProducto(editProduct);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Producto editado correctamente")),
            );
            Navigator.pop(context);
          } catch (e) {
            print("Error al editar producto: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Falla al editar producto")),
            );
          }
        }
      },
      icon: Icon(
        Icons.check,
        size: 30,
        color: theme.brightness == Brightness.dark
            ? const Color.fromARGB(150, 37, 255, 44)
            : Colors.green,
      ),
    );
  }
}

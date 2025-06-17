import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/UsuarioController.dart';
import 'package:proyecto_panaderia/Controlador/AlmacenController.dart';
import 'package:proyecto_panaderia/Modelo/Usuarios.dart';
import 'package:proyecto_panaderia/Modelo/Pedidos.dart';
import 'package:proyecto_panaderia/Modelo/Productos.dart';

class DeleteDialog {
  static Future<bool?> showDeleteDialog<T>({
    required BuildContext context,
    required T item,
    required Function onDelete,
  }) async {
    String mensaje = "";
    Color eliminarColor = const Color.fromARGB(255, 81, 81, 81);

    Future<void> eliminar() async {
      if (item is Usuarios) {
        final eliminar = UsuarioController();
        await eliminar.eliminarUsuario(item.id);
      } else if (item is Pedidos) {
        await FirebaseFirestore.instance
            .collection('pedidos')
            .doc(item.NoPedido)
            .delete();
      } else if (item is Productos) {
        final controller = AlmacenController();
        await controller.eliminarProducto(item.id);
      }
    }

    if (item is Usuarios) {
      mensaje = "¿Estás seguro de que deseas eliminar a ${item.username}?";
    } else if (item is Pedidos) {
      mensaje =
          "¿Estás seguro de que deseas eliminar el pedido de ${item.cliente}?";
      eliminarColor = Colors.red;
    } else if (item is Productos) {
      mensaje = "¿Estás seguro de que deseas eliminar ${item.productoname}?";
    } else {
      return null; 
    }

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          content: Text(
            mensaje,
            style: GoogleFonts.montserrat(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? Colors.white : const Color.fromARGB(255, 81, 81, 81),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  color: isDark
                      ? Colors.white70
                      : const Color.fromARGB(255, 81, 81, 81),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await eliminar();
                onDelete();
                Navigator.pop(context, true);
              },
              child: Text(
                "Eliminar",
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                 color: isDark
                      ? Colors.white70
                      : const Color.fromARGB(255, 81, 81, 81),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

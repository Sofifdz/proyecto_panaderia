import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/CajaController.dart';

class ShowDialogCaja {
  static Future<void> show({
    required BuildContext context,
    required String usuarioId,
    required String username,
    required String abroOcierro,
    required String txtBoton,
    required String tipoOperacion,
    required CajaController controller,
  }) async {
    TextEditingController montoController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: isDark
              ? const Color(0xFF2C2C2E)
              : const Color(0xFFD0E3ED),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      size: 25,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              Text(
                "Hola $username!",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                abroOcierro,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: montoController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "\$0",
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF3A3A3C)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 116, 181, 119),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 10),
                ),
                onPressed: () async {
                  double monto = double.tryParse(montoController.text) ?? 0;
                  bool result = false;

                  if (tipoOperacion == 'abrir') {
                    result = await controller.abrirCaja(usuarioId, monto);
                  } else if (tipoOperacion == 'cerrar') {
                    result = await controller.cerrarCaja(usuarioId, monto);
                  }

                  if (result) {
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error al realizar la operación."),
                      ),
                    );
                  }
                },
                child: Text(
                  txtBoton,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

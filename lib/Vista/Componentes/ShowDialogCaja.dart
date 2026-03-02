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

  const backgroundColor = Color(0xFFF4F6F8);
  const appBarColor = Color(0xFF1F2933);
  const primaryBlue = Color(0xFF2563EB);
  const mainText = Color(0xFF111827);

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 18, horizontal: 20),
                decoration: const BoxDecoration(
                  color: appBarColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Caja",
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [

                    Text(
                      "Hola $username",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: mainText,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      abroOcierro,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: mainText,
                      ),
                    ),

                    const SizedBox(height: 15),

                 
                    TextField(
                      controller: montoController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: mainText,
                      ),
                      decoration: InputDecoration(
                        hintText: "\$0.00",
                        hintStyle: GoogleFonts.roboto(
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          double monto =
                              double.tryParse(montoController.text) ?? 0;
                          bool result = false;

                          if (tipoOperacion == 'abrir') {
                            result = await controller
                                .abrirCaja(usuarioId, monto);
                          } else if (tipoOperacion == 'cerrar') {
                            result = await controller
                                .cerrarCaja(usuarioId, monto);
                          }

                          if (result) {
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Error al realizar la operación."),
                              ),
                            );
                          }
                        },
                        child: Text(
                          txtBoton.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}

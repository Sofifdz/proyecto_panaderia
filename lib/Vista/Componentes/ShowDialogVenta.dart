import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogPago {
  static void mostrar({
    required BuildContext context,
    required double total,
    required VoidCallback onVentaConfirmada,
     VoidCallback? onResetCards,
  }) {
    final TextEditingController pagoController = TextEditingController();
    double cambio = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
           
            void calcularCambio(String valor) {
              final pago = double.tryParse(valor);
              if (pago != null && pago >= total) {
                setState(() {
                  cambio = pago - total;
                });
              } else {
                setState(() {
                  cambio = 0;
                });
              }
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2C2C2C)
                  : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text(
                "Pagar venta",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color.fromARGB(255, 81, 81, 81),
                  fontSize: 25
                ),
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: pagoController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Cantidad recibida",
                        labelStyle: GoogleFonts.montserrat(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: calcularCambio,
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Text(
                        "Total a pagar: \$${total.toStringAsFixed(2)}",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (cambio > 0)
                      Center(
                        child: Text(
                          "Cambio: \$${cambio.toStringAsFixed(2)}",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.lightGreenAccent
                                : Colors.green[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancelar",
                    style: GoogleFonts.montserrat(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      
                    ),
                    
                  ),
                  onPressed: () {
                    final pago = double.tryParse(pagoController.text);
                    if (pago == null || pago < total) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Monto insuficiente")),
                      );
                      return;
                    }
                    Navigator.of(context).pop();
                    onVentaConfirmada();
                  },
                  child: Text(
                    "Confirmar",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

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

    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);
    const backgroundColor = Color(0xFFF4F6F8);

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

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "CONFIRMAR PAGO",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: mainText,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "TOTAL A PAGAR",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: GoogleFonts.montserrat(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: mainText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    TextField(
                      controller: pagoController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: calcularCambio,
                      style: GoogleFonts.roboto(color: mainText),
                      decoration: InputDecoration(
                        hintText: "Cantidad recibida",
                        prefixIcon:
                            const Icon(Icons.attach_money, color: primaryBlue),
                        filled: true,
                        fillColor: backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (cambio > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "CAMBIO",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                            Text(
                              "\$${cambio.toStringAsFixed(2)}",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(),
                            child: Text(
                              "CANCELAR",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                onVentaConfirmada();
                              },
                              child: Text(
                                "CONFIRMAR",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
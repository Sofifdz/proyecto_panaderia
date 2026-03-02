import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Controlador/CajaController.dart';
import 'package:proyecto_panaderia/Controlador/PagoController.dart';

class Vagregarpago extends StatefulWidget {
  final String usuarioId;
  final String username;

  const Vagregarpago({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<Vagregarpago> createState() => _VagregarpagoState();
}

class _VagregarpagoState extends State<Vagregarpago> {
  final _cajaController = CajaController();
  final _pagosController = PagoController();
  final _formKey = GlobalKey<FormState>();

  final proveedorController = TextEditingController();
  final descripcionController = TextEditingController();
  final montoController = TextEditingController();
  DateTime date = DateTime.now();
  double totalRestante = 0;

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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Agregar Gasto",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(proveedorController, "Proveedor", "Proveedor es requerido"),
                        const SizedBox(height: 20),
                        _buildTextField(
                          descripcionController,
                          "Descripción",
                          "Descripción es requerida",
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          montoController,
                          "Monto",
                          "Monto es requerido",
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                          onChanged: (_) => _calcularRestante(),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Monto ingresado:",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  color: mainText,
                                ),
                              ),
                              Text(
                                "\$${totalRestante.toStringAsFixed(2)}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildDatePicker(primaryBlue, mainText),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _guardarPago,
                child: Text(
                  "Guardar Gasto",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calcularRestante() {
    final monto = double.tryParse(montoController.text) ?? 0;
    setState(() {
      totalRestante = monto;
    });
  }

  Widget _buildTextField(TextEditingController controller, String label, String errorText,
      {int? maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      List<TextInputFormatter>? inputFormatters,
      Function(String)? onChanged}) {
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);
    const backgroundColor = Color(0xFFF4F6F8);

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: GoogleFonts.roboto(color: mainText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.roboto(color: mainText),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
      validator: (value) => (value == null || value.isEmpty) ? errorText : null,
    );
  }

  Widget _buildDatePicker(Color primaryBlue, Color mainText) {
    const backgroundColor = Color(0xFFF4F6F8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            "Fecha de gasto:",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w500,
              color: mainText,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (selectedDate != null) {
                TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: date.hour, minute: date.minute),
                );

                if (selectedTime != null) {
                  setState(() {
                    date = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                  });
                }
              }
            },
            child: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(date),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _guardarPago() async {
    if (!_formKey.currentState!.validate()) return;

    final datosCaja = await _cajaController.obtenerCajaActual(widget.usuarioId);
    final cajaId = datosCaja['cajaId'];

    if (cajaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay caja activa para este usuario")),
      );
      return;
    }

    double? monto = double.tryParse(montoController.text);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa un monto válido")),
      );
      return;
    }

    try {
      await _pagosController.guardarPago(
        usuarioId: widget.usuarioId,
        nombre: proveedorController.text.trim(),
        descripcion: descripcionController.text.trim(),
        monto: monto,
        fecha: date,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pago guardado exitosamente")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e")),
      );
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_panaderia/Controlador/PedidoController.dart';

class VAgregarPedidoE extends StatefulWidget {
  final String usuarioId;
  final String username;

  const VAgregarPedidoE({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VAgregarPedidoE> createState() => _VAgregarPedidoEState();
}

class _VAgregarPedidoEState extends State<VAgregarPedidoE> {
  final PedidoController _pedidoController = PedidoController();

  final clienteController = TextEditingController();
  final telefonoController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();
  final anticipoController = TextEditingController();

  DateTime date = DateTime.now();
  double totalRestante = 0;

  final formKey = GlobalKey<FormState>();

  void calcularRestante() {
    final precio = double.tryParse(precioController.text) ?? 0;
    final abono = double.tryParse(anticipoController.text) ?? 0;

    setState(() {
      totalRestante = precio - abono;
      if (totalRestante < 0) totalRestante = 0;
    });
  }

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
          "Agregar Pedido",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: clienteController,
                    label: "Cliente",
                    errorText: "Cliente es requerido",
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: telefonoController,
                    label: "Teléfono",
                    errorText: "Teléfono requerido",
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: descripcionController,
                    label: "Descripción",
                    errorText: "Descripción es requerida",
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),

                  const SizedBox(height: 20),

             
                  _buildTextField(
                    controller: precioController,
                    label: "Precio Total",
                    errorText: "Precio es requerido",
                    keyboardType: TextInputType.number,
                    onChanged: (_) => calcularRestante(),
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  ),

                  const SizedBox(height: 20),

    
                  _buildTextField(
                    controller: anticipoController,
                    label: "Anticipo (Abono)",
                    errorText: "Anticipo requerido",
                    keyboardType: TextInputType.number,
                    onChanged: (_) => calcularRestante(),
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
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
                          "Total restante:",
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

                  const SizedBox(height: 30),

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
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        final precio = double.tryParse(precioController.text) ?? 0;
                        final abono = double.tryParse(anticipoController.text) ?? 0;

                        if (abono > precio) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "El anticipo no puede ser mayor al total"),
                            ),
                          );
                          return;
                        }

                        _pedidoController.guardarPedido(
                          context: context,
                          cliente: clienteController.text,
                          telefono: telefonoController.text,
                          descripcion: descripcionController.text,
                          precio: precioController.text,
                          abono: abono,
                          fecha: date,
                        );
                      },
                      child: Text(
                        "Guardar Pedido",
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String errorText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
    TextInputAction? textInputAction,
  }) {
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction ?? TextInputAction.done,
      onChanged: onChanged,
      style: GoogleFonts.roboto(color: mainText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.roboto(color: mainText),
        filled: true,
        fillColor: const Color(0xFFF4F6F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: primaryBlue,
            width: 1.5,
          ),
        ),
      ),
      validator: (value) => (value == null || value.isEmpty) ? errorText : null,
    );
  }

  Widget _buildDatePicker(Color primaryBlue, Color mainText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            "Fecha de entrega:",
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
}
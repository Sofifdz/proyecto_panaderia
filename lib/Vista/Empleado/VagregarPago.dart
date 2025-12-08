import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
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

  final TextEditingController proveedorController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController montoController = TextEditingController();
  final fechaController = BoardDateTimeTextController();
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.purple.shade900, Colors.purple.shade700]
                  : [Colors.purple.shade200, Colors.purple.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : Colors.black87, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Agregar Gasto",
          style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save,
                size: 30, color: isDark ? Colors.greenAccent : Colors.green),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final datosCaja =
                    await _cajaController.obtenerCajaActual(widget.usuarioId);
                final cajaId = datosCaja['cajaId'];

                if (cajaId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("No hay caja activa para este usuario")),
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
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(proveedorController, "Proveedor", "Proveedor es requerido"),
                const SizedBox(height: 20),
                _buildTextField(descripcionController, "Descripción", "Descripción es requerida",
                    isDescription: true),
                const SizedBox(height: 20),
                _buildTextField(montoController, "Monto", "Monto es requerido", isNumber: true),
                const SizedBox(height: 25),
                _buildDatePicker(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String errorText,
      {bool isDescription = false, bool isNumber = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.number
          : isDescription
              ? TextInputType.multiline
              : TextInputType.text,
      textInputAction: isDescription ? TextInputAction.newline : TextInputAction.done,
      maxLines: isDescription ? null : 1,
      style: GoogleFonts.montserrat(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: isDark ? Colors.white70 : Colors.black54),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple, width: 2),
        ),
      ),
      validator: (value) => (value == null || value.isEmpty) ? errorText : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        border: Border.all(color: Colors.purple, width: 1.5),
      ),
      child: Row(
        children: [
          Text(
            'Fecha: ',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: isDark ? ThemeData.dark() : ThemeData.light(),
                    child: child!,
                  );
                },
              );

              if (selectedDate != null && selectedDate != date) {
                TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: date.hour, minute: date.minute),
                  builder: (context, child) {
                    return Theme(data: isDark ? ThemeData.dark() : ThemeData.light(), child: child!);
                  },
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
                    fechaController.setDate(date);
                  });
                }
              }
            },
            child: Text(
              BoardDateFormat('dd/MM/yyyy HH:mm').format(date),
              style: GoogleFonts.montserrat(
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

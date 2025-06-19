import 'package:flutter/material.dart';
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

  final _formKey = GlobalKey<FormState>();

  final TextEditingController proveedorController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController montoController = TextEditingController();
  DateTime fechaSeleccionada = DateTime.now();

  final _pagosController = PagoController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1E1E1E)
            : const Color.fromARGB(255, 209, 219, 250),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color:
                isDark ? Colors.white : const Color.fromARGB(255, 81, 81, 81),
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
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
                    fecha: fechaSeleccionada,
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
            icon: Icon(
              Icons.save,
              size: 30,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(150, 37, 255, 44)
                  : Colors.green,
            ),
          )
        ],
        title: Center(
          child: Text(
            "Agregar Pago",
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? Colors.white : const Color.fromARGB(255, 81, 81, 81),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _componenteCampo("Proveedor", proveedorController),
                _componenteCampo("Descripción", descripcionController,
                    isDescripcion: true),
                _componenteCampo("Monto", montoController,
                    tipo: TextInputType.number),
                const SizedBox(height: 15),
                _selectorFecha(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _componenteCampo(String titulo, TextEditingController controller,
      {bool isDescripcion = false, TextInputType tipo = TextInputType.text}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            keyboardType: tipo,
            maxLines: isDescripcion ? null : 1,
            validator: (value) => value == null || value.trim().isEmpty
                ? "Campo requerido"
                : null,
            decoration: InputDecoration(
              hintText: "Ingresa $titulo",
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectorFecha(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          height: 65,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2E3B3B)
                : const Color.fromARGB(160, 133, 203, 144),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Fecha:',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFB0B0B0) : Colors.black,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  DateTime? nuevaFecha = await showDatePicker(
                    context: context,
                    initialDate: fechaSeleccionada,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (nuevaFecha != null) {
                    setState(() {
                      fechaSeleccionada = nuevaFecha;
                    });
                  }
                },
                child: Text(
                  DateFormat('dd/MM/yyyy').format(fechaSeleccionada),
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

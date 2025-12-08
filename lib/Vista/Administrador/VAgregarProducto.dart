import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/AlmacenController.dart';
import 'package:proyecto_panaderia/Controlador/UsuarioController.dart';

class VAgregarProducto extends StatefulWidget {
  const VAgregarProducto({super.key});

  @override
  State<VAgregarProducto> createState() => _VAgregarProductoState();
}

class _VAgregarProductoState extends State<VAgregarProducto> {
  String usuarioId = '';
  String username = '';
  final formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  final productonameController = TextEditingController();
  final existenciaController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    obtenerUsername();
    obtenerUsuarioId();
  }

  void obtenerUsername() async {
    String nombre = await UsuarioController.obtenerUsername(usuarioId);
    setState(() => username = nombre);
  }

  void obtenerUsuarioId() async {
    String id = await UsuarioController.obtenerUsuarioId();
    setState(() => usuarioId = id);
  }

  Future<void> registrarProducto() async {
    if (!formKey.currentState!.validate()) return;

    try {
      await AlmacenController.registrarProducto(
        id: idController.text,
        nombre: productonameController.text,
        existencias: int.parse(existenciaController.text),
        precio: int.parse(priceController.text),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

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
                  ? [Colors.green.shade900, Colors.green.shade700]
                  : [Colors.green.shade400, Colors.green.shade300],
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
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.black87, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Agregar Producto',
          style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save, size: 30, color: isDark ? Colors.greenAccent : Colors.green),
            onPressed: registrarProducto,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _buildTextField(productonameController, "Nombre", "Nombre es requerido"),
                const SizedBox(height: 20),
                _buildTextField(idController, "Código", "Código es requerido"),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(existenciaController, "Cantidad", "Cantidad es requerida", isNumber: true),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildTextField(priceController, "Precio", "Precio es requerido", isNumber: true),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String errorText, {bool isNumber = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.montserrat(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: isDark ? Colors.white70 : Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        filled: true,
      ),
      validator: (value) => (value == null || value.isEmpty) ? errorText : null,
    );
  }
}

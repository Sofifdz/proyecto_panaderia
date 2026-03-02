import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto registrado exitosamente")),
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
          "Agregar Producto",
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
                              child: _buildTextField(
                                existenciaController,
                                "Cantidad",
                                "Cantidad es requerida",
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildTextField(
                                priceController,
                                "Precio",
                                "Precio es requerido",
                                isNumber: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
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
                onPressed: registrarProducto,
                child: Text(
                  "Guardar Producto",
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String errorText, {
    bool isNumber = false,
  }) {
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);
    const backgroundColor = Color(0xFFF4F6F8);

    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))] : null,
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
}
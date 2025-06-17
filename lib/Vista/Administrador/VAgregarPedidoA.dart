import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:proyecto_panaderia/Controlador/PedidoController.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VPedidosA.dart';

class VAgregarPedidoA extends StatefulWidget {
  final String usuarioId;
  final String username;
  const VAgregarPedidoA({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<VAgregarPedidoA> createState() => _VAgregarPedidoAState();
}

class _VAgregarPedidoAState extends State<VAgregarPedidoA> {
  final PedidoController _pedidoController = PedidoController();
  final clienteController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();
  final fechaController = BoardDateTimeTextController();
  DateTime date = DateTime.now();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(160, 133, 203, 144),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Color.fromARGB(255, 81, 81, 81),
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);

          },
        ),
        actions: [agregar(context)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Componentes("Cliente", clienteController),
              Componentes("Descripción", descripcionController,
                  isDescription: true),
              Componentes("Precio", precioController),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(
                              0xFF2E3B3B) 
                          : const Color.fromARGB(160, 133, 203, 144),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Fecha de entrega: ',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFFB0B0B0)
                                    : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final isDark =
                                Theme.of(context).brightness == Brightness.dark;

                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              builder: (context, child) {
                                return Theme(
                                  data: isDark
                                      ? ThemeData.dark().copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Color(0xFF8BC34A),
                                            onPrimary: Colors.black,
                                            onSurface: Colors.white,
                                          ),
                                          dialogBackgroundColor:
                                              Color(0xFF1E1E1E),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              textStyle: GoogleFonts.montserrat(
                                                  fontSize: 16),
                                            ),
                                          ),
                                        )
                                      : ThemeData.light().copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: Colors.green,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                          ),
                                          dialogBackgroundColor:
                                              const Color.fromARGB(
                                                  255, 240, 240, 240),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.black,
                                              textStyle: GoogleFonts.montserrat(
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                  child: child!,
                                );
                              },
                            );

                            if (selectedDate != null && selectedDate != date) {
                              TimeOfDay? selectedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                    hour: date.hour, minute: date.minute),
                                builder: (context, child) {
                                  return Theme(
                                    data: isDark
                                        ? ThemeData.dark().copyWith(
                                            colorScheme: const ColorScheme.dark(
                                              primary: Color(0xFF8BC34A),
                                              onPrimary: Colors.black,
                                              onSurface: Colors.white,
                                            ),
                                            dialogBackgroundColor:
                                                Color(0xFF1E1E1E),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                textStyle:
                                                    GoogleFonts.montserrat(
                                                        fontSize: 16),
                                              ),
                                            ),
                                          )
                                        : ThemeData.light().copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                              primary: Colors.green,
                                              onPrimary: Colors.white,
                                              onSurface: Colors.black,
                                            ),
                                            dialogBackgroundColor:
                                                const Color.fromARGB(
                                                    255, 240, 240, 240),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                textStyle:
                                                    GoogleFonts.montserrat(
                                                        fontSize: 16),
                                              ),
                                            ),
                                          ),
                                    child: child!,
                                  );
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
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget Componentes(String titulo, TextEditingController controller,
      {bool isDescription = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.montserrat(
              fontSize: 25,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: isDescription ? const EdgeInsets.all(.0) : EdgeInsets.zero,
            child: TextFormField(
              controller: controller,
              keyboardType:
                  isDescription ? TextInputType.multiline : TextInputType.text,
              textInputAction: isDescription
                  ? TextInputAction.newline
                  : TextInputAction.done,
              maxLines: isDescription ? null : 1,
              decoration: InputDecoration(
                hintText: isDescription
                    ? 'Escribe la descripción del pedido'
                    : 'Ingresa $titulo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget agregar(BuildContext context) {
    return IconButton(
        onPressed: () {
          _pedidoController.guardarPedido(
            context: context,
            cliente: clienteController.text,
            descripcion: descripcionController.text,
            precio: precioController.text,
            fecha: date,
          );
        },
        icon: Icon(
          Icons.save,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(150, 37, 255, 44)
              : Colors.green,
          size: 30,
        ));
  }
}

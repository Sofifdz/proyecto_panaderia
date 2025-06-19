import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/DrawerConfig.dart';

class Vpagos extends StatefulWidget {
  final String usuarioId;
  final String username;
  const Vpagos({
    super.key,
    required this.usuarioId,
    required this.username,
  });

  @override
  State<Vpagos> createState() => _VpagosState();
}

class _VpagosState extends State<Vpagos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : const Color.fromARGB(255, 209, 219, 250),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color.fromARGB(255, 81, 81, 81),
                size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_outlined,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color.fromARGB(255, 81, 81, 81),
              size: 30,
            ),
            onPressed: () {},
          )
        ],
        title: Center(
          child: Text(
            "Pagos",
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color.fromARGB(255, 81, 81, 81),
            ),
          ),
        ),
      ),
      drawer: DrawerConfig.empleadoDrawer(
        context,
        widget.usuarioId,
        widget.username,
      ),
      body: cuerpo(context),
    );
  }

  Widget cuerpo(BuildContext context)
  {
    return Container();
  }
}

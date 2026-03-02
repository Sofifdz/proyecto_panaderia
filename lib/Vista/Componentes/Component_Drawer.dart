import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_panaderia/Controlador/UsuarioController.dart';

class ComponentDrawer extends StatefulWidget {
  final List<String> items;
  final List<IconData> iconos;
  final List<VoidCallback> onTaps;
  final String typeUser;
  final Color colorr;
  final String username;
  final String usuarioId;

  const ComponentDrawer({
    super.key,
    required this.items,
    required this.iconos,
    required this.onTaps,
    required this.typeUser,
    required this.colorr,
    required this.username,
    required this.usuarioId,
  });

  @override
  State<ComponentDrawer> createState() => _ComponentDrawerState();
}

class _ComponentDrawerState extends State<ComponentDrawer> {
  late String _username = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    String username = await UsuarioController.obtenerUsername(widget.usuarioId);
    if (mounted) {
      setState(() {
        _username = username.isEmpty ? 'Usuario desconocido' : username;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6F8);
    const appBarColor = Color(0xFF1F2933);
    const primaryBlue = Color(0xFF2563EB);
    const mainText = Color(0xFF111827);

    final String headerText = 'Hola $_username';

    return Drawer(
      child: Container(
        color: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
                height: 190,
                child: DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    color: appBarColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 34,
                          color: primaryBlue,
                        ),
                      ),
                      Text(
                        headerText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.typeUser,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 20),

            Column(
              children: [
                for (int i = 0; i < widget.items.length; i++)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.iconos[i],
                          size: 22,
                          color: primaryBlue,
                        ),
                      ),
                      title: Text(
                        widget.items[i],
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: mainText,
                        ),
                      ),
                      onTap: widget.onTaps[i],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

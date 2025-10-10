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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final String headerText = 'Hola $_username';

    // Definir gradiente según tipo de usuario
    Gradient headerGradient;
    if (widget.typeUser == 'Empleado') {
      headerGradient = LinearGradient(
        colors: isDark
            ? [Colors.purple.shade900, Colors.purple.shade700]
            : [Colors.purple.shade200, Colors.purple.shade100],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Administrador
      headerGradient = LinearGradient(
        colors: isDark
            ? [Colors.green.shade900, Colors.green.shade700]
            : [Colors.green.shade400, Colors.green.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return Drawer(
      child: Container(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 180,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  gradient: headerGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Center(
                    child: Text(
                      headerText,
                      style: GoogleFonts.montserrat(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                for (int i = 0; i < widget.items.length; i++)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(
                        widget.iconos[i],
                        size: 22,
                        color: isDark
                            ? Colors.white70
                            : (widget.typeUser == 'Empleado'
                                ? Colors.purple
                                : Colors.green[700]),
                      ),
                      title: Text(
                        widget.items[i],
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      onTap: widget.onTaps[i],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

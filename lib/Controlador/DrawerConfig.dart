import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_panaderia/Controlador/CajaController.dart';
import 'package:proyecto_panaderia/Controlador/LoginController.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VAlmacen.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VPedidosA.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VPersonal.dart';
import 'package:proyecto_panaderia/Vista/Administrador/VVentasUsuarios.dart';
import 'package:proyecto_panaderia/Vista/Administrador/Valmacen2.0.dart';
import 'package:proyecto_panaderia/Vista/Componentes/Component_Drawer.dart';
import 'package:proyecto_panaderia/Vista/Componentes/ShowDialogCaja.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VPedidosE.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VVentas.dart';
import 'package:proyecto_panaderia/Vista/Empleado/VVentasporTurno.dart';
import 'package:proyecto_panaderia/Vista/VLogin.dart';

class DrawerConfig {
  static ComponentDrawer administradorDrawer(
      BuildContext context, String usuarioId, String username) {
    return ComponentDrawer(
      usuarioId: usuarioId,
      username: username,
      colorr: Color.fromARGB(160, 133, 203, 144),
      items: ['Ventas', 'Almacen', 'Personal', 'Pedidos', 'Salir'],
      iconos: [
        Icons.shopping_basket,
        Icons.inventory,
        Icons.person,
        Icons.list_alt,
        Icons.exit_to_app
      ],
      onTaps: [
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VVentasUsuarios(usuarioId: usuarioId, username: username)),
          );
        },
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VAlmacenCopia(usuarioId: usuarioId, username: username)),
          );
        },
        () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VPersonal(
                  usuarioId: usuarioId,
                  username: username,
                ),
              ));
        },
        () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VPedidosA(
                  usuarioId: usuarioId,
                  username: username,
                ),
              ));
        },
        () {
          final salir = LoginController();
          salir.logOut(context);
        },
      ],
      typeUser: 'Administrador',
    );
  }

  static ComponentDrawer empleadoDrawer(
      BuildContext context, String usuarioId, String username) {
    return ComponentDrawer(
      usuarioId: usuarioId,
      username: username,
      colorr: Theme.of(context).brightness == Brightness.dark
          ? const Color.fromARGB(255, 193, 209, 255)
          : const Color.fromARGB(255, 209, 219, 250),
      items: [
        'Nueva Venta',
        'Ventas del turno',
        'Pedidos',
        'Corte de caja',
        'Salir'
      ],
      iconos: [
        Icons.add_shopping_cart,
        Icons.shopping_basket_rounded,
        Icons.list_alt,
        Icons.money_off,
        Icons.exit_to_app
      ],
      onTaps: [
        () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VVentas(
                  usuarioId: usuarioId,
                  username: username,
                ),
              ));
        },
        () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VVentasporTurno(
                      usuarioId: usuarioId, username: username)));
        },
        () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VPedidosE(
                        username: username,
                        usuarioId: usuarioId,
                      )));
        },
        () {
          CajaController.corteDeCaja(context, usuarioId, username);
        },
        () {
          final salir = LoginController();
          salir.logOut(context);
        },
      ],
      typeUser: 'Empleado',
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Component_date {
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime? initialDate,
  }) async {
    DateTime tempPickedDate = initialDate ?? DateTime.now();
    return await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Selecciona una fecha',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            height: 300,
            child: StatefulBuilder(
              builder: (context, setState) {
                return CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempPickedDate,
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      tempPickedDate = newDateTime;
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancelar',
                  style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(tempPickedDate),
              child: Text('Aplicar',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  )),
            ),
          ],
        );
      },
    );
  }
}

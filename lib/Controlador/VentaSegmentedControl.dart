import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class VentaSegmentedControl extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onValueChanged;

  const VentaSegmentedControl({
    super.key,
    required this.selectedValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    const colorBorder = Color.fromARGB(255, 60, 120, 80);
    const colorSelected = Color.fromARGB(255, 60, 120, 80); 
    const colorUnselected = Colors.white;
    const colorPressed = Color.fromARGB(80, 60, 120, 80);

    return CupertinoSegmentedControl<String>(
      borderColor: colorBorder,
      selectedColor: colorSelected,
      unselectedColor: colorUnselected,
      pressedColor: colorPressed,
      groupValue: selectedValue,
      onValueChanged: onValueChanged,
      children: {
        'todas': _buildChild('Todas', 'todas'),
        'pan': _buildChild('Pan', 'pan'),
        'almacen': _buildChild('Almacén', 'almacen'),
        'mixto': _buildChild('Mixto', 'mixto'),
        'pagos': _buildChild('Pagos', 'pagos'), 
      },
    );
  }

  Widget _buildChild(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 11),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: value == selectedValue ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
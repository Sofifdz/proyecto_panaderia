import 'package:flutter/material.dart';

class ComponentInputSearch extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback showFilterSheet;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ComponentInputSearch({
    Key? key,
    required this.searchController,
    required this.showFilterSheet,
    required this.onChanged,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: searchController,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: isDark ? const Color(0xFF3A3A3C) : Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

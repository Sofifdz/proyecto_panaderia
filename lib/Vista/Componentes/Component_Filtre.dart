import 'package:flutter/material.dart';

class Component_Filtre extends StatefulWidget {
  final Function(String) onFilterChanged;

  const Component_Filtre({Key? key, required this.onFilterChanged})
      : super(key: key);

  @override
  State<Component_Filtre> createState() => _Component_FiltreState();
}

class _Component_FiltreState extends State<Component_Filtre> {
  String selectedFilter = '';

  
  void _applyFilter(String? filter) {
    if (filter == null) return;
    setState(() {
      selectedFilter = filter;
    });
    widget.onFilterChanged(filter);
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          ExpansionTile(
            title: Text('Ordenar por precio'),
            children: [
              RadioListTile(
                title: Text('Menor precio'),
                value: 'precio_asc',
                groupValue: selectedFilter,
                onChanged: _applyFilter, 
              ),
              RadioListTile(
                title: Text('Mayor precio'),
                value: 'precio_desc',
                groupValue: selectedFilter,
                onChanged: _applyFilter,
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Ordenar por existencias'),
            children: [
              RadioListTile(
                title: Text('Menor existencia'),
                value: 'existencias_asc',
                groupValue: selectedFilter,
                onChanged: _applyFilter,
              ),
              RadioListTile(
                title: Text('Mayor existencia'),
                value: 'existencias_desc',
                groupValue: selectedFilter,
                onChanged: _applyFilter,
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Ordenar por nombre'),
            children: [
              RadioListTile(
                title: Text('Nombre'),
                value: 'nombre_asc',
                groupValue: selectedFilter,
                onChanged: _applyFilter,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


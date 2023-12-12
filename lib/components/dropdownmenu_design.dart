import 'package:flutter/material.dart';

class DropdownMenuDesign extends StatelessWidget {
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?>? onChanged;

  const DropdownMenuDesign({
    Key? key,
    required this.items,
    this.selectedItem,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            dropdownColor: Colors.white,
            isExpanded: true,
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: SizedBox(
                  height: 18,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                      style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Sans-serif',
                          color: Colors.black),
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            value: selectedItem,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            padding: const EdgeInsets.symmetric(),
          ),
        ),
      ),
    );
  }
}

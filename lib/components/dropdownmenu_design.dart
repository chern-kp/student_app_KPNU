import 'package:flutter/material.dart';

class DropdownMenuDesign extends StatelessWidget {
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?>? onChanged;
  final String hintText;

  const DropdownMenuDesign({
    Key? key,
    required this.items,
    this.selectedItem,
    this.onChanged,
    this.hintText = "Select an item",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160, // Set the width as per your requirement
      padding: EdgeInsets.symmetric(),
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
                child: Container(
                  height: 18, // Set the height of the container
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Sans-serif',
                          color: Colors.black),
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            value: selectedItem,
            hint: Center(
              child: Text(
                hintText,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontFamily: 'Sans-serif'),
              ),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            padding: const EdgeInsets.symmetric(),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ModernDropdown extends StatefulWidget {
  final IconData icon;
  final List<String> items;
  final String hint;

  const ModernDropdown({
    super.key,
    required this.icon,
    required this.items,
    required this.hint,
  });

  @override
  State<ModernDropdown> createState() => _ModernDropdownState();
}

class _ModernDropdownState extends State<ModernDropdown> {
  String? _value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _value,
          hint: Row(
            children: [
              Icon(widget.icon, color: Colors.grey),
              const SizedBox(width: 8),
              Text(widget.hint),
            ],
          ),
          isExpanded: true,
          items: widget.items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            setState(() => _value = v);
          },
        ),
      ),
    );
  }
}

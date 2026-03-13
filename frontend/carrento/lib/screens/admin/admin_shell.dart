import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class AdminShell extends StatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final _routes = ['/admin', '/admin/cars', '/admin/bookings', '/admin/users'];
  final _items = [
    (Icons.dashboard_rounded, 'Dashboard'),
    (Icons.directions_car_rounded, 'Cars'),
    (Icons.receipt_long_rounded, 'Bookings'),
    (Icons.people_rounded, 'Users'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.divider))),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: _items.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final selected = _index == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () { setState(() => _index = i); context.go(_routes[i]); },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(item.$1, color: selected ? AppColors.accent : AppColors.textMuted, size: 22),
                        const SizedBox(height: 4),
                        Text(item.$2, style: GoogleFonts.spaceGrotesk(color: selected ? AppColors.accent : AppColors.textMuted, fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                      ]),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

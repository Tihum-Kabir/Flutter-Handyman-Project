import 'package:flutter/material.dart';
import 'handyman_list.dart';

/// Displays all technicians available for booking.
class TechnicianPage extends StatelessWidget {
  const TechnicianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HandymanListPage(category: 'Technician');
  }
}




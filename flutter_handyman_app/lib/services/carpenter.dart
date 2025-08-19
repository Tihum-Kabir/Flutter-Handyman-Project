import 'package:flutter/material.dart';
import 'handyman_list.dart';

/// Displays carpenters for woodworking services.
class CarpenterPage extends StatelessWidget {
  const CarpenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HandymanListPage(category: 'Carpenter');
  }
}




import 'package:flutter/material.dart';
import 'handyman_list.dart';

/// Page listing all painters available for hire.
class PainterPage extends StatelessWidget {
  const PainterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HandymanListPage(category: 'Painter');
  }
}




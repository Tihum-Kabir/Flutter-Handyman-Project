import 'package:flutter/material.dart';
import 'handyman_list.dart';

/// Shows electricians that the user can hire.
class ElectricianPage extends StatelessWidget {
  const ElectricianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HandymanListPage(category: 'Electrician');
  }
}




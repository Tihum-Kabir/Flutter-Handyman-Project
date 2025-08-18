import 'package:flutter/material.dart';
import 'handyman_list.dart';

/// A page that shows a list of available plumbers using the
/// generic [HandymanListPage].
class PlumberPage extends StatelessWidget {
  const PlumberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HandymanListPage(category: 'Plumber');
  }
}




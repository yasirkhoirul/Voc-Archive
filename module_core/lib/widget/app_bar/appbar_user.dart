import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppbarUser extends StatelessWidget {
  const AppbarUser({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Icon(Icons.home_filled)],
      ),
    );
  }
}

class ItemAppBar extends StatelessWidget {
  final String title;
  const ItemAppBar({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ],
    );
  }
}

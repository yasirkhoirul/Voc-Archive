import 'package:flutter/material.dart';

class Button extends StatelessWidget{
  final String textButton;
  final VoidCallback onPressed;
  const Button({super.key, required this.textButton, required this.onPressed, });
  const Button.negative({super.key, required this.textButton, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed, child: Text(textButton,style: Theme.of(context).textTheme.labelLarge,));
  }
}
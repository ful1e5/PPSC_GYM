import 'package:flutter/material.dart';

class CustomFabButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const CustomFabButton({Key key, this.icon, this.color, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        duration: Duration(seconds: 1),
        height: 50.0,
        width: 50.0,
        child: Icon(icon),
      ),
    );
  }
}
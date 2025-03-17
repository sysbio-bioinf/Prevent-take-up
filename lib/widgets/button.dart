import 'package:flutter/material.dart';
import 'package:questionnaires/configs/app_colors.dart';

class Button extends StatelessWidget {
  final String buttonLabel;
  final void Function()? onPressed;
  final bool isPrimary;
  final bool isHighlighted;

  Button.primary({
    required this.buttonLabel,
    required this.onPressed,
  })  : isPrimary = true,
        isHighlighted = false;

  Button.accent({
    required this.buttonLabel,
    required this.onPressed,
  })  : isPrimary = false,
        isHighlighted = false;

  Button.highlighted({
    required this.buttonLabel,
    required this.onPressed,
  })  : isPrimary = false,
        isHighlighted = true;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: isHighlighted
              ? AppColors.highlightorange
              : Theme.of(context).primaryColor,
          shape: isPrimary
              ? null
              : RoundedRectangleBorder(
                  side: BorderSide(
                  color: Theme.of(context).disabledColor,
                ))),
      child: Text(
        buttonLabel,
        style: isPrimary
            ? TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).accentColor,
              )
            : TextStyle(
                fontWeight: FontWeight.w700,
              ),
      ),
      onPressed: onPressed,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:jumandi_rider/utils/app_colors.dart';

class JumandiLogo extends StatelessWidget {
  final double size;
  final bool isRider;

  const JumandiLogo({
    Key? key,
    this.size = 100,
    this.isRider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/jumandi_logo.png',
              width: size * 0.7,
              height: size * 0.7,
              // If you don't have the logo image yet, you can use a placeholder icon
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.delivery_dining,
                  size: size * 0.5,
                  color: AppColors.primary,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isRider ? 'JUMANDI RIDER' : 'JUMANDI GAS',
          style: TextStyle(
            fontSize: size * 0.18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
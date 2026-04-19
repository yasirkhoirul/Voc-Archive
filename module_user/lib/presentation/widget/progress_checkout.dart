import 'package:flutter/material.dart';

class ProgressCheckout extends StatelessWidget {
  final int currentStep;

  const ProgressCheckout({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStep(0, 'Personal Data'),
          _buildLine(0),
          _buildStep(1, 'Shipping Data'),
          _buildLine(1),
          _buildStep(2, 'Payment'),
        ],
      ),
    );
  }

  Widget _buildStep(int stepIndex, String title) {
    bool isActive = stepIndex <= currentStep;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.black : Colors.white,
            border: Border.all(
              color: isActive ? Colors.black : Colors.grey,
              width: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(int stepIndex) {
    bool isActive = stepIndex < currentStep;
    return Expanded(
      child: Column(
        children: [
          const SizedBox(
            height: 11,
          ), // To align with the middle of the 24px circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isActive ? Colors.black : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

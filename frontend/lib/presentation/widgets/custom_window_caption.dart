import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/constants/colors.dart';

class CustomWindowCaption extends StatelessWidget {
  const CustomWindowCaption({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: Container(
        height: 40,
        color: AppColors.background,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                'RG Clinic',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPlum,
                ),
              ),
            ),
            const Spacer(),
            _buildButton(
              icon: Icons.minimize,
              onTap: () => windowManager.minimize(),
            ),
            _buildButton(
              icon: Icons.close,
              onTap: () => windowManager.close(),
              isClose: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onTap, bool isClose = false}) {
    return InkWell(
      onTap: onTap,
      hoverColor: isClose ? Colors.red : Colors.grey.withValues(alpha: 0.2),
      child: Container(
        width: 46,
        height: 40,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

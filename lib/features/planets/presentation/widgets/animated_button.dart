import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/planets/data/models/planets_model.dart';
import 'package:flutter_ar/features/planets/presentation/details_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';

class AnimatedButton extends StatefulWidget {
  final PlanetsModel planet;
  final FontSizeOption fontSize;

  const AnimatedButton({
    super.key,
    required this.planet,
    required this.fontSize,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool isVisible = false;
  late SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _settingsProvider.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (!_settingsProvider.isAnimationEnabled && isVisible) {
      setState(() {
        isVisible = false;
      });
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DetailsPage(
            planet: widget.planet,
            fontSize: widget.fontSize,
          );
        },
      );
    }
  }

  void showAnimationAndModal() {
    if (_settingsProvider.isAnimationEnabled) {
      setState(() {
        isVisible = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isVisible = false;
          });

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return DetailsPage(
                planet: widget.planet,
                fontSize: widget.fontSize,
              );
            },
          );
        }
      });
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DetailsPage(
            planet: widget.planet,
            fontSize: widget.fontSize,
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!isVisible)
            ElevatedButton(
              onPressed: showAnimationAndModal,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white70,
                foregroundColor: AppTheme.getTextColor(context),
                fixedSize: Size(200.w, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(42.r),
                ),
              ),
              child: Text(
                "Узнать больше",
                style: TextStyle(
                  fontSize: AppTheme.getBodyFontSize(),
                  fontFamily: 'kanit',
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ),
          if (isVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: Lottie.asset(
                'assets/animations/rocket.json',
                height: 100.h,
                width: 150.w,
              ),
            ),
        ],
      ),
    );
  }
}
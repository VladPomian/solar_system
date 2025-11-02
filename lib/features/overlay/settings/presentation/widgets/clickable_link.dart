import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableLink extends StatelessWidget {
  final IconData icon;
  final String text;
  final String url;
  final String? fallbackUrl;
  final Color primaryColor;
  final bool underline;

  const ClickableLink({
    super.key,
    required this.icon,
    required this.text,
    required this.url,
    this.fallbackUrl,
    required this.primaryColor,
    this.underline = true,
  });

  Future<void> _launch(BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (fallbackUrl != null) {
        await launchUrl(Uri.parse(fallbackUrl!), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть ссылку')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launch(context),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: primaryColor,
              fontSize: 14,
              decoration: underline ? TextDecoration.underline : TextDecoration.none,
              decorationColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
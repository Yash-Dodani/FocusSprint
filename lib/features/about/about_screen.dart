import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF14141F);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B6B80);

    return Scaffold(
      appBar: AppBar(title: const Text('About FocusSprint')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Logo
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isDark ? const Color(0xFF19192A) : Colors.grey.shade100,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/logo/focus_sprint_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'FocusSprint',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Short, powerful focus sprints that keep you consistent.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Credits',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Created by Yash Dodani\n'
                'Team: Night Owls',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Version 1.0.0 (Hackathon build)',
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
            ),
            const Spacer(),
            Text(
              'Made with ❤️ in India',
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

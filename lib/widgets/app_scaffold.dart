import 'package:flutter/material.dart';

const green = Color(0xFF006B52);
const mint = Color(0xFFE9FBF4);
const ink = Color(0xFF111827);
const muted = Color(0xFF667085);

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  final bool showBack;
  final int? currentTab;

  const AppScaffold({super.key, required this.title, required this.child, this.actions = const [], this.showBack = true, this.currentTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBack ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)) : null,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: ink)),
        centerTitle: true,
        actions: actions,
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: currentTab == null ? null : BottomNavigationBar(
        currentIndex: currentTab!,
        onTap: (index) {
          final routes = ['/dashboard', '/workers', '/documents', '/compliance'];
          if (index != currentTab) Navigator.pushReplacementNamed(context, routes[index]);
        },
        selectedItemColor: green,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Workers'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Docs'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), label: 'Compliance'),
        ],
      ),
    );
  }
}

class ScreenPadding extends StatelessWidget {
  final Widget child;
  const ScreenPadding({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), child: child);
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const SurfaceCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE3E5E8))),
        child: child,
      );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const PrimaryButton({super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(backgroundColor: green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))));
}

class StatusBadge extends StatelessWidget {
  final String text;
  final bool warning;
  const StatusBadge({super.key, required this.text, this.warning = false});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: warning ? const Color(0xFFFFF7DF) : mint, borderRadius: BorderRadius.circular(6)), child: Text(text, style: TextStyle(color: warning ? const Color(0xFFB56C00) : green, fontSize: 11, fontWeight: FontWeight.w700)));
}

class FlagLabel extends StatelessWidget {
  final String country;
  const FlagLabel({super.key, required this.country});
  String get flag => {'Bangladesh': '🇧🇩', 'Singapore': '🇸🇬', 'Germany': '🇩🇪', 'India': '🇮🇳', 'United States': '🇺🇸' }[country] ?? '🌐';
  @override
  Widget build(BuildContext context) => Text('$flag  $country', style: const TextStyle(fontWeight: FontWeight.w600));
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_notifier.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return PopupMenuButton<ThemeMode>(
      icon: const Icon(Icons.brightness_6),
      onSelected: (mode) => ref.read(themeProvider.notifier).setTheme(mode),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.system,
          child: Text('System'),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: Text('Light'),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Text('Dark'),
        ),
      ],
      initialValue: themeMode,
    );
  }
}

class ThemeSwitcherCard extends ConsumerWidget {
  const ThemeSwitcherCard({super.key});

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Theme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Current: ${_getThemeModeName(themeMode)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const ThemeSwitcher(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildThemeOption(
                  context,
                  ref,
                  ThemeMode.light,
                  Icons.light_mode,
                  'Light',
                ),
                _buildThemeOption(
                  context,
                  ref,
                  ThemeMode.dark,
                  Icons.dark_mode,
                  'Dark',
                ),
                _buildThemeOption(
                  context,
                  ref,
                  ThemeMode.system,
                  Icons.brightness_auto,
                  'System',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    IconData icon,
    String label,
  ) {
    final currentThemeMode = ref.watch(themeProvider);
    final isSelected = currentThemeMode == mode;
    
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).setTheme(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingThemeSwitcher extends ConsumerStatefulWidget {
  const FloatingThemeSwitcher({super.key});

  @override
  ConsumerState<FloatingThemeSwitcher> createState() => _FloatingThemeSwitcherState();
}

class _FloatingThemeSwitcherState extends ConsumerState<FloatingThemeSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    
    return FloatingActionButton(
      onPressed: () {
        _animationController.forward().then((_) {
          _animationController.reverse();
          ref.read(themeProvider.notifier).toggleTheme();
        });
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
        ),
      ),
    );
  }
} 
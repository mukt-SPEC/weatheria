import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Application menu bar providing keyboard shortcuts and menu actions.
/// On macOS, uses the native PlatformMenuBar.
/// On other desktop/web platforms, renders an in-app MenuBar.
class AppMenuBarWrapper extends StatelessWidget {
  const AppMenuBarWrapper({
    super.key,
    required this.child,
    required this.onSearch,
    required this.onLocationPicker,
    required this.onRefresh,
    required this.onToggleTheme,
  });

  final Widget child;
  final VoidCallback onSearch;
  final VoidCallback onLocationPicker;
  final VoidCallback onRefresh;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    // Register keyboard shortcuts regardless of platform
    return CallbackShortcuts(
      bindings: _shortcuts,
      child: Focus(
        autofocus: true,
        child: _buildWithMenuBar(context),
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> get _shortcuts => {
        // Ctrl/Cmd + F → search
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            onSearch,
        // Ctrl/Cmd + L → location picker
        const SingleActivator(LogicalKeyboardKey.keyL, control: true):
            onLocationPicker,
        // F5 → refresh
        const SingleActivator(LogicalKeyboardKey.f5): onRefresh,
        // Ctrl/Cmd + T → toggle theme
        const SingleActivator(LogicalKeyboardKey.keyT, control: true):
            onToggleTheme,
        // / key → quick search
        const SingleActivator(LogicalKeyboardKey.slash): onSearch,
      };

  Widget _buildWithMenuBar(BuildContext context) {
    // On macOS, use native platform menu bar
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
      return PlatformMenuBar(
        menus: [
          PlatformMenu(
            label: 'Weatheria',
            menus: [
              PlatformMenuItem(
                label: 'About Weatheria',
                onSelected: null,
              ),
              const PlatformMenuItemGroup(members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.quit,
                ),
              ]),
            ],
          ),
          PlatformMenu(
            label: 'View',
            menus: [
              PlatformMenuItem(
                label: 'Search City',
                shortcut:
                    const SingleActivator(LogicalKeyboardKey.keyF, meta: true),
                onSelected: onSearch,
              ),
              PlatformMenuItem(
                label: 'Location Picker',
                shortcut:
                    const SingleActivator(LogicalKeyboardKey.keyL, meta: true),
                onSelected: onLocationPicker,
              ),
              PlatformMenuItem(
                label: 'Refresh Weather',
                shortcut: const SingleActivator(LogicalKeyboardKey.f5),
                onSelected: onRefresh,
              ),
              PlatformMenuItem(
                label: 'Toggle Theme',
                shortcut:
                    const SingleActivator(LogicalKeyboardKey.keyT, meta: true),
                onSelected: onToggleTheme,
              ),
            ],
          ),
        ],
        child: child,
      );
    }

    // On other desktop or web, use in-app menu bar
    if (_shouldShowInAppMenu) {
      return Column(
        children: [
          _InAppMenuBar(
            onSearch: onSearch,
            onLocationPicker: onLocationPicker,
            onRefresh: onRefresh,
            onToggleTheme: onToggleTheme,
          ),
          Expanded(child: child),
        ],
      );
    }

    return child;
  }

  bool get _shouldShowInAppMenu {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }
}

class _InAppMenuBar extends StatelessWidget {
  const _InAppMenuBar({
    required this.onSearch,
    required this.onLocationPicker,
    required this.onRefresh,
    required this.onToggleTheme,
  });

  final VoidCallback onSearch;
  final VoidCallback onLocationPicker;
  final VoidCallback onRefresh;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 32,
      color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
      child: MenuBar(
        style: MenuStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
        children: [
          SubmenuButton(
            menuStyle: MenuStyle(
              elevation: WidgetStateProperty.all(4),
            ),
            menuChildren: [
              MenuItemButton(
                onPressed: onRefresh,
                shortcut:
                    const SingleActivator(LogicalKeyboardKey.f5),
                child: const Text('Refresh'),
              ),
            ],
            child: const Text('File'),
          ),
          SubmenuButton(
            menuStyle: MenuStyle(
              elevation: WidgetStateProperty.all(4),
            ),
            menuChildren: [
              MenuItemButton(
                onPressed: onSearch,
                shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyF,
                    control: true),
                child: const Text('Search City'),
              ),
              MenuItemButton(
                onPressed: onLocationPicker,
                shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyL,
                    control: true),
                child: const Text('Location Picker'),
              ),
              MenuItemButton(
                onPressed: onToggleTheme,
                shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyT,
                    control: true),
                child: const Text('Toggle Theme'),
              ),
            ],
            child: const Text('View'),
          ),
          SubmenuButton(
            menuStyle: MenuStyle(
              elevation: WidgetStateProperty.all(4),
            ),
            menuChildren: [
              MenuItemButton(
                onPressed: null,
                child: const Text('About Weatheria'),
              ),
            ],
            child: const Text('Help'),
          ),
        ],
      ),
    );
  }
}

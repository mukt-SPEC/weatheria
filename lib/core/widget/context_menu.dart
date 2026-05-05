import 'package:flutter/material.dart';


class AppContextMenu extends StatelessWidget {
  const AppContextMenu({
    super.key,
    required this.child,
    required this.menuItems,
  });

  final Widget child;
  final List<AppContextMenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    if (menuItems.isEmpty) return child;

    return MenuAnchor(
      menuChildren: menuItems
          .map(
            (item) => MenuItemButton(
              onPressed: item.onTap,
              leadingIcon:
                  item.icon != null ? Icon(item.icon, size: 18) : null,
              shortcut: item.shortcut,
              child: Text(item.label),
            ),
          )
          .toList(),
      builder: (context, controller, child) {
        return GestureDetector(
          onSecondaryTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          onLongPress: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: child,
        );
      },
      child: child,
    );
  }
}

class AppContextMenuItem {
  const AppContextMenuItem({
    required this.label,
    required this.onTap,
    this.icon,
    this.shortcut,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final MenuSerializableShortcut? shortcut;
}

import 'package:material_ui/material_ui.dart';

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

const navItems = [
  NavItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Главная',
    route: '/',
  ),
  NavItem(
    icon: Icons.explore_outlined,
    selectedIcon: Icons.explore_rounded,
    label: 'Источники',
    route: '/sources',
  ),
  NavItem(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Настройки',
    route: '/settings',
  ),
];

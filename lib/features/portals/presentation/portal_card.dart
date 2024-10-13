import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_core/ui/constants.dart';

class PortalCard extends StatelessWidget {
  const PortalCard({
    super.key,
    required this.portal,
    this.onTap,
    this.authIndication = false,
  });

  final Portal portal;
  final VoidCallback? onTap;
  final bool? authIndication;

  @override
  Widget build(BuildContext context) {
    if (authIndication == true) {
      return Observer(
        builder: (context) {
          final isActive =
              authIndication != true || portal.service.isAuthorized;

          return TweenAnimationBuilder(
            duration: Durations.medium2,
            tween: Tween<double>(
              begin: isActive ? 0.5 : 1,
              end: isActive ? 1 : 0.5,
            ),
            builder: (_, v, child) {
              var color =
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: v);

              return PortalCardBase(
                onTap: onTap,
                portal: portal,
                color: color,
                authIndication: authIndication,
                isActive: isActive,
              );
            },
          );
        },
      );
    }
    return PortalCardBase(
      onTap: onTap,
      portal: portal,
      color: Theme.of(context).colorScheme.onSurface,
      authIndication: authIndication,
      isActive: false,
    );
  }
}

class PortalCardBase extends StatelessWidget {
  const PortalCardBase({
    super.key,
    required this.onTap,
    required this.portal,
    required this.color,
    required this.authIndication,
    required this.isActive,
  });

  final VoidCallback? onTap;
  final Portal portal;
  final Color color;
  final bool? authIndication;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: SizedBox(
          width: 110,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: appPadding * 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      SvgPicture(
                        portal.logo,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      ),
                      if (authIndication == true)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: appPadding * 3),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? Colors.green[400]
                                    : Colors.grey[600],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: Icon(
                                  isActive ? Icons.check : Icons.add,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: appPadding),
                Text(portal.name, style: TextStyle(color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

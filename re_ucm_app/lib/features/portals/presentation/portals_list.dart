import 'package:flutter/material.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_core/models/portal/portal_settings.dart';
import '../../../core/ui/constants.dart';
import '../domain/portal_factory.dart';
import 'portal_card.dart';

class PortalsList extends StatelessWidget {
  const PortalsList({
    super.key,
    this.onTap,
    this.authIndication,
    this.settingsResolver,
  });

  final Function(Portal portal)? onTap;
  final bool? authIndication;
  final PortalSettings Function(Portal portal)? settingsResolver;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        padding: const EdgeInsets.only(
          right: appPadding * 1.5,
          left: appPadding * 1.5,
          bottom: 4,
        ),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: PortalFactory.portals.length,
        separatorBuilder: (context, index) => const SizedBox(width: appPadding),
        itemBuilder: (context, index) {
          var portal = PortalFactory.portals[index];
          return PortalCard(
            portal: portal,
            authIndication: authIndication,
            isAuthorized: settingsResolver != null
                ? portal.service.isAuthorized(settingsResolver!(portal))
                : false,
            onTap: onTap != null ? () => onTap!(portal) : null,
          );
        },
      ),
    );
  }
}

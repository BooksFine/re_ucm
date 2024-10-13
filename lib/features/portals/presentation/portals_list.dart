import 'package:flutter/material.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_core/ui/constants.dart';
import '../domain/portal_factory.dart';
import 'portal_card.dart';

class PortalsList extends StatelessWidget {
  const PortalsList({
    super.key,
    this.onTap,
    this.authIndication,
  });

  final Function(Portal portal)? onTap;
  final bool? authIndication;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: appPadding / 2),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: PortalFactory.portals.length,
        separatorBuilder: (context, index) => const SizedBox(width: appPadding),
        itemBuilder: (context, index) {
          var portal = PortalFactory.portals[index];
          return PortalCard(
            portal: portal,
            authIndication: authIndication,
            onTap: onTap != null ? () => onTap!(portal) : null,
          );
        },
      ),
    );
  }
}

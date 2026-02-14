import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:re_ucm_core/models/portal.dart';
import '../../../core/ui/constants.dart';
import '../domain/portal_factory.dart';
import 'portal_card.dart';

class PortalsList extends StatelessWidget {
  const PortalsList({
    super.key,
    this.onTap,
    this.authIndication,
    this.isAuthorizedResolver,
  });

  final Function(Portal portal)? onTap;
  final bool? authIndication;
  final bool Function(Portal portal)? isAuthorizedResolver;

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
          return Observer(
            builder: (context) {
              return PortalCard(
                portal: portal,
                authIndication: authIndication,
                isAuthorized: isAuthorizedResolver != null
                    ? isAuthorizedResolver!(portal)
                    : false,
                onTap: onTap != null ? () => onTap!(portal) : null,
              );
            },
          );
        },
      ),
    );
  }
}

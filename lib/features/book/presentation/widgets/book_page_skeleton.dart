import 'package:flutter/material.dart';
import '../../../../core/constants.dart';

class BookPageSkeleton extends StatelessWidget {
  const BookPageSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: appPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: appPadding),
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 110,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: appPadding * 1.5),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: appPadding * 2),
                      ...List.generate(
                        5,
                        (index) => Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                      ),
                      Container(
                        width: 100.0,
                        height: 10.0,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: appPadding * 2),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: const SizedBox(
                height: 48,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: appPadding * 2),
            ...List.generate(
              2,
              (index) => Container(
                width: double.infinity,
                height: 10.0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8.0),
              ),
            ),
            Container(
              width: 300.0,
              height: 10.0,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 8.0),
            ),
            ...List.generate(
              2,
              (index) => Container(
                width: double.infinity,
                height: 10.0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8.0),
              ),
            ),
            Container(
              width: 200.0,
              height: 10.0,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}

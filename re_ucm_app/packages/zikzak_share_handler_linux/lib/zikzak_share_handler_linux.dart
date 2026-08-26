import 'package:zikzak_share_handler_platform_interface/zikzak_share_handler_platform_interface.dart';

class ZikzakShareHandlerLinux extends ShareHandlerPlatform {
  static void registerWith() {
    ShareHandlerPlatform.instance = ZikzakShareHandlerLinux();
  }

  @override
  Future<SharedMedia?> getInitialSharedMedia() async {
    return null;
  }

  @override
  Stream<SharedMedia> get sharedMediaStream => const Stream.empty();
}

import 'package:zikzak_share_handler_platform_interface/zikzak_share_handler_platform_interface.dart';

class ZikzakShareHandlerWindows extends ShareHandlerPlatform {
  static void registerWith() {
    ShareHandlerPlatform.instance = ZikzakShareHandlerWindows();
  }

  @override
  Future<SharedMedia?> getInitialSharedMedia() async {
    return null;
  }

  @override
  Stream<SharedMedia> get sharedMediaStream => const Stream.empty();
}

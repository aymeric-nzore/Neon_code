import 'dart:async';
import 'dart:html' as html;

class WebPermissionsHelper {
  static Future<bool> isCameraPermissionGranted() async {
    try {
      final permissions = html.window.navigator.permissions;
      if (permissions == null) return false;
      
      final status = await permissions.query({'name': 'camera'});
      return status.state == 'granted';
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestCameraPermission() async {
    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) return false;
      
      final stream = await mediaDevices.getUserMedia({'video': true});
      // Stop all tracks to release camera
      final tracks = stream.getTracks();
      for (final track in tracks) {
        track.stop();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

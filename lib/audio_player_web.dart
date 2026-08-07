// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void playNotificationSound() {
  try {
    js.context.callMethod('playAudio', ['assets/assets/water_reminder.aac']);
  } catch (e) {
    // Suppress web-specific audio errors
  }
}

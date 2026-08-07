import 'audio_player_stub.dart'
    if (dart.library.js) 'audio_player_web.dart' as player;

void playReminderSound() {
  player.playNotificationSound();
}

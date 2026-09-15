/// RTC & WebRTC Configuration Constants for Grevia
/// Includes ZegoCloud WebRTC / WebSocket room server endpoints.
class RtcConstants {
  RtcConstants._();

  /// ZegoCloud App ID extracted from room server configuration
  static const int zegoAppId = 208938410;

  /// Primary WebSocket server address for Web scenarios
  static const String primaryWebSocketServer =
      'wss://webliveroom208938410-api.coolzcloud.com/ws';

  /// Secondary WebSocket server address (backup) for Web scenarios
  static const String secondaryWebSocketServer =
      'wss://webliveroom208938410-api-bak.coolzcloud.com/ws';

  /// Default Google STUN servers for WebRTC ICE negotiation
  static const List<String> defaultStunServers = [
    'stun:stun.l.google.com:19302',
    'stun:stun1.l.google.com:19302',
    'stun:stun2.l.google.com:19302',
    'stun:stun3.l.google.com:19302',
  ];

  /// Get list of configured WebSocket signaling endpoints
  static List<String> get webSocketServers => [
        primaryWebSocketServer,
        secondaryWebSocketServer,
      ];
}

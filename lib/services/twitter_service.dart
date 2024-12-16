// lib/services/twitter_service.dart
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TwitterService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  TwitterApi? _twitter;

  // Replace these with your actual credentials
  final String bearerToken = 'AAAAAAAAAAAAAAAAAAAAAElPxgEAAAAAFTTwQyhGAcZ1mQ%2F422T8K%2FOy2Fo%3DrzfDIz59QMWNmqrPdVdIWtdCrpnEvOjMzOOPWbfQFCOAJgJNFj'; // Replace with your Bearer Token

  TwitterService();

  /// Initialize TwitterApi client with stored access tokens
  Future<void> initialize() async {
    final accessToken = await _storage.read(key: 'twitter_access_token');
    final accessSecret = await _storage.read(key: 'twitter_access_secret');

    if (accessToken != null && accessSecret != null) {
      _twitter = TwitterApi(
        bearerToken: bearerToken,
      );
    } else {
      print('No access tokens found. Please authenticate.');
    }
  }

  /// Stores access tokens securely
  Future<void> storeAccessTokens(String accessToken, String accessSecret) async {
    await _storage.write(key: 'twitter_access_token', value: accessToken);
    await _storage.write(key: 'twitter_access_secret', value: accessSecret);
  }

  /// Posts a tweet with the given message
  Future<void> postTweet(String message) async {
    try {
      // Ensure the TwitterApi client is initialized
      if (_twitter == null) {
        await initialize();
      }

      if (_twitter != null) {
        final tweet = await _twitter!.tweetsService.createTweet(
            text: message
        );
        print('Tweet posted successfully! Tweet ID: ${tweet.data.id}');
      } else {
        print('Twitter API not initialized.');
      }
    } catch (e) {
      print('Error posting tweet: $e');
    }
  }

  /// Disconnects the Twitter account by deleting stored tokens
  Future<void> disconnect() async {
    await _storage.delete(key: 'twitter_access_token');
    await _storage.delete(key: 'twitter_access_secret');
    _twitter = null;
    print('Twitter account disconnected.');
  }
}

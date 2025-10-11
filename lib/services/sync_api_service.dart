import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/post.dart';
import '../core/ui_state.dart';

/// Service for communicating with the sync API server
/// Handles HTTP requests to the backend for data synchronization
class SyncApiService {
  final http.Client _httpClient;

  SyncApiService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Ping the server to check connectivity
  /// Returns true if server responds with 200 OK
  Future<bool> pingServer() async {
    try {
      final uri = Uri.parse(Env.pingUrl);

      if (Env.debugApiCalls) {
        print('[SyncApiService] Pinging server: $uri');
      }

      final response = await _httpClient
          .get(uri, headers: Env.defaultHeaders)
          .timeout(Duration(seconds: Env.apiTimeoutSeconds));

      if (Env.debugApiCalls) {
        print('[SyncApiService] Ping response: ${response.statusCode}');
      }

      return response.statusCode == 200;
    } on SocketException {
      // Network is offline
      if (Env.debugApiCalls) {
        print('[SyncApiService] Network offline - SocketException');
      }
      return false;
    } on HttpException catch (e) {
      // HTTP error
      if (Env.debugApiCalls) {
        print('[SyncApiService] HTTP error: $e');
      }
      return false;
    } on FormatException catch (e) {
      // Invalid response format
      if (Env.debugApiCalls) {
        print('[SyncApiService] Format error: $e');
      }
      return false;
    } catch (e) {
      // Any other error (timeout, etc.)
      if (Env.debugApiCalls) {
        print('[SyncApiService] Unexpected error: $e');
      }
      return false;
    }
  }

  /// Pull posts from server
  /// Returns list of posts from the server
  Future<List<Post>> pullPosts() async {
    try {
      final uri = Uri.parse(Env.postsUrl);

      if (Env.debugApiCalls) {
        print('[SyncApiService] Pulling posts from: $uri');
      }

      final response = await _httpClient
          .get(uri, headers: Env.defaultHeaders)
          .timeout(Duration(seconds: Env.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final posts = jsonList.map((json) => Post.fromJson(json)).toList();

        if (Env.debugApiCalls) {
          print('[SyncApiService] Pulled ${posts.length} posts');
        }

        return posts;
      } else {
        if (Env.debugApiCalls) {
          print(
              '[SyncApiService] Failed to pull posts: ${response.statusCode}');
        }
        return [];
      }
    } on SocketException {
      if (Env.debugApiCalls) {
        print('[SyncApiService] Network offline during pull posts');
      }
      return [];
    } catch (e) {
      if (Env.debugApiCalls) {
        print('[SyncApiService] Error pulling posts: $e');
      }
      return [];
    }
  }

  /// Push posts to server (mock implementation)
  /// In real implementation, this would send posts to server
  Future<void> pushPosts(List<Post> posts) async {
    try {
      final uri = Uri.parse(Env.postsUrl);

      if (Env.debugApiCalls) {
        print('[SyncApiService] Pushing ${posts.length} posts to: $uri');
      }

      // Mock implementation - just log the request
      // In real implementation, this would be:
      // final jsonList = posts.map((post) => post.toJson()).toList();
      // final jsonBody = json.encode(jsonList);
      // final response = await _httpClient
      //     .post(uri, headers: Env.defaultHeaders, body: jsonBody)
      //     .timeout(Duration(seconds: Env.apiTimeoutSeconds));

      if (Env.debugApiCalls) {
        print('[SyncApiService] Mock push completed for ${posts.length} posts');
      }

      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      if (Env.debugApiCalls) {
        print('[SyncApiService] Error pushing posts: $e');
      }
      rethrow;
    }
  }

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  /// Push a single post to the server
  Future<UiState<void>> pushPost(Post post) async {
    try {
      final uri = Uri.parse('${Env.apiBaseUrl}/posts');
      final response = await _httpClient.post(
        uri,
        headers: Env.defaultHeaders,
        body: jsonEncode(post.toJson()),
      ).timeout(Duration(seconds: Env.apiTimeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UiStateUtils.success(null);
      } else {
        return UiStateUtils.error('投稿の同期に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      return UiStateUtils.error('投稿の同期中にエラーが発生しました: $e');
    }
  }

  /// Update reaction for a post
  Future<UiState<void>> updateReaction(
    String postId,
    String reactionType,
    bool isActive,
  ) async {
    try {
      final uri = Uri.parse('${Env.apiBaseUrl}/posts/$postId/reactions');
      final body = {
        'type': reactionType,
        'active': isActive,
      };
      
      final response = await _httpClient.put(
        uri,
        headers: Env.defaultHeaders,
        body: jsonEncode(body),
      ).timeout(Duration(seconds: Env.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        return UiStateUtils.success(null);
      } else {
        return UiStateUtils.error('リアクションの更新に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      return UiStateUtils.error('リアクションの更新中にエラーが発生しました: $e');
    }
  }

  /// Update learning history for a card
  Future<UiState<void>> updateLearningHistory(
    String cardId,
    String result,
  ) async {
    try {
      final uri = Uri.parse('${Env.apiBaseUrl}/cards/$cardId/history');
      final body = {
        'result': result,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final response = await _httpClient.post(
        uri,
        headers: Env.defaultHeaders,
        body: jsonEncode(body),
      ).timeout(Duration(seconds: Env.apiTimeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UiStateUtils.success(null);
      } else {
        return UiStateUtils.error('学習履歴の更新に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      return UiStateUtils.error('学習履歴の更新中にエラーが発生しました: $e');
    }
  }

  /// Delete a post
  Future<UiState<void>> deletePost(String postId) async {
    try {
      final uri = Uri.parse('${Env.apiBaseUrl}/posts/$postId');
      final response = await _httpClient.delete(
        uri,
        headers: Env.defaultHeaders,
      ).timeout(Duration(seconds: Env.apiTimeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return UiStateUtils.success(null);
      } else {
        return UiStateUtils.error('投稿の削除に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      return UiStateUtils.error('投稿の削除中にエラーが発生しました: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}

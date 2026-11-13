import 'dart:convert';
import 'dart:io';

import 'env.dart';

/// Minimal REST client used to prepare and clean server-side CI fixtures.
///
/// It talks to the same REST endpoint as the SDK but authenticates with the
/// app token, so it can set up relations, groups and chat rooms that the
/// local single-device test cannot create through the public API (for
/// example chat rooms on the 4.25 line where the creation API is missing).
final class CiRestClient {
  CiRestClient({
    required String restApi,
    required String appKey,
    required String appToken,
    HttpClient? httpClient,
  })  : _restApi = restApi.replaceFirst(RegExp(r'/+$'), ''),
        _appKey = _parseAppKey(appKey),
        _appToken = appToken,
        _httpClient = httpClient ?? directHttpClient();

  /// Builds the fixture client from the CI dart-defines.
  CiRestClient.fromCiEnvironment()
      : this(
          restApi: ciRestApi,
          appKey: ciAppKey,
          appToken: ciAppToken,
        );

  final String _restApi;
  final List<String> _appKey;
  final String _appToken;
  final HttpClient _httpClient;

  /// Contact relations, server-side view.
  Future<List<String>> fetchContactIds(String userId) async {
    final response = await _request(
      'GET',
      'users/${Uri.encodeComponent(userId)}/contacts/users',
    );
    final data = response['data'];
    if (data is! List) {
      throw FormatException('GET contacts of "$userId": data must be a list');
    }
    return <String>[for (final item in data) if (item is String) item];
  }

  /// Adds bilateral friend relation (bypasses the invite/accept flow).
  ///
  /// The server only supports adding one friend per call
  /// (`POST users/{owner}/contacts/users/{friend}`); the collection-level
  /// POST with a `usernames` body answers HTTP 405 for this app.
  Future<void> addContacts(String owner, List<String> userIds) async {
    if (userIds.isEmpty) return;
    final existing = await fetchContactIds(owner);
    for (final userId in userIds) {
      if (existing.contains(userId)) continue;
      await _request(
        'POST',
        'users/${Uri.encodeComponent(owner)}/contacts/users/'
            '${Uri.encodeComponent(userId)}',
      );
    }
  }

  Future<void> removeContact(String owner, String userId, {bool ignoreNotFound = true}) async {
    await _request(
      'DELETE',
      'users/${Uri.encodeComponent(owner)}/contacts/users/'
          '${Uri.encodeComponent(userId)}',
      ignoreNotFound: ignoreNotFound,
    );
  }

  /// Creates an offline account used as a peer fixture.
  Future<void> createUser(String username, String password) async {
    await _request(
      'POST',
      'users',
      body: <String, Object>{'username': username, 'password': password},
      ignoreConflict: true,
    );
  }

  Future<void> deleteUser(String username) async {
    await _request(
      'DELETE',
      'users/${Uri.encodeComponent(username)}',
      ignoreNotFound: true,
    );
  }

  /// Groups. The SDK-side group fixture is preferred; REST is for members
  /// that must join without an invite/accept round trip.
  Future<String> createGroup({
    required String owner,
    required String name,
    String description = 'flutter ci group',
    List<String> members = const <String>[],
  }) async {
    final response = await _request(
      'POST',
      'groups',
      body: <String, Object>{
        'groupname': name,
        'desc': description,
        'owner': owner,
        'public': true,
        'approval': false,
        'members': members,
      },
    );
    final data = response['data'];
    if (data is Map && data['groupid'] is String) {
      return data['groupid'] as String;
    }
    throw const FormatException('POST groups: response missing data.groupid');
  }

  Future<void> deleteGroup(String groupId) async {
    await _request(
      'DELETE',
      'groups/${Uri.encodeComponent(groupId)}',
      ignoreNotFound: true,
    );
  }

  Future<void> addGroupMembers(String groupId, List<String> userIds) async {
    if (userIds.isEmpty) return;
    await _request(
      'POST',
      'groups/${Uri.encodeComponent(groupId)}/users',
      body: <String, Object>{'usernames': userIds},
    );
  }

  Future<void> removeGroupMember(String groupId, String userId) async {
    await _request(
      'DELETE',
      'groups/${Uri.encodeComponent(groupId)}/users/'
          '${Uri.encodeComponent(userId)}',
      ignoreNotFound: true,
    );
  }

  /// Chat rooms. The 4.25 ohos build has no public create-chat-room API, so
  /// room fixtures are always created through REST.
  Future<String> createChatRoom({
    required String owner,
    required String name,
    String description = 'flutter ci room',
    List<String> members = const <String>[],
    int maxUsers = 1000,
  }) async {
    final response = await _request(
      'POST',
      'chatrooms',
      body: <String, Object>{
        'name': name,
        'description': description,
        'maxusers': maxUsers,
        'owner': owner,
        if (members.isNotEmpty) 'members': members,
      },
    );
    final data = response['data'];
    if (data is Map && data['id'] is String) {
      return data['id'] as String;
    }
    throw const FormatException('POST chatrooms: response missing data.id');
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    await _request(
      'DELETE',
      'chatrooms/${Uri.encodeComponent(chatRoomId)}',
      ignoreNotFound: true,
    );
  }

  Future<void> addChatRoomMembers(String chatRoomId, List<String> userIds) async {
    if (userIds.isEmpty) return;
    await _request(
      'POST',
      'chatrooms/${Uri.encodeComponent(chatRoomId)}/users',
      body: <String, Object>{'usernames': userIds},
    );
  }

  Future<void> removeChatRoomMember(String chatRoomId, String userId) async {
    await _request(
      'DELETE',
      'chatrooms/${Uri.encodeComponent(chatRoomId)}/users/'
          '${Uri.encodeComponent(userId)}',
      ignoreNotFound: true,
    );
  }

  /// Transfers the chat room ownership, used to restore the fixture owner.
  ///
  /// The REST API transfers ownership through `PUT chatrooms/{id}` with a
  /// `newowner` field (there is no `/owner` sub-resource).
  Future<void> changeChatRoomOwner(String chatRoomId, String newOwner) async {
    await _request(
      'PUT',
      'chatrooms/${Uri.encodeComponent(chatRoomId)}',
      body: <String, Object>{'newowner': newOwner},
    );
  }

  /// Reads the server-side chat room detail used to verify room mutations.
  Future<Map<String, dynamic>> fetchChatRoomDetail(String chatRoomId) async {
    final response = await _request(
      'GET',
      'chatrooms/${Uri.encodeComponent(chatRoomId)}',
    );
    final data = response['data'];
    // The single-room GET wraps the room in a one-element list.
    final room = data is List && data.isNotEmpty ? data.first : data;
    if (room is! Map) {
      throw FormatException('GET chatroom "$chatRoomId": data must be a map');
    }
    return Map<String, dynamic>.from(room);
  }

  Future<List<String>> fetchChatRoomMembers(String chatRoomId) async {
    final response = await _request(
      'GET',
      'chatrooms/${Uri.encodeComponent(chatRoomId)}/users',
    );
    final data = response['data'];
    if (data is! List) {
      throw const FormatException('GET chatroom users: data must be a list');
    }
    final members = <String>[];
    for (final item in data) {
      if (item is String) {
        members.add(item);
      } else if (item is Map) {
        final member = item['member'];
        final owner = item['owner'];
        if (member is String) {
          members.add(member);
        }
        if (owner is String) {
          members.add(owner);
        }
      }
    }
    return members;
  }

  /// Reads the chat room admin list from the server.
  Future<List<String>> fetchChatRoomAdmins(String chatRoomId) async {
    final response = await _request(
      'GET',
      'chatrooms/${Uri.encodeComponent(chatRoomId)}/admin',
    );
    final data = response['data'];
    if (data is! List) {
      throw const FormatException('GET chatroom admins: data must be a list');
    }
    return <String>[
      for (final item in data)
        if (item is String) item,
    ];
  }

  /// Reads the chat room announcement from the server.
  Future<String?> fetchChatRoomAnnouncement(String chatRoomId) async {
    final response = await _request(
      'GET',
      'chatrooms/${Uri.encodeComponent(chatRoomId)}/announcement',
    );
    final data = response['data'];
    if (data is Map && data['announcement'] is String) {
      return data['announcement'] as String;
    }
    return null;
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, Object?>? body,
    bool ignoreNotFound = false,
    bool ignoreConflict = false,
  }) async {
    final uri = Uri.parse(
      '$_restApi/${Uri.encodeComponent(_appKey[0])}/'
      '${Uri.encodeComponent(_appKey[1])}/$path',
    );
    final request = await _httpClient.openUrl(method, uri);
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    request.headers.set(
      HttpHeaders.authorizationHeader,
      'Bearer $_appToken',
    );
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final text = await utf8.decoder.bind(response).join();
    Object? decoded;
    if (text.isEmpty) {
      decoded = <String, dynamic>{};
    } else {
      try {
        decoded = jsonDecode(text);
      } on FormatException {
        throw HttpException(
          'HTTP ${response.statusCode}: invalid JSON response',
          uri: uri,
        );
      }
    }
    if ((response.statusCode == HttpStatus.notFound && ignoreNotFound) ||
        (response.statusCode == HttpStatus.conflict && ignoreConflict)) {
      return decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded is Map
          ? <Object>[decoded['error'], decoded['error_description']]
              .whereType<Object>()
              .join(' ')
          : decoded.toString();
      throw HttpException('HTTP ${response.statusCode}: $error', uri: uri);
    }
    if (decoded is! Map) {
      throw FormatException('$method $path response must be a JSON object');
    }
    return Map<String, dynamic>.from(decoded);
  }

  void close() => _httpClient.close(force: true);
}

/// A direct (no proxy) HTTP client with bounded connection timeout.
HttpClient directHttpClient() {
  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..findProxy = (_) => 'DIRECT';
  return client;
}

List<String> _parseAppKey(String appKey) {
  final parts = appKey.split('#');
  if (parts.length != 2 || parts.any((part) => part.isEmpty)) {
    throw FormatException('invalid appKey, expected orgName#appName: $appKey');
  }
  return parts;
}

import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:sweyer_plugin/sweyer_plugin.dart';
import '../test.dart';

/// An Entry in the [FakeContentChannel.favoriteRequestLog].
class FavoriteLogEntry {
  /// The set of songs that were modified.
  final Set<Song> songs;

  /// `true` if a request was made to make the songs favorite, `false` if the request was made to unfavor them.
  final bool setFavorite;

  const FavoriteLogEntry(this.songs, this.setFavorite);

  @override
  String toString() => '${runtimeType.toString()}(songs=$songs, setFavorite=$setFavorite)';

  @override
  bool operator ==(Object other) =>
      other is FavoriteLogEntry && setFavorite == other.setFavorite && setEquals(songs, other.songs);

  @override
  int get hashCode => Object.hash(Object.hashAllUnordered(songs), setFavorite);
}

class FakeSweyerPluginPlatform extends SweyerPluginPlatform {
  FakeSweyerPluginPlatform(TestWidgetsFlutterBinding binding) {
    instance = this;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('content_channel'), (call) {
      /// Ignore [CancellationSignal] calls
      if (call.method == 'cancelAlbumArtLoading') {
        return null;
      }
      throw UnimplementedError('method is not mocked');
    });
  }
  static late FakeSweyerPluginPlatform instance;

  List<Song>? songs;
  List<Album>? albums;
  List<Playlist>? playlists;
  List<Artist>? artists;

  @override
  Future<void> createPlaylist(String name) async {}

  @override
  Future<bool> deleteSongs(List<Map<String, dynamic>> songs) async {
    return true;
  }

  @override
  Future<void> fixAlbumArt(int albumId) async {}

  @override
  Future<void> insertSongsInPlaylist({
    required int index,
    required List<int> songIds,
    required int playlistId,
  }) async {}

  @override
  Future<bool> isIntentActionView() async {
    return false;
  }

  @override
  Future<Uint8List?> loadAlbumArt({
    required String uri,
    required Size size,
    required String cancellationSignalId,
  }) async {
    return Uint8List.fromList(kBlueSquarePng);
  }

  @override
  Future<void> cancelAlbumArtLoad({required String id}) async {}

  @override
  Future<bool> moveSongInPlaylist({required int playlistId, required int from, required int to}) async {
    return true;
  }

  @override
  Future<void> removeFromPlaylistAt({required List<int> indexes, required int playlistId}) async {}

  @override
  Future<void> removePlaylists(List<int> playlistIds) async {}

  @override
  Future<void> renamePlaylist(int playlistId, String name) async {}

  @override
  Future<Iterable<Map<String, dynamic>>> retrieveAlbums() async {
    final albumsList = albums ?? [albumWith()];
    return albumsList.map((album) => album.toMap());
  }

  @override
  Future<Iterable<Map<String, dynamic>>> retrieveArtists() async {
    return (artists ?? [artistWith()]).map((artist) => artist.toMap());
  }

  @override
  Future<Iterable<Map<String, dynamic>>> retrieveGenres() async {
    return [];
  }

  @override
  Future<Iterable<Map<String, dynamic>>> retrievePlaylists() async {
    return (playlists ?? [playlistWith()]).map((playlist) => playlist.toMap());
  }

  @override
  Future<Iterable<Map<String, dynamic>>> retrieveSongs() async {
    return (songs ?? [songWith()]).map((song) => song.toMap());
  }

  /// The log of all recorded [setSongsFavorite] calls.
  List<FavoriteLogEntry> get favoriteRequestLog => UnmodifiableListView(_favoriteRequestLog);
  final List<FavoriteLogEntry> _favoriteRequestLog = [];

  @override
  Future<bool> setSongsFavorite(List<int> songIds, bool value) async {
    _favoriteRequestLog.add(FavoriteLogEntry(songIds.map((id) => _songById(id)!).toSet(), value));
    return true;
  }

  /// Get a song by its [id].
  Song? _songById(int id) => songs?.firstWhere((song) => song.id == id);
}

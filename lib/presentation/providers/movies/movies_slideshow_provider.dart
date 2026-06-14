
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final moviesSlidesshowProvider = Provider<List<Movie>>((ref) {
  final nowPlayingsMovie = ref.watch(nowPlayingMoviesProvider);
  if (nowPlayingsMovie.isEmpty) return [];
  return nowPlayingsMovie.sublist(0,6);
});
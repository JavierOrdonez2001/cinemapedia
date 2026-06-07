import 'package:cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/movie_moviedb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fakeMovieDB = MovieMovieDB(
    adult: false,
    backdropPath: '/abc123.jpg',
    genreIds: [28, 12],
    id: 1,
    originalLanguage: 'en',
    originalTitle: 'Test Movie',
    overview: 'Una película de prueba',
    popularity: 9.5,
    posterPath: '/poster123.jpg',
    releaseDate: DateTime(2024, 1, 15),
    title: 'Película de Prueba',
    video: false,
    voteAverage: 8.2,
    voteCount: 1500,
  );

  test('MovieMapper convierte correctamente a entidad Movie', () {
    final movie = MovieMapper.movieDBToEntity(fakeMovieDB);

    expect(movie.id, 1);
    expect(movie.title, 'Película de Prueba');
    expect(movie.voteAverage, 8.2);
  });

  test('backdropPath construye la URL completa cuando no está vacío', () {
    final movie = MovieMapper.movieDBToEntity(fakeMovieDB);

    expect(movie.backdropPath, 'https://image.tmdb.org/t/p/w500/abc123.jpg');
  });

  test('backdropPath usa imagen por defecto cuando está vacío', () {
    final movieSinBackdrop = MovieMovieDB(
      adult: false,
      backdropPath: '',
      genreIds: [],
      id: 2,
      originalLanguage: 'en',
      originalTitle: 'Sin Backdrop',
      overview: '',
      popularity: 1.0,
      posterPath: '',
      releaseDate: DateTime(2024, 1, 1),
      title: 'Sin Backdrop',
      video: false,
      voteAverage: 5.0,
      voteCount: 10,
    );

    final movie = MovieMapper.movieDBToEntity(movieSinBackdrop);

    expect(movie.backdropPath, 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg');
  });
}

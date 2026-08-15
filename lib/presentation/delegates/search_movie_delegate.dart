import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';

typedef SearchMovieCallback = Future<List<Movie>> Function( String query );

class SearchMovieDelegate extends SearchDelegate<Movie?> {
  final SearchMovieCallback searchMovie;

  SearchMovieDelegate({required this.searchMovie});



  @override
  String get searchFieldLabel => 'Buscar película';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      FadeIn(
          animate: query.isNotEmpty,
          child: IconButton(
              onPressed: () {
                query = '';
              },
              icon: const Icon(Icons.refresh_rounded)))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: (() {
          close(context, null);
        }),
        icon: const Icon(Icons.arrow_back_rounded));
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text('buildResults');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: searchMovie(query), 
      builder: ((context, snapshot) {
        final movies = snapshot.data ?? [];
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: ((context, index) {
            final movie = movies[index];
            return ListTile(title: Text(movie.title));
          })
          );
      })
      );
  }
}

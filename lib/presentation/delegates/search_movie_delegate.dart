import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';

typedef SearchMovieCallback = Future<List<Movie>> Function(String query);

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
              itemBuilder: ((context, index) => _MovieItem(movie: movies[index],)));
        }));
  }
}

class _MovieItem extends StatelessWidget {
  final Movie movie;
  const _MovieItem({required this.movie});

  @override
  Widget build(BuildContext context) {

    final textStyle = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return  Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 5, horizontal: 10), child: Row(children: [
      SizedBox(
        width: size.width * 0.2,
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(20),
          child: Image.network(movie.posterPath, 
          loadingBuilder: ((context, child, loadingProgress) => FadeIn(child: child)),
          ),
        ),
      ),

      const SizedBox(width: 10),

      SizedBox(
        width: size.width * 0.7,
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( movie.title, style: textStyle.titleMedium),
          (movie.overview.length > 100) 
          ? Text('${movie.overview.substring(0,100)}...')
          : Text(movie.overview),

          Row(children: [
            Icon( Icons.star_half_rounded, color: Colors.yellow.shade800,),
            Text(HumanFormats.number(movie.voteAverage, 1), style: textStyle.bodyMedium!.copyWith(color: Colors.yellow.shade900))
          ],)
        ],),
      )
    ],),);
  }
}

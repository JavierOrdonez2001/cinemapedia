import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/actors/actors_by_movie_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const name = "movie-screen";
  final String movieId;

  const MovieScreen({super.key, required this.movieId});

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];

    if (movie == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(
              delegate:
                  SliverChildBuilderDelegate(childCount: 1, ((context, index) {
            return _MovieView(
              movie: movie,
            );
          })))
        ],
      ),
    );
  }
}

class _MovieView extends StatelessWidget {
  final Movie movie;
  const _MovieView({required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //* Imagen redondeada
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(movie.posterPath, width: size.width * 0.3),
              ),

              const SizedBox(
                width: 10,
              ),

              // * Descripcion

              SizedBox(
                width: (size.width - 40) * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: textStyles.titleLarge),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(movie.overview),
                  ],
                ),
              ),
            ],
          ),
        ),

        // * Generos de la pelicula

        Padding(
          padding: const EdgeInsetsGeometry.all(8),
          child: Wrap(
            children: [
              ...movie.genreIds.map((gender) => Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Chip(
                        label: Text(gender),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(20))),
                  ))
            ],
          ),
        ),

        // TODO: Mostrar actores

        _ActorsByMovie(movieId: movie.id.toString()),

        const SizedBox(
          height: 100,
        )
      ],
    );
  }
}

class _CustomSliverAppBar extends StatelessWidget {
  final Movie movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
          // title: Text(movie.title,
          //     textAlign: TextAlign.start,
          //     style: const TextStyle(color: Colors.white, fontSize: 20)),
          background: Stack(
        children: [
          // * imagen de fondo
          SizedBox.expand(
            child: Image.network(movie.posterPath, fit: BoxFit.cover, loadingBuilder:((context, child, loadingProgress) {
              if (loadingProgress != null) return const SizedBox();
              return FadeIn(child: child);
            }),),
          ),

          // * Gradiante
          const SizedBox.expand(
            child: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: AlignmentGeometry.topLeft,
                        end: AlignmentGeometry.bottomCenter,
                        stops: [
                  0.0,
                  0.95
                ],
                        colors: [
                  Color.fromARGB(0, 0, 0, 0),
                  Colors.black87,
                ]))),
          )
        ],
      )),
    );
  }
}

class _ActorsByMovie extends ConsumerWidget {
  final String movieId;
  const _ActorsByMovie({required this.movieId});

  @override
  Widget build(BuildContext context, ref) {
    final actorsByMovie = ref.watch(actorsByMovieProvider);

    if (actorsByMovie[movieId] == null) {
      return const CircularProgressIndicator(strokeWidth: 2);
    }

    final actors = actorsByMovie[movieId];

    return SizedBox(
      height: 300,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: actors!.length,
          itemBuilder: ((context, index) {
            final actor = actors[index];

            return Container(
              padding: EdgeInsets.all(8.0),
              width: 135,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //* Actor Photo
                  FadeInRight(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        actor.profilePath,
                        height: 180,
                        width: 135,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  //* Actor name

                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    actor.name,
                    maxLines: 2,
                  ),
                  Text(
                    actor.character ?? '',
                    maxLines: 2,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            );
          })),
    );
  }
}

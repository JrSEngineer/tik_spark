import 'dart:developer';

import 'package:bluesky/bluesky.dart' as bsky;
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tik_spark/models/feed_video_model.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  final ValueNotifier<List<FeedVideoModel>> _videos = ValueNotifier([]);

  late ChewieController _videoController;

  final _feedGeneratorUri = bsky.AtUri.parse('at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids');

  @override
  void initState() {
    super.initState();

    _loadFeed();

    _pageController.addListener(() {
      _videoController.pause();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController.dispose();

    super.dispose();
  }

  Future<void> _loadFeed() async {
    final session = await bsky.createSession(
      identifier: 'jrzanka.bsky.social',
      password: '1614181151Bs!',
    );

    _videos.value.clear();

    final bluesky = bsky.Bluesky.fromSession(session.data);
    final feed = await bluesky.feed.getFeed(generatorUri: _feedGeneratorUri, limit: 5);
    final result = feed.data.toJson()['feed'];

    log(result.toString().replaceAll('{', '{\n').replaceAll('}', '\n}').replaceAll(',', ',\n'));

    result.map((e) {
      final video = FeedVideoModel.fromJson(e['post']);

      _videos.value.add(video);
      return video;
    }).toList();

    _videos.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _videos,
          builder: (context, value, child) {
            return _videos.value.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : PageView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    controller: _pageController,
                    itemCount: _videos.value.length,
                    itemBuilder: (context, index) {
                      final video = _videos.value[index];

                      _videoController = ChewieController(
                        autoPlay: false,
                        deviceOrientationsAfterFullScreen: [
                          DeviceOrientation.portraitUp,
                        ],
                        deviceOrientationsOnEnterFullScreen: [
                          DeviceOrientation.portraitUp,
                        ],
                        playbackSpeeds: [1, 1.5, 2],
                        draggableProgressBar: false,
                        autoInitialize: true,
                        aspectRatio: 9 / 16,
                        allowPlaybackSpeedChanging: false,
                        looping: true,
                        zoomAndPan: false,
                        showControlsOnInitialize: false,
                        allowFullScreen: true,
                        allowMuting: true,
                        fullScreenByDefault: true,
                        videoPlayerController: VideoPlayerController.networkUrl(Uri.parse(video.videoUrl)),
                        subtitle: Subtitles([
                          Subtitle(
                            text: video.authorName,
                            start: const Duration(seconds: 0),
                            end: const Duration(seconds: 0),
                            index: index,
                          ),
                        ]),
                      );

                      return Stack(
                        children: [
                          Chewie(
                            controller: _videoController,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(video.authorAvatar),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    video.authorName,
                                    style: const TextStyle(color: Colors.white, fontSize: 20),
                                  ),
                                  Text(
                                    video.handle,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}

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
  final ValueNotifier<List<FeedVideoModel>> _videos = ValueNotifier([]);
  final PageController _pageController = PageController();
  late ChewieController _videoController;
  final _feedGeneratorUri = bsky.AtUri.parse('at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids');

  final ValueNotifier<bool> _loadingVideos = ValueNotifier(false);

  late bsky.FeedService _feed;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(milliseconds: 500),
      () async {
        _feed = await _getFeedService();
        await _loadFeed(_feed);
      },
    );

    Future.delayed(const Duration(seconds: 1));

    _pageController.addListener(() async {
      bool listEndReached = _pageController.position.maxScrollExtent == _pageController.offset;
      if (listEndReached) {
        await _loadFeed(_feed);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController.dispose();

    super.dispose();
  }

  Future<bsky.FeedService> _getFeedService() async {
    _loadingVideos.value = true;

    final session = await bsky.createSession(
      identifier: 'jrzanka.bsky.social',
      password: '1614181151Bs!',
    );

    final bluesky = bsky.Bluesky.fromSession(session.data);

    return bluesky.feed;
  }

  Future<void> _loadFeed(bsky.FeedService feed) async {
    final blueskyFeed = await feed.getFeed(generatorUri: _feedGeneratorUri, limit: 5);
    final result = blueskyFeed.data.toJson()['feed'];

    log(result.toString().replaceAll('{', '{\n').replaceAll('}', '\n}').replaceAll(',', ',\n'));

    result.map((e) {
      final video = FeedVideoModel.fromJson(e['post']);

      _videos.value.add(video);
      return video;
    }).toList();

    _loadingVideos.value = false;

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
                : _loadingVideos.value
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => _loadFeed(_feed),
                        child: PageView.builder(
                          scrollDirection: Axis.vertical,
                          controller: _pageController,
                          itemCount: _videos.value.length + 1,
                          itemBuilder: (context, index) {
                            bool hasVideosLeft = index < _videos.value.length;

                            if (hasVideosLeft) {
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
                                startAt: const Duration(milliseconds: 300),
                                autoInitialize: true,
                                aspectRatio: 2 / 3,
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
                            } else {
                              return const SizedBox.shrink(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                        ),
                      );
          },
        ),
      ),
    );
  }
}

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tik_spark/models/feed_video_model.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final FeedVideoModel video;
  final int index;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.index,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late ChewieController _videoController;
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
        allowBackgroundPlayback: false,
      ),
    );

    _videoController = ChewieController(
      autoPlay: false,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      errorBuilder: (context, errorMessage) {
        _videoController.videoPlayerController.dispose();
        return Center(
          child: Text(errorMessage),
        );
      },
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
      videoPlayerController: _videoPlayerController,
      subtitle: Subtitles([
        Subtitle(
          text: widget.video.authorName,
          start: const Duration(seconds: 0),
          end: const Duration(seconds: 0),
          index: widget.index,
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  image: NetworkImage(widget.video.authorAvatar),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.authorName,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  widget.video.handle,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

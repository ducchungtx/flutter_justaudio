import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  String musicUrl =
      "https://basicenglishspeaking.com/wp-content/uploads/audio/QA/QA-01.mp3"; // Insert your music URL
  String thumbnailImgUrl =
      "https://media.api.mythaco.vn/index.php/s/pg6iN5eGqSFWrBY/download/1700819449447_Untitled-1.jpg?filename=1700819449447_Untitled-1.jpg"; // Insert your thumbnail URL
  var player = AudioPlayer();
  bool loaded = false;
  bool playing = false;

  void loadMusic() async {
    await player.setUrl(musicUrl);
    setState(() {
      loaded = true;
    });
  }

  void playMusic() async {
    setState(() {
      playing = true;
    });
    await player.play();
  }

  void pauseMusic() async {
    setState(() {
      playing = false;
    });
    await player.pause();
  }

  @override
  void initState() {
    loadMusic();
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Podcast"),
      ),
      body: Column(
        children: [
          const Spacer(
            flex: 2,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              thumbnailImgUrl,
              height: 350,
              width: 350,
              fit: BoxFit.fitWidth,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: StreamBuilder(
                stream: player.positionStream,
                builder: (context, snapshot1) {
                  final Duration duration = loaded
                      ? snapshot1.data as Duration
                      : const Duration(seconds: 0);
                  return StreamBuilder(
                      stream: player.bufferedPositionStream,
                      builder: (context, snapshot2) {
                        final Duration bufferedDuration = loaded
                            ? snapshot2.data as Duration
                            : const Duration(seconds: 0);
                        return SizedBox(
                          height: 30,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ProgressBar(
                              progress: duration,
                              total:
                                  player.duration ?? const Duration(seconds: 0),
                              buffered: bufferedDuration,
                              timeLabelPadding: -1,
                              timeLabelTextStyle: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                              progressBarColor: Colors.red,
                              baseBarColor: Colors.grey[200],
                              bufferedBarColor: Colors.grey[350],
                              thumbColor: Colors.red,
                              onSeek: loaded
                                  ? (duration) async {
                                      await player.seek(duration);
                                    }
                                  : null,
                            ),
                          ),
                        );
                      });
                }),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                width: 10,
              ),
              IconButton(
                  onPressed: loaded
                      ? () async {
                          if (player.position.inSeconds >= 10) {
                            await player.seek(Duration(
                                seconds: player.position.inSeconds - 10));
                          } else {
                            await player.seek(const Duration(seconds: 0));
                          }
                        }
                      : null,
                  icon: const Icon(Icons.fast_rewind_rounded)),
              Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.red),
                child: IconButton(
                    onPressed: loaded
                        ? () {
                            if (playing) {
                              pauseMusic();
                            } else {
                              playMusic();
                            }
                          }
                        : null,
                    icon: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    )),
              ),
              IconButton(
                  onPressed: loaded
                      ? () async {
                          if (player.position.inSeconds + 10 <=
                              player.duration!.inSeconds) {
                            await player.seek(Duration(
                                seconds: player.position.inSeconds + 10));
                          } else {
                            await player.seek(const Duration(seconds: 0));
                          }
                        }
                      : null,
                  icon: const Icon(Icons.fast_forward_rounded)),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const Spacer(
            flex: 2,
          )
        ],
      ),
    );
  }
}

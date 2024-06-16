import 'package:double_tap_to_exit/double_tap_to_exit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:pan_tv/data/channels.dart';
import 'package:pan_tv/models/channel_model.dart';
import 'package:pan_tv/utils/constants.dart';
import 'package:pan_tv/utils/player_provider.dart';
import 'package:pan_tv/utils/styles.dart';
import 'package:pan_tv/widgets/genre_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentGenreIndex = 0;

  late VideoPlayerController _controller;
  bool buffering = false;
  bool error = false;

  /// Main Screen that displays the Live Tvs
  /// [GenreWidget] displays the current genre to choose from
  /// set the [currentPlaying] with first item in [Channels]

  late ChannelModel currentPlaying;

  /// Get The [ScaffoldState] for you to open the [Drawer]
  GlobalKey key = GlobalKey<ScaffoldState>();

  /// Change The [DeviceOrientation] when user enters or exits [fullScreen]
  Future changeOrientation(bool fullScreen) async {
    if (fullScreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: []);
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    }
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    Map firstItem = Channels.channels[currentGenreIndex].entries.first.value[0];
    currentPlaying = ChannelModel(
        id: firstItem['id'],
        channelName: firstItem['channelName'],
        description: firstItem['description'],
        streamLabel: firstItem['streamLabel'],
        streamUrl: firstItem['streamUrl'],
        thumbnailUrl: firstItem['thumbnailUrl']);

    _controller =
        VideoPlayerController.networkUrl(Uri.parse(currentPlaying.streamUrl))
          ..initialize().then((_) {
            setState(() {});
          }).then((value) {
            return _controller.play();
          });
    _controller.addListener(playerListener);
  }

  /// Listen for [VideoPlayerController] events
  /// Mainly these thing play/pause, error, mute/unmute and buffering

  playerListener() {
    if (_controller.value.isBuffering) {
      setState(() {
        buffering = true;
      });
    } else {
      /// Clear buffering if not buffering
      if (buffering == true) {
        setState(() {
          buffering = false;
        });
      }
    }

    if (_controller.value.hasError) {
      /// If there is an error in the stream update the ui
      setState(() {
        error = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(playerListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DoubleTapToExit(
      snackBar: const SnackBar(
        content: Text('Tap again to exit !'),
      ),
      child: Scaffold(
        key: key,
        drawer: Drawer(
          backgroundColor: Styles.mainGrey,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Column(
            children: [
              SizedBox(
                height: size.height * .9,
                child: ListView(
                  children: [
                    SizedBox(
                      height: 120,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.asset("assets/images/pan.png"),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.of(context).pop();
                        showAboutDialog();
                      },
                      leading: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                      title: const Text(
                        Constants.about,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      subtitle: const Text(
                        Constants.aboutDescription,
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ),
                    /*
                    ListTile(
                      onTap: () {},
                      leading: const Icon(
                        Icons.coffee,
                        color: Colors.white,
                      ),
                      title: const Text(
                        Constants.byMeACoffee,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      subtitle: const Text(
                        Constants.supportThisApp,
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ), */
                  ],
                ),
              ),
              const Text(
                Constants.version,
                style: TextStyle(fontSize: 13, color: Colors.white30),
              )
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              context.watch<PlayerProvider>().fullScreen
                  ? const SizedBox()
                  : const SizedBox(
                      height: 5,
                    ),
              Stack(
                children: [
                  playerWidget(),
                  context.watch<PlayerProvider>().fullScreen
                      ? const SizedBox()
                      : Positioned(
                          left: 10,
                          top: 10,
                          child: SafeArea(child: Builder(builder: (context) {
                            return IconButton(
                                onPressed: () {
                                  if (Scaffold.of(context).isDrawerOpen) {
                                    Scaffold.of(context).closeDrawer();
                                  } else {
                                    Scaffold.of(context).openDrawer();
                                  }
                                },
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                ));
                          })))
                ],
              ),
              context.watch<PlayerProvider>().fullScreen
                  ? const SizedBox()
                  : const SizedBox(
                      height: 3,
                    ),
              context.watch<PlayerProvider>().fullScreen
                  ? const SizedBox()
                  : SizedBox(
                      width: size.width,
                      height: size.height * .08,
                      child: ListView.builder(
                          itemCount: Channels.channels.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            String genre =
                                Channels.channels[index].entries.first.key;

                            ///Pass the required parameter to the [GenreWidget]
                            return GenreWidget(
                              onTap: () {
                                setState(() {
                                  currentGenreIndex = index;
                                });
                              },
                              selected: currentGenreIndex == index,
                              title: genre,
                            );
                          })),
              context.watch<PlayerProvider>().fullScreen
                  ? const SizedBox()
                  : const SizedBox(
                      height: 3,
                    ),
              context.watch<PlayerProvider>().fullScreen
                  ? const SizedBox()
                  : SizedBox(
                      height: size.height * .55,
                      child: ListView.builder(
                          itemCount: Channels.channels[currentGenreIndex]
                              .entries.first.value.length,
                          itemBuilder: (context, index) {
                            Map<String, String> channel = Channels
                                .channels[currentGenreIndex]
                                .entries
                                .first
                                .value[index];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Divider(
                                  color: Styles.secondaryGrey,
                                  height: .5,
                                  thickness: .5,
                                ),
                                ListTile(
                                  onTap: () {
                                    /// First remove the Listener, then dispose, then set the controller
                                    _controller.removeListener(playerListener);
                                    _controller.dispose();
                                    setState(() {
                                      currentPlaying = ChannelModel(
                                          channelName: channel['channelName']!,
                                          id: channel['id']!,
                                          description: channel['description']!,
                                          streamLabel: channel['streamLabel']!,
                                          streamUrl: channel['streamUrl']!,
                                          thumbnailUrl:
                                              channel['thumbnailUrl']!);
                                      _controller =
                                          VideoPlayerController.networkUrl(
                                              Uri.parse(channel['streamUrl']!))
                                            ..initialize().then((_) {
                                              setState(() {});
                                            }).then((value) {
                                              return _controller.play();
                                            });
                                      _controller.addListener(playerListener);
                                    });
                                  },
                                  minVerticalPadding: 0,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10),
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        width: 60,
                                        child: Image.asset(
                                            channel['thumbnailUrl']!),
                                      ),
                                      const VerticalDivider(
                                        color: Styles.secondaryGrey,
                                      )
                                    ],
                                  ),
                                  title: Text(
                                    channel['channelName']!,
                                    style: TextStyle(
                                        color:
                                            currentPlaying.id == channel['id']
                                                ? Styles.mainColor
                                                : Colors.white,
                                        fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    channel['description']!,
                                    style: const TextStyle(
                                        color: Colors.white30,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const VerticalDivider(
                                        color: Styles.secondaryGrey,
                                        endIndent: 0,
                                        indent: 0,
                                        thickness: 1,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      currentPlaying.id == channel['id']
                                          ? SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: Center(
                                                child: Lottie.asset(
                                                    'assets/json/live.json',
                                                    fit: BoxFit.cover),
                                              ),
                                            )
                                          : SizedBox(
                                              width: 30,
                                              child: Text(
                                                channel['streamLabel']!,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  color: Styles.secondaryGrey,
                                  height: .5,
                                  thickness: .5,
                                ),
                              ],
                            );
                          }),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Stack playerWidget() {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          color: Styles.mainGrey,
          width: size.width,
          height: context.watch<PlayerProvider>().fullScreen
              ? size.height
              : size.height * .3,
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: 16 / 9,
                  child: VideoPlayer(_controller),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator()),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      Constants.loading,
                      style: TextStyle(fontSize: 13, color: Colors.white),
                    )
                  ],
                ),
        ),
        Positioned.fill(
            child: buffering
                ? const Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator()),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          Constants.loading,
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        )
                      ],
                    ),
                  )
                : const SizedBox()),
        Positioned(
            bottom: 20,
            child: SizedBox(
              width: size.width,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        context.watch<PlayerProvider>().fullScreen ? 50 : 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: context.watch<PlayerProvider>().fullScreen
                              ? size.width * .22
                              : size.width * .3,
                          child: Text(
                            currentPlaying.channelName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 35,
                          height: 20,
                          decoration: BoxDecoration(
                              color: Styles.secondaryColor,
                              borderRadius: BorderRadius.circular(2)),
                          child: Text(
                            currentPlaying.streamLabel,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                    GestureDetector(
                        onTap: () {
                          if (Provider.of<PlayerProvider>(context,
                                  listen: false)
                              .fullScreen) {
                            Provider.of<PlayerProvider>(context, listen: false)
                                .changeOrientation(false);
                            changeOrientation(false);
                          } else {
                            Provider.of<PlayerProvider>(context, listen: false)
                                .changeOrientation(true);
                            changeOrientation(true);
                          }
                        },
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
            ))
      ],
    );
  }

  showAboutDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape:
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              backgroundColor: Styles.mainGrey,
              title: SizedBox(
                  height: 25, child: Image.asset("assets/images/pan.png")),
              content: const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Pan TV is a free tv live streaming platform that allows you to watch free movies and sports.",
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ));
  }
}

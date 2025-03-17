import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:masterstudy_app/data/core/constants/assets_path.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/theme/app_color.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/lesson_stream/bloc.dart';
import 'package:masterstudy_app/ui/screens/assignment/assignment_screen.dart';
import 'package:masterstudy_app/ui/screens/final/final_screen.dart';
import 'package:masterstudy_app/ui/screens/lesson_video/lesson_video_screen.dart';
import 'package:masterstudy_app/ui/screens/questions/questions_screen.dart';
import 'package:masterstudy_app/ui/screens/quiz_lesson/quiz_lesson_screen.dart';
import 'package:masterstudy_app/ui/screens/text_lesson/text_lesson_screen.dart';
import 'package:masterstudy_app/ui/screens/user_course_locked/user_course_locked_screen.dart';
import 'package:masterstudy_app/ui/widgets/warning_lesson_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonStreamScreenArgs {
  final int courseId;
  final int lessonId;
  final String authorAva;
  final String authorName;

  LessonStreamScreenArgs(this.courseId, this.lessonId, this.authorAva, this.authorName);
}

class LessonStreamScreen extends StatelessWidget {
  static const routeName = 'lessonStreamScreen';
  final LessonStreamBloc _bloc;

  const LessonStreamScreen(this._bloc) : super();

  @override
  Widget build(BuildContext context) {
    final LessonStreamScreenArgs args = ModalRoute.of(context)?.settings.arguments as LessonStreamScreenArgs;

    return BlocProvider<LessonStreamBloc>(
        create: (c) => _bloc, child: _LessonStreamScreenWidget(args.courseId, args.lessonId, args.authorAva, args.authorName));
  }
}

class _LessonStreamScreenWidget extends StatefulWidget {
  final int courseId;
  final int lessonId;
  final String authorAva;
  final String authorName;

  const _LessonStreamScreenWidget(this.courseId, this.lessonId, this.authorAva, this.authorName);

  @override
  State<StatefulWidget> createState() {
    return _LessonStreamScreenState();
  }
}

class _LessonStreamScreenState extends State<_LessonStreamScreenWidget> {
  late LessonStreamBloc _bloc;
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<LessonStreamBloc>(context)..add(FetchEvent(widget.courseId, widget.lessonId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (BuildContext context, state) {
        if (state is CacheWarningLessonStreamState) {
          showDialog(context: context, builder: (context) => WarningLessonDialog());
        }
      },
      child: BlocBuilder<LessonStreamBloc, LessonStreamState>(
        bloc: _bloc,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: HexColor.fromHex("#151A25"),
            appBar: AppBar(backgroundColor: HexColor.fromHex("#273044"), title: _buildTitle(state), actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 15.0),
                child: SizedBox(
                  width: 42,
                  height: 30,
                  child: ElevatedButton(
                    // TODO:
                    style: ElevatedButton.styleFrom(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      padding: EdgeInsets.all(0.0),
                      backgroundColor: HexColor.fromHex("#FFFFFF").withOpacity(0.1),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        QuestionsScreen.routeName,
                        arguments: QuestionsScreenArgs(widget.lessonId, 1),
                      );
                    },

                    child: SvgPicture.asset(
                      ImageVectorPath.faq,
                      color: HexColor.fromHex("#FFFFFF"),
                      width: 20.0,
                      height: 20.0,
                    ),
                  ),
                ),
              )
            ]),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: loadPlayer(state),
              ),
            ),
            bottomNavigationBar: _buildBottom(state),
          );
        },
      ),
    );
  }

  _buildTitle(state) {
    if (state is InitialLessonStreamState) {}

    if (state is LoadedLessonStreamState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            state.lessonResponse.section?.number + ":",
            textScaleFactor: 1.0,
            style: TextStyle(color: Colors.white, fontSize: 14.0),
          ),
          Text(
            state.lessonResponse.section?.label,
            textScaleFactor: 1.0,
            style: TextStyle(color: Colors.white, fontSize: 14.0),
          )
        ],
      );
    }
  }

  loadPlayer(state) {
    if (state is LoadedLessonStreamState) {
      String? videoId = YoutubePlayer.convertUrlToId(state.lessonResponse.video);
      if (videoId != "") {
        _youtubePlayerController = YoutubePlayerController(
          initialVideoId: videoId!,
          flags: YoutubePlayerFlags(
            autoPlay: true,
            isLive: true,
          ),
        );
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Center(
              child: YoutubePlayer(
                  controller: _youtubePlayerController,
                  showVideoProgressIndicator: true,
                  actionsPadding: EdgeInsets.only(left: 16.0),
                  liveUIColor: Colors.red,
                  bottomActions: [
                    CurrentPosition(),
                    SizedBox(width: 10.0),
                    ProgressBar(isExpanded: true),
                    SizedBox(width: 10.0),
                    RemainingDuration(),
                    FullScreenButton(),
                  ],
                  onReady: () {
                    print("YOUTUBE READY");
                  }),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: MaterialButton(
                    height: 50,
                    color: HexColor.fromHex("#CC0000"),
                    onPressed: () {
                      _launchURL(state.lessonResponse.video);
                    },
                    child: Text(
                      localizations!.getLocalization("go_to_live_button"),
                      textScaleFactor: 1.0,
                      style: TextStyle(fontSize: 14.0),
                    ))),
          )
        ],
      );
    }

    return Center(
      child: CircularProgressIndicator(),
    );
  }

  _buildBottom(LessonStreamState state) {
    if (state is InitialLessonStreamState) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is LoadedLessonStreamState) {
      return Container(
        decoration: BoxDecoration(
            color: HexColor.fromHex("#273044"),
            boxShadow: [BoxShadow(color: HexColor.fromHex("#000000").withOpacity(.1), offset: Offset(0, 0), blurRadius: 6, spreadRadius: 2)]),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 35,
                height: 35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0), side: BorderSide(color: HexColor.fromHex("#306ECE"))),
                    padding: EdgeInsets.all(0.0),
                    backgroundColor: AppColor.mainColor,
                  ),
                  onPressed: () {
                    if (state.lessonResponse.prev_lesson != "") {
                      switch (state.lessonResponse.prev_lesson_type) {
                        case "video":
                          Navigator.of(context).pushReplacementNamed(
                            LessonVideoScreen.routeName,
                            arguments: LessonVideoScreenArgs(
                                widget.courseId, int.tryParse(state.lessonResponse.prev_lesson)!, widget.authorAva, widget.authorName, false, true),
                          );
                          break;
                        case "quiz":
                          Navigator.of(context).pushReplacementNamed(
                            QuizLessonScreen.routeName,
                            arguments: QuizLessonScreenArgs(
                                widget.courseId, int.tryParse(state.lessonResponse.prev_lesson)!, widget.authorAva, widget.authorName),
                          );
                          break;
                        case "assignment":
                          Navigator.of(context).pushReplacementNamed(
                            AssignmentScreen.routeName,
                            arguments: AssignmentScreenArgs(
                                widget.courseId, int.tryParse(state.lessonResponse.prev_lesson)!, widget.authorAva, widget.authorName),
                          );
                          break;
                        case "stream":
                          Navigator.of(context).pushReplacementNamed(
                            LessonStreamScreen.routeName,
                            arguments: LessonStreamScreenArgs(
                                widget.courseId, int.tryParse(state.lessonResponse.prev_lesson)!, widget.authorAva, widget.authorName),
                          );
                          break;
                        default:
                          Navigator.of(context).pushReplacementNamed(
                            TextLessonScreen.routeName,
                            arguments: TextLessonScreenArgs(
                                widget.courseId, int.tryParse(state.lessonResponse.prev_lesson)!, widget.authorAva, widget.authorName, false, true),
                          );
                      }
                    } else {
                      var future = Navigator.of(context).pushNamed(
                        FinalScreen.routeName,
                        arguments: FinalScreenArgs(widget.courseId),
                      );
                      future.then((value) {
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: MaterialButton(
                        height: 50,
                        color: AppColor.mainColor,
                        onPressed: () {},
                        child: Text(
                          localizations!.getLocalization("complete_lesson_button"),
                          textScaleFactor: 1.0,
                          style: TextStyle(fontSize: 14.0),
                        ))),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: (state.lessonResponse.next_lesson != "")
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0), side: BorderSide(color: HexColor.fromHex("#306ECE"))),
                          padding: EdgeInsets.all(0.0),
                          backgroundColor: AppColor.mainColor,
                        ),
                        onPressed: () {
                          if (state.lessonResponse.next_lesson_available) {
                            switch (state.lessonResponse.next_lesson_type) {
                              case "video":
                                Navigator.of(context).pushReplacementNamed(
                                  LessonVideoScreen.routeName,
                                  arguments: LessonVideoScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.next_lesson)!, widget.authorAva,
                                      widget.authorName, false, true),
                                );
                                break;
                              case "quiz":
                                Navigator.of(context).pushReplacementNamed(
                                  QuizLessonScreen.routeName,
                                  arguments: QuizLessonScreenArgs(
                                      widget.courseId, int.tryParse(state.lessonResponse.next_lesson)!, widget.authorAva, widget.authorName),
                                );
                                break;
                              case "assignment":
                                Navigator.of(context).pushReplacementNamed(
                                  AssignmentScreen.routeName,
                                  arguments: AssignmentScreenArgs(
                                      widget.courseId, int.tryParse(state.lessonResponse.next_lesson)!, widget.authorAva, widget.authorName),
                                );
                                break;
                              case "stream":
                                Navigator.of(context).pushReplacementNamed(
                                  LessonStreamScreen.routeName,
                                  arguments: LessonStreamScreenArgs(
                                      widget.courseId, int.tryParse(state.lessonResponse.next_lesson)!, widget.authorAva, widget.authorName),
                                );
                                break;
                              default:
                                Navigator.of(context).pushReplacementNamed(
                                  TextLessonScreen.routeName,
                                  arguments: TextLessonScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.next_lesson)!, widget.authorAva,
                                      widget.authorName, false, true),
                                );
                            }
                          } else {
                            Navigator.of(context).pushNamed(
                              UserCourseLockedScreen.routeName,
                              arguments: UserCourseLockedScreenArgs(widget.courseId),
                            );
                          }
                        },
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                      )
                    : Center(),
              )
            ],
          ),
        ),
      );
    }
  }

  _launchURL(String url) async {
    await launch(url);
  }

  @override
  void dispose() {
    super.dispose();
    _youtubePlayerController.dispose();
  }
}

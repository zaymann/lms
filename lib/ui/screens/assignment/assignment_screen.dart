import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:masterstudy_app/data/core/constants/assets_path.dart';
import 'package:masterstudy_app/data/utils.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/theme/app_color.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/assignment/bloc.dart';
import 'package:masterstudy_app/ui/screens/assignment/assignment_state/assignment_pass_unpass.dart';
import 'package:masterstudy_app/ui/screens/assignment/assignment_state/assignment_pending.dart';
import 'package:masterstudy_app/ui/screens/assignment/assignment_state/assignment_preview.dart';
import 'package:masterstudy_app/ui/screens/lesson_stream/lesson_stream_screen.dart';
import 'package:masterstudy_app/ui/screens/lesson_video/lesson_video_screen.dart';
import 'package:masterstudy_app/ui/screens/questions/questions_screen.dart';
import 'package:masterstudy_app/ui/screens/quiz_lesson/quiz_lesson_screen.dart';
import 'package:masterstudy_app/ui/screens/text_lesson/text_lesson_screen.dart';
import 'package:masterstudy_app/ui/widgets/dialog_author.dart';
import 'package:masterstudy_app/ui/widgets/warning_lesson_dialog.dart';

import './assignment_state/assignment_draft.dart';

class AssignmentScreenArgs {
  final int courseId;
  final int assignmentId;
  final String authorAva;
  final String authorName;

  AssignmentScreenArgs(this.courseId, this.assignmentId, this.authorAva, this.authorName);
}

class AssignmentScreen extends StatelessWidget {
  static const routeName = 'assignmentScreen';
  final AssignmentBloc _bloc;

  const AssignmentScreen(this._bloc) : super();

  @override
  Widget build(BuildContext context) {
    final AssignmentScreenArgs args = ModalRoute.of(context)?.settings.arguments as AssignmentScreenArgs;

    return BlocProvider<AssignmentBloc>(
      create: (c) => _bloc,
      child: _AssignmentScreenWidget(
        args.courseId,
        args.assignmentId,
        args.authorAva,
        args.authorName,
      ),
    );
  }
}

class _AssignmentScreenWidget extends StatefulWidget {
  final int courseId;
  final int assignmentId;
  final String authorAva;
  final String authorName;

  const _AssignmentScreenWidget(this.courseId, this.assignmentId, this.authorAva, this.authorName);

  @override
  State<StatefulWidget> createState() => _AssignmentScreenWidgetState();
}

class _AssignmentScreenWidgetState extends State<_AssignmentScreenWidget> {
  late AssignmentBloc _bloc;
  bool assignmentAdd = false;
  late bool demo;

  @override
  void initState() {
    super.initState();
    if (preferences.getBool('demo') == null) {
      demo = false;
    } else {
      demo = preferences.getBool('demo')!;
    }
    _bloc = BlocProvider.of<AssignmentBloc>(context)..add(FetchEvent(widget.courseId, widget.assignmentId));
  }

  final GlobalKey<AssignmentDraftWidgetState> assignmentDraftWidgetState = GlobalKey<AssignmentDraftWidgetState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssignmentBloc, AssignmentState>(
      bloc: _bloc,
      listener: (BuildContext context, AssignmentState state) {
        if (state is CacheWarningAssignmentState) {
          showDialog(context: context, builder: (context) => WarningLessonDialog());
        }
      },
      child: BlocBuilder<AssignmentBloc, AssignmentState>(builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
              backgroundColor: AppColor.mainColor,
              title: Text(
                localizations!.getLocalization("assignment_screen_title"),
                textScaleFactor: 1.0,
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 15.0),
                  child: SizedBox(
                    width: 42,
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        padding: EdgeInsets.all(0.0),
                        backgroundColor: HexColor.fromHex("#3D4557"),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          QuestionsScreen.routeName,
                          arguments: QuestionsScreenArgs(widget.assignmentId, 1),
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
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: _buildContent(state),
              ),
            ),
          ),
          bottomNavigationBar: _buildBottom(state),
        );
      }),
    );
  }

  _buildContent(AssignmentState state) {
    if (state is InitialAssignmentState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[_loading()],
      );
    }

    if (state is LoadedAssignmentState) {
      switch (state.assignmentResponse.status) {
        case "new":
          return AssignmentPreviewWidget(state.assignmentResponse, widget.courseId, widget.assignmentId);
        case "unpassed":
          return AssignmentPassUnpassWidget(_bloc, state.assignmentResponse, widget.courseId, widget.assignmentId,
              widget.authorAva, widget.authorName);
        case "passed":
          return AssignmentPassUnpassWidget(_bloc, state.assignmentResponse, widget.courseId, widget.assignmentId,
              widget.authorAva, widget.authorName);
        case "draft":
          return AssignmentDraftWidget(assignmentDraftWidgetState, _bloc, state.assignmentResponse, widget.courseId,
              widget.assignmentId, state.assignmentResponse.draft_id);
        case "pending":
          return AssignmentPendingWidget(state.assignmentResponse);
        default:
          return _loading();
      }
    }
  }

  _buildBottom(AssignmentState state) {
    if (state is InitialAssignmentState) return _loading();

    if (state is LoadedAssignmentState) {
      switch (state.assignmentResponse.status) {
        case "new":
          return _bottomStatusNew(state);
        case "draft":
          return _bottomStatusDraft(state);
        default:
          return SizedBox(width: 0, height: 0);
      }
    }
  }

  _bottomStatusNew(LoadedAssignmentState state) {
    return Container(
      decoration: BoxDecoration(color: HexColor.fromHex("#FFFFFF"), boxShadow: [
        BoxShadow(
            color: HexColor.fromHex("#000000").withOpacity(.1), offset: Offset(0, 0), blurRadius: 6, spreadRadius: 2)
      ]),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 35,
              height: 35,
              child: (state.assignmentResponse.prev_lesson != "")
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(0.0),
                        backgroundColor: AppColor.mainColor,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            side: BorderSide(color: HexColor.fromHex("#306ECE"))),
                      ),
                      onPressed: () {
                        switch (state.assignmentResponse.prev_lesson_type) {
                          case "video":
                            Navigator.of(context).pushReplacementNamed(
                              LessonVideoScreen.routeName,
                              arguments: LessonVideoScreenArgs(
                                  widget.courseId,
                                  int.tryParse(state.assignmentResponse.prev_lesson)!,
                                  widget.authorAva,
                                  widget.authorName,
                                  false,
                                  true),
                            );
                            break;
                          case "quiz":
                            Navigator.of(context).pushReplacementNamed(
                              QuizLessonScreen.routeName,
                              arguments: QuizLessonScreenArgs(
                                  widget.courseId,
                                  int.tryParse(state.assignmentResponse.prev_lesson)!,
                                  widget.authorAva,
                                  widget.authorName),
                            );
                            break;
                          case "assignment":
                            Navigator.of(context).pushReplacementNamed(
                              AssignmentScreen.routeName,
                              arguments: AssignmentScreenArgs(
                                  widget.courseId,
                                  int.tryParse(state.assignmentResponse.prev_lesson)!,
                                  widget.authorAva,
                                  widget.authorName),
                            );
                            break;
                          case "stream":
                            Navigator.of(context).pushReplacementNamed(
                              LessonStreamScreen.routeName,
                              arguments: LessonStreamScreenArgs(
                                  widget.courseId,
                                  int.tryParse(state.assignmentResponse.prev_lesson)!,
                                  widget.authorAva,
                                  widget.authorName),
                            );
                            break;
                          default:
                            Navigator.of(context).pushReplacementNamed(
                              TextLessonScreen.routeName,
                              arguments: TextLessonScreenArgs(
                                  widget.courseId,
                                  int.tryParse(state.assignmentResponse.prev_lesson)!,
                                  widget.authorAva,
                                  widget.authorName,
                                  false,
                                  true),
                            );
                        }
                      },
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),
                    )
                  : Center(),
            ),
            MaterialButton(
              height: 50,
              color: AppColor.mainColor,
              onPressed: () {
                if (demo) {
                  showDialogError(context, 'Demo Mode');
                } else {
                  _bloc.add(StartAssignmentEvent(widget.courseId, widget.assignmentId));
                }
              },
              // ignore: unnecessary_type_check
              child: setUpButtonChild((state is LoadedAssignmentState) ? state.assignmentResponse.button : "",
                  state is LoadedAssignmentState),
            ),
            SizedBox(
              width: 35,
              height: 35,
              child: (state.assignmentResponse.next_lesson != "")
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            side: BorderSide(color: HexColor.fromHex("#306ECE"))),
                        padding: EdgeInsets.all(0.0),
                        backgroundColor: AppColor.mainColor,
                      ),
                      onPressed: () {
                        switch (state.assignmentResponse.next_lesson_type) {
                          case "video":
                            Navigator.of(context).pushReplacementNamed(
                              LessonVideoScreen.routeName,
                              arguments: LessonVideoScreenArgs(
                                  widget.courseId,
                                  int.tryParse(state.assignmentResponse.next_lesson)!,
                                  widget.authorAva,
                                  widget.authorName,
                                  false,
                                  true),
                            );
                            break;
                          case "quiz":
                            Navigator.of(context).pushReplacementNamed(
                              QuizLessonScreen.routeName,
                              arguments: QuizLessonScreenArgs(
                                  widget.courseId,
                                  int.tryParse(state.assignmentResponse.next_lesson)!,
                                  widget.authorAva,
                                  widget.authorName),
                            );
                            break;
                          case "assignment":
                            Navigator.of(context).pushReplacementNamed(
                              AssignmentScreen.routeName,
                              arguments: AssignmentScreenArgs(
                                  widget.courseId,
                                  int.tryParse(state.assignmentResponse.next_lesson)!,
                                  widget.authorAva,
                                  widget.authorName),
                            );
                            break;
                          case "stream":
                            Navigator.of(context).pushReplacementNamed(
                              LessonStreamScreen.routeName,
                              arguments: LessonStreamScreenArgs(
                                  widget.courseId,
                                  int.tryParse(state.assignmentResponse.prev_lesson)!,
                                  widget.authorAva,
                                  widget.authorName),
                            );
                            break;
                          default:
                            Navigator.of(context).pushReplacementNamed(
                              TextLessonScreen.routeName,
                              arguments: TextLessonScreenArgs(
                                  widget.courseId,
                                  int.tryParse(state.assignmentResponse.next_lesson)!,
                                  widget.authorAva,
                                  widget.authorName,
                                  false,
                                  true),
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

  _bottomStatusDraft(LoadedAssignmentState state) {
    return Container(
      decoration: BoxDecoration(color: HexColor.fromHex("#FFFFFF"), boxShadow: [
        BoxShadow(
            color: HexColor.fromHex("#000000").withOpacity(.1), offset: Offset(0, 0), blurRadius: 6, spreadRadius: 2)
      ]),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 35,
              height: 35,
            ),
            Expanded(
              flex: 6,
              child: MaterialButton(
                  height: 50,
                  color: AppColor.mainColor,
                  onPressed: () {
                    setState(() {
                      assignmentAdd = true;
                    });
                    assignmentDraftWidgetState.currentState?.addAssignment(true);
                  },
                  child: (!assignmentAdd)
                      ? Text(
                          localizations!.getLocalization("assignment_send_button"),
                          textScaleFactor: 1.0,
                        )
                      : CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )),
            ),
            SizedBox(
              width: 35,
              height: 35,
            )
          ],
        ),
      ),
    );
  }

  Widget? setUpButtonChild(String buttonText, bool enable) {
    if (enable == true) {
      return new Text(
        buttonText.toUpperCase(),
        textScaleFactor: 1.0,
      );
    } else {
      _loading();
    }

    return null;
  }

  _loading() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }
}

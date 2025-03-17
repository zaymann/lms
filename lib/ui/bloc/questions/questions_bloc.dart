import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/QuestionsResponse.dart';
import 'package:masterstudy_app/data/repository/questions_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './bloc.dart';

@provide
class QuestionsBloc extends Bloc<QuestionsEvent, QuestionsState> {
  final QuestionsRepository _questionsRepository;

  QuestionsBloc(this._questionsRepository) : super(InitialQuestionsState()) {
    on<FetchEvent>((event, emit) async {
      try {
        //Get userID
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var currentUserId = prefs.getString("apiToken")!.split('|');

        QuestionsResponse questions = await _questionsRepository.getQuestions(event.lessonId, event.page, event.search, "");
        QuestionsResponse questionsMy = await _questionsRepository.getQuestions(event.lessonId, event.page, event.search, currentUserId[0]);

        emit(LoadedQuestionsState(questions, questionsMy));
      } on DioError catch (error) {
        print(error);
      }
    });

    on<MyQuestionAddEvent>((event, emit) async {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var currentUserId = prefs.getString("apiToken")!.split('|');

        QuestionsResponse questionsMy = await _questionsRepository.getQuestions(event.lessonId, 1, "", currentUserId[0]);

        emit(TimerStartState());
        emit(LoadedQuestionsState(event.questionsResponse, questionsMy));
      } on DioError catch (e) {
        log(e.toString());
      }
    });
  }
}

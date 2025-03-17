import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:masterstudy_app/data/models/app_settings/app_settings.dart';
import 'package:masterstudy_app/data/models/course/CourcesResponse.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/screens/category_detail/category_detail_screen.dart';
import 'package:masterstudy_app/ui/screens/course/course_screen.dart';

class CourseGridItem extends StatelessWidget {
  final CoursesBean? coursesBean;
  final OptionsBean? optionsBean;

  CourseGridItem(this.coursesBean, {this.optionsBean});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          CourseScreen.routeName,
          arguments: CourseScreenArgs.fromCourseBean(coursesBean!, optionsBean: optionsBean),
        );
      },
      child: _buildCard(context),
    );
  }

  _buildCard(context) {
    double? rating = 0.0;
    num? reviews = 0;
    rating = coursesBean?.rating?.average?.toDouble();
    reviews = coursesBean?.rating?.total;

    var unescape = new HtmlUnescape();
    double imgHeight = (MediaQuery.of(context).size.width > 450) ? 220.0 : 75.0;
    // ignore: unnecessary_null_comparison
    String? categoryName = (coursesBean?.categories_object != null) ? coursesBean?.categories_object.first?.name : "";
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Hero(
                  tag: coursesBean?.id,
                  child: Image.network(
                    coursesBean?.images?.small ?? "",
                    width: double.infinity,
                    height: imgHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          CategoryDetailScreen.routeName,
                          arguments: CategoryDetailScreenArgs(
                            coursesBean?.categories_object.first,
                            optionsBean: optionsBean,
                          ),
                        );
                      },
                      child: Text(
                        unescape.convert(categoryName!),
                        textScaleFactor: 1.0,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium
                            ?.copyWith(color: Colors.black.withOpacity(0.5)),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Text(unescape.convert(coursesBean?.title ?? '') + '\n',
                      maxLines: 2,
                      textScaleFactor: 1,
                      style: Theme.of(context).primaryTextTheme.titleMedium?.copyWith(
                            color: Colors.black,
                          )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Row(
                    children: <Widget>[
                      RatingBar.builder(
                        initialRating: rating!,
                        minRating: 0,
                        direction: Axis.horizontal,
                        tapOnlyMode: true,
                        glow: false,
                        allowHalfRating: true,
                        ignoreGestures: true,
                        itemCount: 5,
                        itemSize: 14,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                      Text(
                        "$rating ($reviews)",
                        textScaleFactor: 1.0,
                        style: Theme.of(context).primaryTextTheme.bodySmall?.copyWith(color: Colors.black),
                      )
                    ],
                  ),
                ),
                _buildPrice(context)
              ],
            ),
          )),
    );
  }

  _buildPrice(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 0.0, right: 16.0),
      child: Row(
        children: <Widget>[
          Text(
            coursesBean?.price?.free ? localizations!.getLocalization("course_free_price") : coursesBean?.price?.price,
            textScaleFactor: 1.0,
            style: Theme.of(context)
                .primaryTextTheme
                .titleMedium!
                .copyWith(color: dark, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              (coursesBean?.price?.old_price != null) ? coursesBean?.price?.old_price : " ",
              textScaleFactor: 1.0,
              style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                  color: HexColor.fromHex("#999999"),
                  fontStyle: FontStyle.normal,
                  decoration:
                      (coursesBean?.price?.old_price != null) ? TextDecoration.lineThrough : TextDecoration.none),
            ),
          )
        ],
      ),
    );
  }
}

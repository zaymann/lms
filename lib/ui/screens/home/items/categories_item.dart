import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:masterstudy_app/data/models/category.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/screens/category_detail/category_detail_screen.dart';

import '../../../../data/models/app_settings/app_settings.dart';
import '../../../../main.dart';

class CategoriesWidget extends StatelessWidget {
  final List<Category?> categories;
  final String? title;
  final OptionsBean? optionsBean;

  CategoriesWidget(this.title, this.categories, this.optionsBean, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (categories.length != 0)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 30.0),
                child: Text(
                  localizations!.getLocalization("categories"),
                  textScaleFactor: 1.0,
                  style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(color: dark, fontStyle: FontStyle.normal),
                ),
              ),
              _buildList(context)
            ],
          )
        : Center();
  }

  _buildList(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ConstrainedBox(
        constraints: new BoxConstraints(minHeight: 120, maxHeight: 160),
        child: new ListView.builder(
          itemCount: categories.length,
          padding: const EdgeInsets.all(8.0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var item = categories[index];
            var padding = (index == 0) ? 20.0 : 0.0;
            var color = (item?.color != null) ? HexColor.fromHex(item?.color) : dark;

            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  CategoryDetailScreen.routeName,
                  arguments: CategoryDetailScreenArgs(item, optionsBean: optionsBean),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(left: padding),
                child: _buildRow(item?.image, color, item?.name),
              ),
            );
          },
        ),
      ),
    );
  }

  _buildRow(String? imgUrl, color, title) {
    var unescape = new HtmlUnescape();

    var imgFormat = (imgUrl != "" || imgUrl != null) ? imgUrl?.split(".") : null;

    return Card(
      color: color,
      child: new Container(
        width: 140,
        height: 140,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              (imgFormat != null)
                  ? SizedBox(
                      width: 50,
                      height: 50,
                      child: (imgFormat.last == 'svg')
                          ? SvgPicture.asset(imgUrl!, color: HexColor.fromHex("#FFFFFF"))
                          : Image.network(
                              imgUrl!,
                              width: double.infinity,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                    )
                  : SizedBox(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
                child: Text(
                  unescape.convert(title),
                  textScaleFactor: 1.0,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

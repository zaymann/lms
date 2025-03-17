import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:masterstudy_app/data/core/constants/assets_path.dart';
import 'package:masterstudy_app/data/models/app_settings/app_settings.dart';
import 'package:masterstudy_app/data/models/account.dart';
import 'package:masterstudy_app/data/models/category.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/theme/app_color.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/detail_profile/bloc.dart';
import 'package:masterstudy_app/ui/screens/category_detail/category_detail_screen.dart';
import 'package:masterstudy_app/ui/screens/course/course_screen.dart';
import 'package:masterstudy_app/ui/screens/profile_edit/profile_edit_screen.dart';
import 'package:masterstudy_app/ui/screens/search_detail/search_detail_screen.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailProfileScreenArgs {
  Account? account;
  int? teacherId;
  OptionsBean? optionsBean;

  DetailProfileScreenArgs(this.account, this.optionsBean);

  DetailProfileScreenArgs.fromId(this.teacherId, {this.optionsBean});
}

class DetailProfileScreen extends StatelessWidget {
  static const routeName = "detailProfileScreen";
  final DetailProfileBloc _bloc;

  const DetailProfileScreen(this._bloc) : super();

  @override
  Widget build(BuildContext context) {
    final DetailProfileScreenArgs args = ModalRoute.of(context)?.settings.arguments as DetailProfileScreenArgs;
    if (args.teacherId != null) {
      _bloc.setTeacherId(args.teacherId!);
    } else {
      _bloc.setAccount(args.account!);
    }
    return BlocProvider<DetailProfileBloc>(
      create: (context) => _bloc,
      child: DetailProfileWidget(
        optionsBean: args.optionsBean,
      ),
    );
  }
}

class DetailProfileWidget extends StatefulWidget {
  final OptionsBean? optionsBean;

  const DetailProfileWidget({Key? key, this.optionsBean}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailProfileWidgetState();
}

class _DetailProfileWidgetState extends State<DetailProfileWidget> {
  late DetailProfileBloc _bloc;
  late ScrollController _scrollController;
  String title = "";
  num kef = 2;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (!_isAppBarExpanded) {
          setState(() {
            title = "";
          });
        } else {
          if (_bloc.account != null) {
            setState(() {
              title = "${_bloc.account!.meta!.first_name} ${_bloc.account!.meta!.last_name}";
            });
          }
        }
      });
    _bloc = BlocProvider.of<DetailProfileBloc>(context)..add(LoadDetailProfile());
  }

  bool get _isAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset > (MediaQuery.of(context).size.height / kef - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    kef = (MediaQuery.of(context).size.height > 690) ? kef : 1.8;

    return BlocBuilder<DetailProfileBloc, DetailProfileState>(
      builder: (context, state) {
        var isTeacher = false;
        var tabsCount = 0;

        if (state is LoadedDetailProfileState) {
          isTeacher = state.isTeacher;
          if (isTeacher) tabsCount = 2;
        }

        return DefaultTabController(
          length: tabsCount,
          child: Scaffold(
            body: (state is LoadedDetailProfileState)
                ? NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      Widget buildAvatar = ClipRRect(
                        borderRadius: BorderRadius.circular(60.0),
                        child: CachedNetworkImage(
                          imageUrl: _bloc.account!.avatar_url!,
                          fit: BoxFit.fill,
                          width: 100.0,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) {
                            return SizedBox(
                              width: 100.0,
                              child: Image.asset(ImageRasterPath.logo),
                            );
                          },
                        ),
                      );

                      var name = (_bloc.account!.meta?.first_name != '' && _bloc.account!.meta?.last_name != '')
                          ? "${_bloc.account!.meta?.first_name} ${_bloc.account!.meta?.last_name}"
                          : _bloc.account!.login;

                      return <Widget>[
                        SliverAppBar(
                          backgroundColor: AppColor.mainColor,
                          title: Text(
                            title,
                            textScaleFactor: 1.0,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          expandedHeight: MediaQuery.of(context).size.height / kef,
                          floating: false,
                          pinned: true,
                          snap: false,
                          actions: <Widget>[
                            Visibility(
                              visible: isTeacher,
                              child: IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () {},
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(SearchDetailScreen.routeName, arguments: SearchDetailScreenArgs("")),
                            ),
                          ],
                          bottom: (isTeacher)
                              ? ColoredTabBar(
                                  Colors.white,
                                  TabBar(
                                    indicatorColor: AppColor.mainColor,
                                    tabs: _getTabs(state),
                                  ),
                                )
                              : null,
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            centerTitle: true,
                            background: SafeArea(
                              child: Container(
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 30.0),
                                        child: buildAvatar,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          name ?? '',
                                          textScaleFactor: 1.0,
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                      Visibility(
                                        visible: isTeacher,
                                        child: Text(
                                          isTeacher ? _bloc.account!.meta!.position! : "",
                                          textScaleFactor: 1.0,
                                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                                        ),
                                      ),
                                      Visibility(
                                        visible: isTeacher,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 6.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              RatingBar.builder(
                                                initialRating: _bloc.account!.rating!.average!.toDouble(),
                                                minRating: 0,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 16,
                                                itemBuilder: (context, _) => Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                glow: false,
                                                onRatingUpdate: (double value) {},
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: Text(
                                                  "${_bloc.account!.rating?.average!.toDouble()} ${_bloc.account!.rating?.total_marks != '' ? '(${_bloc.account!.rating!.total_marks})' : ''}",
                                                  textScaleFactor: 1.0,
                                                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 25.0, bottom: 50),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width / 3,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              if (_bloc.account!.meta?.facebook != "")
                                                Padding(
                                                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      try {
                                                        if (await canLaunch(_bloc.account!.meta!.facebook!)) {
                                                          await launch(_bloc.account!.meta!.facebook!);
                                                        } else {
                                                          launch("https://www.facebook.com/");
                                                        }
                                                      } catch (e) {
                                                        await launch("https://www.facebook.com/");
                                                      }
                                                    },
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: SvgPicture.asset(
                                                        ImageVectorPath.facebook,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              if (_bloc.account!.meta!.twitter != "")
                                                Padding(
                                                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      try {
                                                        if (await canLaunch(_bloc.account!.meta!.twitter)) {
                                                          await launch(_bloc.account!.meta!.twitter);
                                                        } else {
                                                          launch("https://www.twitter.com/");
                                                        }
                                                      } catch (e) {
                                                        await launch("https://twitter.com/");
                                                      }
                                                    },
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: SvgPicture.asset(
                                                        ImageVectorPath.twitter,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              if (_bloc.account!.meta!.instagram != "")
                                                Padding(
                                                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      try {
                                                        if (await canLaunch(_bloc.account!.meta!.instagram)) {
                                                          await launch(_bloc.account!.meta!.instagram);
                                                        } else {
                                                          launch("https://www.instagram.com/");
                                                        }
                                                      } catch (e) {
                                                        await launch("https://www.instagram.com/");
                                                      }
                                                    },
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: SvgPicture.asset(
                                                        ImageVectorPath.instagram,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: getBody(state))
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        );
      },
    );
  }

  Widget getBody(state) {
    if (state is LoadedDetailProfileState) {
      if (state.isTeacher) {
        return TabBarView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                _bloc.account!.meta!.description,
                textScaleFactor: 1.0,
              ),
            ),
            ListView.builder(
              itemCount: state.courses!.length,
              itemBuilder: (BuildContext context, int index) {
                var item = state.courses![index];

                double? rating = 0.0;
                int? reviews = 0;
                if (item?.rating?.total != null) {
                  rating = item!.rating!.average!.toDouble();
                }
                if (item!.rating!.total != null) {
                  reviews = item.rating?.total as int?;
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      CourseScreen.routeName,
                      arguments: CourseScreenArgs.fromCourseBean(item, optionsBean: widget.optionsBean),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                    child: _buildCard(
                      context,
                      item.images?.full,
                      item.categories_object.first,
                      "${item.title}",
                      rating,
                      reviews,
                      item.price?.price,
                      item.price?.old_price,
                      item.price?.free,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      } else {
        if (_bloc.account!.meta?.description != null && _bloc.account!.meta!.description.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              _bloc.account!.meta!.description,
              textScaleFactor: 1.0,
            ),
          );
        } else {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  localizations!.getLocalization("empty_profile_text"),
                  textScaleFactor: 1.0,
                  style: TextStyle(color: HexColor.fromHex("#D7DAE2"), fontSize: 18),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: MaterialButton(
                    height: 40,
                    color: AppColor.mainColor,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        ProfileEditScreen.routeName,
                        arguments: ProfileEditScreenArgs(_bloc.account),
                      );
                    },
                    child: Text(
                      localizations!.getLocalization("empty_profile_button"),
                    ),
                  ),
                )
              ],
            ),
          );
        }
      }
    } else
      return Center(
        child: CircularProgressIndicator(),
      );
  }

  List<Widget> _getTabs(state) {
    List<Widget> tabs = [];

    if (state is LoadedDetailProfileState) {
      if (state.isTeacher) {
        tabs.addAll([
          Tab(
            text: localizations!.getLocalization("profile_bio_tab"),
          ),
          Tab(text: localizations!.getLocalization("profile_courses_tab")),
        ]);
      }
    }

    return tabs;
  }

  _buildCard(context, image, Category? category, title, stars, reviews, price, oldPrice, free) {
    var unescape = new HtmlUnescape();

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        child: Card(
          borderOnForeground: true,
          elevation: 3,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FadeInImage.memoryNetwork(
                  image: image,
                  placeholder: kTransparentImage,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        CategoryDetailScreen.routeName,
                        arguments: CategoryDetailScreenArgs(category, optionsBean: widget.optionsBean),
                      );
                    },
                    child: Text(
                      "${unescape.convert(category?.name ?? '')} >",
                      textScaleFactor: 1.0,
                      style: TextStyle(fontSize: 18, color: HexColor.fromHex("#2a3045").withOpacity(0.5)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, left: 16.0, right: 16.0),
                  child: Text(
                    title,
                    textScaleFactor: 1.0,
                    maxLines: 2,
                    style: TextStyle(fontSize: 22, color: dark),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: Divider(
                    color: HexColor.fromHex("#e0e0e0"),
                    thickness: 1.3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 15.0, right: 16.0),
                  child: Row(
                    children: <Widget>[
                      RatingBar.builder(
                        initialRating: stars,
                        minRating: 0,
                        direction: Axis.horizontal,
                        tapOnlyMode: true,
                        allowHalfRating: true,
                        glow: false,
                        ignoreGestures: true,
                        itemCount: 5,
                        itemSize: 19,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "$stars ($reviews)",
                          textScaleFactor: 1.0,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPrice(context, price, oldPrice, free),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildPrice(context, price, oldPrice, free) {
    if (free) return Center();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          Text(
            price,
            textScaleFactor: 1.0,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall
                ?.copyWith(color: dark, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
          ),
          Visibility(
            visible: oldPrice != null,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                oldPrice.toString(),
                textScaleFactor: 1.0,
                style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                    color: HexColor.fromHex("#999999"),
                    fontStyle: FontStyle.normal,
                    decoration: TextDecoration.lineThrough),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar(this.color, this.tabBar);

  final color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        color: color,
        child: tabBar,
      );
}

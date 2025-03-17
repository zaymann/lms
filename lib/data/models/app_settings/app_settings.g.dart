// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return AppSettings(
    addons: json['addons'] == null ? null : AddonsBean.fromJson(json['addons'] as Map<String, dynamic>),
    home_layout: (json['home_layout'] as List)
        .map((e) => e == null ? null : HomeLayoutBean.fromJson(e as Map<String, dynamic>))
        .toList(),
    options: json['options'] == null ? null : OptionsBean.fromJson(json['options'] as Map<String, dynamic>),
    demo: json['demo'] as bool?,
  );
}

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) => <String, dynamic>{
      'addons': instance.addons,
      'home_layout': instance.home_layout,
      'options': instance.options,
      'demo': instance.demo,
    };

HomeLayoutBean _$HomeLayoutBeanFromJson(Map<String, dynamic> json) {
  return HomeLayoutBean(
    id: json['id'] as num,
    name: json['name'] as String,
    enabled: json['enabled'] as bool,
  );
}

Map<String, dynamic> _$HomeLayoutBeanToJson(HomeLayoutBean instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'enabled': instance.enabled,
    };

AddonsBean _$AddonsBeanFromJson(Map<String, dynamic> json) {
  return AddonsBean(
    shareware: json['shareware'] as String?,
    sequential_drip_content: json['sequential_drip_content'] as String?,
    gradebook: json['gradebook'] as String?,
    live_streams: json['live_streams'] as String?,
    enterprise_courses: json['enterprise_courses'] as String?,
    assignments: json['assignments'] as String?,
    point_system: json['point_system'] as String?,
    statistics: json['statistics'] as String?,
    online_testing: json['online_testing'] as String?,
    course_bundle: json['course_bundle'] as String?,
    multi_instructors: json['multi_instructors'] as String?,
  );
}

Map<String, dynamic> _$AddonsBeanToJson(AddonsBean instance) => <String, dynamic>{
      'shareware': instance.shareware,
      'sequential_drip_content': instance.sequential_drip_content,
      'gradebook': instance.gradebook,
      'live_streams': instance.live_streams,
      'enterprise_courses': instance.enterprise_courses,
      'assignments': instance.assignments,
      'point_system': instance.point_system,
      'statistics': instance.statistics,
      'online_testing': instance.online_testing,
      'course_bundle': instance.course_bundle,
      'multi_instructors': instance.multi_instructors,
    };

OptionsBean _$OptionsBeanFromJson(Map<String, dynamic> json) {
  return OptionsBean(
    subscriptions: json['subscriptions'] as bool?,
    google_oauth: json['google_oauth'] as bool?,
    facebook_oauth: json['facebook_oauth'] as bool?,
    logo: json['logo'] as String?,
    main_color: json['main_color'] == null ? null : ColorBean.fromJson(json['main_color'] as Map<String, dynamic>),
    main_color_hex: json['main_color_hex'] == null ? null : json['main_color_hex'],
    secondary_color:
        json['secondary_color'] == null ? null : ColorBean.fromJson(json['secondary_color'] as Map<String, dynamic>),
    app_view: json['app_view'] as bool,
    posts_count: json['posts_count'] as num,
  );
}

Map<String, dynamic> _$OptionsBeanToJson(OptionsBean instance) => <String, dynamic>{
      'subscriptions': instance.subscriptions,
      'google_oauth': instance.google_oauth,
      'facebook_oauth': instance.facebook_oauth,
      'logo': instance.logo,
      'main_color': instance.main_color,
      'main_color_hex': instance.main_color_hex,
      'secondary_color': instance.secondary_color,
      'app_view': instance.app_view,
      'posts_count': instance.posts_count,
    };

ColorBean _$ColorBeanFromJson(Map<String, dynamic> json) {
  return ColorBean(
    r: json['r'] as num,
    g: json['g'] as num,
    b: json['b'] as num,
    a: json['a'] as num,
  );
}

Map<String, dynamic> _$ColorBeanToJson(ColorBean instance) => <String, dynamic>{
      'r': instance.r,
      'g': instance.g,
      'b': instance.b,
      'a': instance.a,
    };

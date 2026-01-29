import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'LifeLog',
      'new_entry': 'New Entry',
      'time': 'Time',
      'how_are_you_feeling': 'How are you feeling?',
      'what_happened': 'What happened?',
      'please_enter_event': 'Please enter an event description',
      'no_entries_yet': 'No entries yet',
      'tap_to_add': 'Tap + to add your first log entry',
      'delete_entry': 'Delete Entry',
      'delete_entry_confirm': 'Are you sure you want to delete this entry?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'close': 'Close',
      'settings': 'Settings',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'follow_system': 'Follow System',
      'about': 'About',
      'clear_all_entries': 'Clear All Entries',
      'clear_all_confirm': 'Are you sure you want to delete all log entries? This action cannot be undone.',
      'delete_all': 'Delete All',
      'all_entries_cleared': 'All entries cleared',
      'app_description': 'A simple life logging app to track moments with time, mood, and events.',
      'built_with_flutter': 'Built with Flutter',
      'attachments': 'Attachments',
      'add_attachment': 'Add attachment',
      'choose_from_gallery': 'Choose from Gallery',
      'choose_video_from_gallery': 'Choose Video from Gallery',
      'take_photo': 'Take Photo',
      'record_video': 'Record Video',
      'failed_to_pick_image': 'Failed to pick image',
      'failed_to_pick_video': 'Failed to pick video',
      'failed_to_take_photo': 'Failed to take photo',
      'failed_to_record_video': 'Failed to record video',
      'feeling_score': 'Feeling Score',
      'feeling_score_optional': 'Feeling Score (optional)',
      'epitaph': 'Life Goals',
      'epitaph_settings': 'Life Goals Settings',
      'enable_epitaph': 'Enable Life Goals',
      'birthday': 'Birthday',
      'expected_lifespan': 'Expected Lifespan (years)',
      'epitaph_content': 'Life Goals',
      'save': 'Save',
      'please_enter_birthday': 'Please enter your birthday',
      'please_enter_lifespan': 'Please enter expected lifespan',
      'please_enter_epitaph': 'Please enter your life goals',
      'statistics': 'Statistics',
      'feeling_curve': 'Feeling Curve',
      'no_feeling_data': 'No feeling score data available',
      'average_feeling': 'Average',
      'view_statistics': 'View Statistics',
      'recent_entries': 'Recent Entries',
      'invalid_lifespan': 'Please enter a valid lifespan (1-150)',
    },
    'zh': {
      'app_title': '人生日志',
      'new_entry': '新建记录',
      'time': '时间',
      'how_are_you_feeling': '你的心情如何？',
      'what_happened': '发生了什么？',
      'please_enter_event': '请输入事件描述',
      'no_entries_yet': '暂无记录',
      'tap_to_add': '点击 + 添加您的第一条日志',
      'delete_entry': '删除记录',
      'delete_entry_confirm': '确定要删除此记录吗？',
      'cancel': '取消',
      'delete': '删除',
      'close': '关闭',
      'settings': '设置',
      'theme': '主题',
      'light': '浅色',
      'dark': '深色',
      'follow_system': '跟随系统',
      'about': '关于',
      'clear_all_entries': '清空所有记录',
      'clear_all_confirm': '确定要删除所有日志记录吗？此操作无法撤销。',
      'delete_all': '全部删除',
      'all_entries_cleared': '所有记录已清空',
      'app_description': '一个简单的人生日志应用，用于记录时间、心情和事件。',
      'built_with_flutter': '使用 Flutter 构建',
      'attachments': '附件',
      'add_attachment': '添加附件',
      'choose_from_gallery': '从相册选择',
      'choose_video_from_gallery': '从相册选择视频',
      'take_photo': '拍照',
      'record_video': '录像',
      'failed_to_pick_image': '选择图片失败',
      'failed_to_pick_video': '选择视频失败',
      'failed_to_take_photo': '拍照失败',
      'failed_to_record_video': '录像失败',
      'feeling_score': '感受得分',
      'feeling_score_optional': '感受得分（可选）',
      'epitaph': '人生目标',
      'epitaph_settings': '人生目标设置',
      'enable_epitaph': '启用人生目标',
      'birthday': '生日',
      'expected_lifespan': '预期寿命（年）',
      'epitaph_content': '人生目标',
      'save': '保存',
      'please_enter_birthday': '请输入您的生日',
      'please_enter_lifespan': '请输入预期寿命',
      'please_enter_epitaph': '请输入您的人生目标',
      'statistics': '统计',
      'feeling_curve': '感受曲线',
      'no_feeling_data': '暂无感受得分数据',
      'average_feeling': '平均值',
      'view_statistics': '查看统计',
      'recent_entries': '最近记录',
      'invalid_lifespan': '请输入有效的寿命（1-150）',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for commonly used strings
  String get appTitle => translate('app_title');
  String get newEntry => translate('new_entry');
  String get time => translate('time');
  String get howAreYouFeeling => translate('how_are_you_feeling');
  String get whatHappened => translate('what_happened');
  String get pleaseEnterEvent => translate('please_enter_event');
  String get noEntriesYet => translate('no_entries_yet');
  String get tapToAdd => translate('tap_to_add');
  String get deleteEntry => translate('delete_entry');
  String get deleteEntryConfirm => translate('delete_entry_confirm');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get close => translate('close');
  String get settings => translate('settings');
  String get theme => translate('theme');
  String get light => translate('light');
  String get dark => translate('dark');
  String get followSystem => translate('follow_system');
  String get about => translate('about');
  String get clearAllEntries => translate('clear_all_entries');
  String get clearAllConfirm => translate('clear_all_confirm');
  String get deleteAll => translate('delete_all');
  String get allEntriesCleared => translate('all_entries_cleared');
  String get appDescription => translate('app_description');
  String get builtWithFlutter => translate('built_with_flutter');
  String get attachments => translate('attachments');
  String get addAttachment => translate('add_attachment');
  String get chooseFromGallery => translate('choose_from_gallery');
  String get chooseVideoFromGallery => translate('choose_video_from_gallery');
  String get takePhoto => translate('take_photo');
  String get recordVideo => translate('record_video');
  String get failedToPickImage => translate('failed_to_pick_image');
  String get failedToPickVideo => translate('failed_to_pick_video');
  String get failedToTakePhoto => translate('failed_to_take_photo');
  String get failedToRecordVideo => translate('failed_to_record_video');
  String get feelingScore => translate('feeling_score');
  String get feelingScoreOptional => translate('feeling_score_optional');
  String get epitaph => translate('epitaph');
  String get epitaphSettings => translate('epitaph_settings');
  String get enableEpitaph => translate('enable_epitaph');
  String get birthday => translate('birthday');
  String get expectedLifespan => translate('expected_lifespan');
  String get epitaphContent => translate('epitaph_content');
  String get save => translate('save');
  String get pleaseEnterBirthday => translate('please_enter_birthday');
  String get pleaseEnterLifespan => translate('please_enter_lifespan');
  String get pleaseEnterEpitaph => translate('please_enter_epitaph');
  String get statistics => translate('statistics');
  String get feelingCurve => translate('feeling_curve');
  String get noFeelingData => translate('no_feeling_data');
  String get averageFeeling => translate('average_feeling');
  String get viewStatistics => translate('view_statistics');
  String get recentEntries => translate('recent_entries');
  String get invalidLifespan => translate('invalid_lifespan');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

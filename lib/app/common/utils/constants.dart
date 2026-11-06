class AppConstants {
  static const String appName = 'ArtTrace';
  static const String appTagline = 'AR Drawing & Sketching Master';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyIsPremium = 'is_premium';
  static const String keyFavorites = 'user_favorites';
  static const String keyRecentDrawings = 'user_recent_drawings';
  static const String keySavedArtworks = 'user_saved_artworks';
  static const String keyThemeMode = 'app_theme_mode'; // 'system', 'light', 'dark'
  static const String keyHapticFeedback = 'haptic_feedback_enabled';
  static const String keyDefaultOpacity = 'default_tracing_opacity';
  static const String keyShowStandGuide = 'show_phone_stand_guide';

  // AdMob Test Unit IDs (Official Google Test Ad Unit IDs)
  static const String bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';

  // In-App Purchase Product IDs (Play Store billing)
  static const String productIdProWeekly = 'arttrace_pro_weekly';
  static const String productIdProMonthly = 'arttrace_pro_monthly';
  static const String productIdProLifetime = 'arttrace_pro_lifetime';
  static const String productIdRemoveAds = 'arttrace_remove_ads';

  static const List<String> kAllProductIds = [
    productIdProWeekly,
    productIdProMonthly,
    productIdProLifetime,
    productIdRemoveAds,
  ];

  // Links
  static const String privacyPolicyUrl = 'https://arttrace.app/privacy';
  static const String termsOfServiceUrl = 'https://arttrace.app/terms';
  static const String supportEmail = 'support@arttrace.app';
}


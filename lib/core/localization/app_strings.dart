/// The two languages this app supports.
enum AppLocale { en, ne }

/// A simple, self-contained translation system — not Flutter's official
/// intl/.arb pipeline (which needs code generation and doesn't have
/// built-in Nepali locale data), just a lookup table you can extend by
/// adding more keys as more screens get translated.
///
/// Usage: AppStrings.of('nav_home', locale)
class AppStrings {
  AppStrings._();

  static const Map<String, Map<AppLocale, String>> _strings = {
    // ── Bottom nav / app bar ──────────────────────────
    'app_name': {AppLocale.en: 'KitabGhar', AppLocale.ne: 'किताबघर'},
    'nav_home': {AppLocale.en: 'Home', AppLocale.ne: 'गृह'},
    'nav_explore': {AppLocale.en: 'Explore', AppLocale.ne: 'अन्वेषण'},
    'nav_purchases': {AppLocale.en: 'Purchases', AppLocale.ne: 'खरिदहरू'},
    'nav_favourite': {AppLocale.en: 'Favourite', AppLocale.ne: 'मनपर्ने'},
    'nav_profile': {AppLocale.en: 'Profile', AppLocale.ne: 'प्रोफाइल'},

    // ── Profile page ──────────────────────────────────
    'profile_title': {AppLocale.en: 'Profile', AppLocale.ne: 'प्रोफाइल'},
    'my_listings': {AppLocale.en: 'My Listings', AppLocale.ne: 'मेरा सूचीहरू'},
    'no_listings': {
      AppLocale.en: 'No listings yet. Sell your first book!',
      AppLocale.ne: 'अहिलेसम्म कुनै सूची छैन। आफ्नो पहिलो किताब बेच्नुहोस्!',
    },
    'account': {AppLocale.en: 'Account', AppLocale.ne: 'खाता'},
    'manage_profile': {
      AppLocale.en: 'Manage Profile',
      AppLocale.ne: 'प्रोफाइल व्यवस्थापन गर्नुहोस्',
    },
    'security_privacy': {
      AppLocale.en: 'Security & Privacy',
      AppLocale.ne: 'सुरक्षा र गोपनीयता',
    },
    'preferences': {AppLocale.en: 'Preferences', AppLocale.ne: 'प्राथमिकताहरू'},
    'notifications': {AppLocale.en: 'Notifications', AppLocale.ne: 'सूचनाहरू'},
    'dark_mode': {AppLocale.en: 'Dark Mode', AppLocale.ne: 'डार्क मोड'},
    'language': {AppLocale.en: 'Language', AppLocale.ne: 'भाषा'},
    'support': {AppLocale.en: 'Support', AppLocale.ne: 'सहायता'},
    'help_center': {AppLocale.en: 'Help Center', AppLocale.ne: 'सहायता केन्द्र'},
    'terms_policies': {
      AppLocale.en: 'Terms & Policies',
      AppLocale.ne: 'सर्तहरू र नीतिहरू',
    },
    'about_us': {AppLocale.en: 'About Us', AppLocale.ne: 'हाम्रो बारेमा'},
    'log_out': {AppLocale.en: 'Log Out', AppLocale.ne: 'लग आउट'},
    'log_out_confirm_message': {
      AppLocale.en: 'Are you sure you want to log out?',
      AppLocale.ne: 'के तपाईं लग आउट गर्न निश्चित हुनुहुन्छ?',
    },
    'cancel': {AppLocale.en: 'Cancel', AppLocale.ne: 'रद्द गर्नुहोस्'},

    // ── Language picker ───────────────────────────────
    'select_language': {
      AppLocale.en: 'Select Language',
      AppLocale.ne: 'भाषा चयन गर्नुहोस्',
    },
    'english': {AppLocale.en: 'English', AppLocale.ne: 'अंग्रेजी'},
    'nepali': {AppLocale.en: 'Nepali', AppLocale.ne: 'नेपाली'},
  };

  static String of(String key, AppLocale locale) {
    return _strings[key]?[locale] ?? key;
  }
}
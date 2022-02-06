import 'package:flutter/material.dart';

/// APP SETINGS INFO CONSTANTS - SECTION ///
///
const String APP_NAME = "Dosti Pak";
const Color APP_PRIMARY_COLOR = Colors.indigo;
const Color APP_ACCENT_COLOR = Colors.indigoAccent;
const String APP_VERSION_NAME = "v2.0.0";
const int ANDROID_APP_VERSION_NUMBER = 2; // Google Play Version Number
const int IOS_APP_VERSION_NUMBER = 2; // App Store Version Number
// 
// Add Google Maps - API KEY required for Passport feature
// 
const String ANDROID_MAPS_API_KEY = "YOUR ANDROID API KEY";
const String IOS_MAPS_API_KEY = "YOUR IOS API KEY";
//
// GOOGLE ADMOB INTERSTITIAL IDS
//
// For Android Platform
const String ANDROID_INTERSTITIAL_ID = "....................";
// For IOS Platform
const String IOS_INTERSTITIAL_ID = "YOUR iOS AD ID";

/// List of Supported Locales
/// Add your new supported Locale to the array list.
///
/// E.g: Locale('fr'), Locale('es'),
///
const List<Locale> SUPPORTED_LOCALES = [
  Locale('en'),
];
///
/// END APP SETINGS - SECTION


/// 
/// DATABASE COLLECTIONS FIELD - SECTION
/// 
/// FIREBASE MESSAGING TOPIC
const NOTIFY_USERS = "NOTIFY_USERS";

/// DATABASE COLLECTION NAMES USED IN APP
///
const String C_APP_INFO = "AppInfo";
const String C_USERS = "Users";
const String C_FLAGGED_USERS = "FlaggedUsers";
const String C_CONNECTIONS = "Connections";
const String C_MATCHES = "Matches";
const String C_CONVERSATIONS = "Conversations";
const String C_LIKES = "Likes";
const String C_VISITS = "Visits";
const String C_DISLIKES = "Dislikes";
const String C_MESSAGES = "Messages";
const String C_NOTIFICATIONS = "Notifications";

/// DATABASE FIELDS FOR AppInfo COLLECTION  ///
///
const String ANDROID_APP_CURRENT_VERSION = "android_app_current_version";
const String IOS_APP_CURRENT_VERSION = "ios_app_current_version";
const String ANDROID_PACKAGE_NAME = "android_package_name";
const String IOS_APP_ID = "ios_app_id";
const String APP_EMAIL = "app_email";
const String PRIVACY_POLICY_URL = "privacy_policy_url";
const String TERMS_OF_SERVICE_URL = "terms_of_service_url";
const String FIREBASE_SERVER_KEY = "firebase_server_key";
const String STORE_SUBSCRIPTION_IDS = "store_subscription_ids";
const String FREE_ACCOUNT_MAX_DISTANCE = "free_account_max_distance";
const String VIP_ACCOUNT_MAX_DISTANCE = "vip_account_max_distance";
// Admob variables
const String ADMOB_APP_ID = "admob_app_id";
const String ADMOB_INTERSTITIAL_AD_ID = "admob_interstitial_ad_id";

/// DATABASE FIELDS FOR USER COLLECTION  ///
///

//NEW
const String USER_WALLET = "user_wallet";
const String USER_ONLINE = "user_online";
const String USER_TYPING = "user_typing";
//NEW
const String USER_ID = "user_id";
const String USER_PROFILE_PHOTO = "user_photo_link";
const String USER_FULLNAME = "user_fullname";
const String USER_GENDER = "user_gender";
const String USER_BIRTH_DAY = "user_birth_day";
const String USER_BIRTH_MONTH = "user_birth_month";
const String USER_BIRTH_YEAR = "user_birth_year";
const String USER_SCHOOL = "user_school";
const String USER_JOB_TITLE = "user_job_title";
const String USER_BIO = "user_bio";
const String USER_PHONE_NUMBER = "user_phone_number";
const String USER_EMAIL = "user_email";
const String USER_GALLERY = "user_gallery";
const String USER_COUNTRY = "user_country";
const String USER_LOCALITY = "user_locality";
const String USER_GEO_POINT = "user_geo_point";
const String USER_SETTINGS = "user_settings";
const String USER_STATUS = "user_status";
const String USER_IS_VERIFIED = "user_is_verified";
const String USER_LEVEL = "user_level";
const String USER_REG_DATE = "user_reg_date";
const String USER_LAST_LOGIN = "user_last_login";
const String USER_DEVICE_TOKEN = "user_device_token";
const String USER_TOTAL_LIKES = "user_total_likes";
const String USER_TOTAL_VISITS = "user_total_visits";
const String USER_TOTAL_DISLIKED = "user_total_disliked";
// User Setting map - fields
const String USER_MIN_AGE = "user_min_age";
const String USER_MAX_AGE = "user_max_age";
const String USER_MAX_DISTANCE = "user_max_distance";
const String USER_SHOW_ME = "user_show_me";


/// DATABASE FIELDS FOR FlaggedUsers COLLECTION  ///
///
const String FLAGGED_USER_ID = "flagged_user_id";
const String FLAG_REASON = "flag_reason";
const String FLAGGED_BY_USER_ID = "flagged_by_user_id";

/// DATABASE FIELDS FOR Messages and Conversations COLLECTION ///
///
const String MESSAGE_TEXT = "message_text";
const String MESSAGE_TYPE = "message_type";
const String MESSAGE_IMG_LINK = "message_img_link";
const String MESSAGE_AUDIO_LINK = "message_audio_link";
const String MESSAGE_GIF_LINK = "message_gif_link";
const String MESSAGE_STICKER_LINK = "message_sticker_link";
const String MESSAGE_READ = "message_read";
const String LAST_MESSAGE = "last_message";

/// DATABASE FIELDS FOR Notifications COLLECTION ///
///
const N_SENDER_ID = "n_sender_id";
const N_SENDER_FULLNAME = "n_sender_fullname";
const N_SENDER_PHOTO_LINK = "n_sender_photo_link";
const N_RECEIVER_ID = "n_receiver_id";
const N_TYPE = "n_type";
const N_MESSAGE = "n_message";
const N_READ = "n_read";

/// DATABASE FIELDS FOR Likes COLLECTION
///
const String LIKED_USER_ID = 'liked_user_id';
const String LIKED_BY_USER_ID = 'liked_by_user_id';
const String LIKE_TYPE = 'like_type';

/// DATABASE FIELDS FOR Dislikes COLLECTION
///
const String DISLIKED_USER_ID = 'disliked_user_id';
const String DISLIKED_BY_USER_ID = 'disliked_by_user_id';

/// DATABASE FIELDS FOR Visits COLLECTION
///
const String VISITED_USER_ID = 'visited_user_id';
const String VISITED_BY_USER_ID = 'visited_by_user_id';

/// DATABASE SHARED FIELDS FOR COLLECTION
///
const String TIMESTAMP = "timestamp";



///Remove Ads (NEW)
const bool REMOVE_ADS = true;
bool isFirstTime = true;


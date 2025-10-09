import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Get analytics instance
  FirebaseAnalytics get analytics => _analytics;

  // Authentication Events
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logLogout() async {
    await _analytics.logEvent(
      name: 'logout',
    );
  }

  Future<void> logPasswordReset() async {
    await _analytics.logEvent(
      name: 'password_reset',
    );
  }

  Future<void> logDeleteAccount() async {
    await _analytics.logEvent(
      name: 'delete_account',
    );
  }

  // Navigation Events
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
    );
  }

  // Transaction Events
  Future<void> logAddTransaction({
    required String type,
    required double value,
    String? category,
    String? paymentType,
    bool? isInstallment,
  }) async {
    await _analytics.logEvent(
      name: 'add_transaction',
      parameters: {
        'transaction_type': type,
        'value': value,
        if (category != null) 'category': category,
        if (paymentType != null) 'payment_type': paymentType,
        if (isInstallment != null) 'is_installment': isInstallment,
      },
    );
  }

  Future<void> logUpdateTransaction({
    required String type,
    required double value,
  }) async {
    await _analytics.logEvent(
      name: 'update_transaction',
      parameters: {
        'transaction_type': type,
        'value': value,
      },
    );
  }

  Future<void> logDeleteTransaction({
    required String type,
    required double value,
  }) async {
    await _analytics.logEvent(
      name: 'delete_transaction',
      parameters: {
        'transaction_type': type,
        'value': value,
      },
    );
  }

  // Card Events
  Future<void> logAddCard(String cardName) async {
    await _analytics.logEvent(
      name: 'add_card',
      parameters: {
        'card_name': cardName,
      },
    );
  }

  Future<void> logUpdateCard(String cardName) async {
    await _analytics.logEvent(
      name: 'update_card',
      parameters: {
        'card_name': cardName,
      },
    );
  }

  Future<void> logDeleteCard(String cardName) async {
    await _analytics.logEvent(
      name: 'delete_card',
      parameters: {
        'card_name': cardName,
      },
    );
  }

  // Goal Events
  Future<void> logAddGoal({
    required String goalName,
    required double targetValue,
  }) async {
    await _analytics.logEvent(
      name: 'add_goal',
      parameters: {
        'goal_name': goalName,
        'target_value': targetValue,
      },
    );
  }

  Future<void> logUpdateGoal(String goalName) async {
    await _analytics.logEvent(
      name: 'update_goal',
      parameters: {
        'goal_name': goalName,
      },
    );
  }

  Future<void> logDeleteGoal(String goalName) async {
    await _analytics.logEvent(
      name: 'delete_goal',
      parameters: {
        'goal_name': goalName,
      },
    );
  }

  Future<void> logGoalCompleted(String goalName) async {
    await _analytics.logEvent(
      name: 'goal_completed',
      parameters: {
        'goal_name': goalName,
      },
    );
  }

  // Fixed Accounts Events
  Future<void> logAddFixedAccount({
    required String accountName,
    required double value,
    required String frequency,
  }) async {
    await _analytics.logEvent(
      name: 'add_fixed_account',
      parameters: {
        'account_name': accountName,
        'value': value,
        'frequency': frequency,
      },
    );
  }

  Future<void> logUpdateFixedAccount(String accountName) async {
    await _analytics.logEvent(
      name: 'update_fixed_account',
      parameters: {
        'account_name': accountName,
      },
    );
  }

  Future<void> logDeleteFixedAccount(String accountName) async {
    await _analytics.logEvent(
      name: 'delete_fixed_account',
      parameters: {
        'account_name': accountName,
      },
    );
  }

  // Report Events
  Future<void> logViewReport(String reportType) async {
    await _analytics.logEvent(
      name: 'view_report',
      parameters: {
        'report_type': reportType,
      },
    );
  }

  Future<void> logExportData(String format) async {
    await _analytics.logEvent(
      name: 'export_data',
      parameters: {
        'format': format,
      },
    );
  }

  // Spending Goal Events
  Future<void> logAddSpendingGoal({
    required String category,
    required double limit,
  }) async {
    await _analytics.logEvent(
      name: 'add_spending_goal',
      parameters: {
        'category': category,
        'limit': limit,
      },
    );
  }

  Future<void> logUpdateSpendingGoal(String category) async {
    await _analytics.logEvent(
      name: 'update_spending_goal',
      parameters: {
        'category': category,
      },
    );
  }

  Future<void> logDeleteSpendingGoal(String category) async {
    await _analytics.logEvent(
      name: 'delete_spending_goal',
      parameters: {
        'category': category,
      },
    );
  }

  // User Actions
  Future<void> logCategorySelected(String category) async {
    await _analytics.logEvent(
      name: 'category_selected',
      parameters: {
        'category': category,
      },
    );
  }

  Future<void> logPaymentTypeSelected(String paymentType) async {
    await _analytics.logEvent(
      name: 'payment_type_selected',
      parameters: {
        'payment_type': paymentType,
      },
    );
  }

  Future<void> logOnboardingCompleted() async {
    await _analytics.logEvent(
      name: 'onboarding_completed',
    );
  }

  Future<void> logFilterApplied({
    required String filterType,
    String? filterValue,
  }) async {
    await _analytics.logEvent(
      name: 'filter_applied',
      parameters: {
        'filter_type': filterType,
        if (filterValue != null) 'filter_value': filterValue,
      },
    );
  }

  // Privacy Events
  Future<void> logPrivacyPolicyViewed() async {
    await _analytics.logEvent(
      name: 'privacy_policy_viewed',
    );
  }

  Future<void> logPrivacyPolicyAccepted() async {
    await _analytics.logEvent(
      name: 'privacy_policy_accepted',
    );
  }

  // Generic event logger
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}

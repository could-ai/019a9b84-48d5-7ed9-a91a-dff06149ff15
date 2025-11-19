import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  static const String _usageKey = 'free_usage_seconds';
  static const String _isPremiumKey = 'is_premium_user';
  static const int _freeLimitSeconds = 3600; // 1 Hour

  int _currentUsage = 0;
  bool _isPremium = false;
  Timer? _usageTimer;
  final StreamController<int> _remainingTimeController = StreamController<int>.broadcast();

  Stream<int> get remainingTimeStream => _remainingTimeController.stream;
  bool get isPremium => _isPremium;
  int get freeLimitSeconds => _freeLimitSeconds;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUsage = prefs.getInt(_usageKey) ?? 0;
    _isPremium = prefs.getBool(_isPremiumKey) ?? false;
    _emitRemainingTime();
  }

  void startTracking() {
    if (_isPremium) return;

    _usageTimer?.cancel();
    _usageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentUsage++;
      _saveUsage();
      _emitRemainingTime();

      if (_currentUsage >= _freeLimitSeconds) {
        stopTracking();
      }
    });
  }

  void stopTracking() {
    _usageTimer?.cancel();
    _saveUsage();
  }

  Future<void> _saveUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_usageKey, _currentUsage);
  }

  void _emitRemainingTime() {
    int remaining = _freeLimitSeconds - _currentUsage;
    if (remaining < 0) remaining = 0;
    _remainingTimeController.add(remaining);
  }

  bool hasAccess() {
    if (_isPremium) return true;
    return _currentUsage < _freeLimitSeconds;
  }

  // Mock Purchase Function
  Future<bool> buyPremium() async {
    // In a real app, integrate 'in_app_purchase' package here.
    // await InAppPurchase.instance.buyNonConsumable(...);
    
    await Future.delayed(const Duration(seconds: 2)); // Simulate network
    _isPremium = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, true);
    _emitRemainingTime(); // Will stop emitting countdown effectively
    return true;
  }
  
  // Reset for testing purposes
  Future<void> resetUsage() async {
    _currentUsage = 0;
    _isPremium = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_usageKey, 0);
    await prefs.setBool(_isPremiumKey, false);
    _emitRemainingTime();
  }
}

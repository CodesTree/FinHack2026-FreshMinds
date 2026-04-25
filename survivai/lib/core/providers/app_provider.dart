import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/loan_model.dart';
import '../services/mock_data_service.dart';

const int kEmergencyThreshold = 5;

class AppProvider extends ChangeNotifier {
  late UserModel _user;
  LoanModel? _activeLoan;
  bool _ctosConsented = false;
  int _nudgeStreak = 3;
  bool _emergencyAutoTriggered = false;

  AppProvider() {
    _user = MockDataService.getSitiProfile();
    _checkAndAutoTriggerEmergency();
  }

  UserModel get user => _user;
  LoanModel? get activeLoan => _activeLoan;
  bool get ctosConsented => _ctosConsented;
  int get nudgeStreak => _nudgeStreak;
  bool get emergencyAutoTriggered => _emergencyAutoTriggered;
  bool get shouldShowEmergencyBanner =>
      _user.survivalDays <= kEmergencyThreshold && !_user.emergencyModeActive;

  void _checkAndAutoTriggerEmergency() {
    if (_user.survivalDays <= kEmergencyThreshold && !_user.emergencyModeActive) {
      _user = UserModel(
        id: _user.id,
        name: _user.name,
        walletBalance: _user.walletBalance,
        survivalDays: _user.survivalDays,
        dailyBurnRate: _user.dailyBurnRate,
        trend: _user.trend,
        colorBand: _user.colorBand,
        emergencyModeActive: true,
        topDiscretionaryCategory: _user.topDiscretionaryCategory,
        topDiscretionaryAmount: _user.topDiscretionaryAmount,
        hasActiveLoan: _user.hasActiveLoan,
        monthlyIncome: _user.monthlyIncome,
      );
      _emergencyAutoTriggered = true;
    }
  }

  void activateEmergencyMode() {
    _user = MockDataService.getSitiEmergencyProfile();
    notifyListeners();
  }

  void deactivateEmergencyMode() {
    _emergencyAutoTriggered = false;
    _user = MockDataService.getSitiProfile();
    _checkAndAutoTriggerEmergency();
    notifyListeners();
  }

  void setCtosConsent(bool value) {
    _ctosConsented = value;
    notifyListeners();
  }

  void approveLoan() {
    _activeLoan = MockDataService.getApprovedLoan();
    _user = UserModel(
      id: _user.id,
      name: _user.name,
      walletBalance: _user.walletBalance,
      survivalDays: _user.survivalDays,
      dailyBurnRate: _user.dailyBurnRate,
      trend: _user.trend,
      colorBand: _user.colorBand,
      emergencyModeActive: _user.emergencyModeActive,
      topDiscretionaryCategory: _user.topDiscretionaryCategory,
      topDiscretionaryAmount: _user.topDiscretionaryAmount,
      hasActiveLoan: true,
      monthlyIncome: _user.monthlyIncome,
    );
    notifyListeners();
  }

  void incrementNudgeStreak() {
    _nudgeStreak++;
    notifyListeners();
  }

  void updateMonthlyIncome(double newIncome) {
    _user = UserModel(
      id: _user.id,
      name: _user.name,
      walletBalance: _user.walletBalance,
      survivalDays: _user.survivalDays,
      dailyBurnRate: _user.dailyBurnRate,
      trend: _user.trend,
      colorBand: _user.colorBand,
      emergencyModeActive: _user.emergencyModeActive,
      topDiscretionaryCategory: _user.topDiscretionaryCategory,
      topDiscretionaryAmount: _user.topDiscretionaryAmount,
      hasActiveLoan: _user.hasActiveLoan,
      monthlyIncome: newIncome,
    );
    notifyListeners();
  }
}

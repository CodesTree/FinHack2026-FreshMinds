import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/loan_model.dart';
import '../services/mock_data_service.dart';
import '../services/survivai_repository.dart';

const int kEmergencyThreshold = 5;

class AppProvider extends ChangeNotifier {
  late UserModel _user;
  final SurvivaiRepository _repository;
  LoanModel? _activeLoan;
  bool _ctosConsented = false;
  int _nudgeStreak = 3;
  bool _emergencyAutoTriggered = false;
  bool _isLoading = false;
  String? _error;

  AppProvider({SurvivaiRepository? repository})
      : _repository = repository ?? SurvivaiRepository() {
    _user = MockDataService.getSitiProfile();
    loadDashboard();
  }

  AppProvider.test({required SurvivaiRepository repository}) : _repository = repository {
    _user = MockDataService.getSitiProfile();
  }

  UserModel get user => _user;
  LoanModel? get activeLoan => _activeLoan;
  bool get ctosConsented => _ctosConsented;
  int get nudgeStreak => _nudgeStreak;
  bool get emergencyAutoTriggered => _emergencyAutoTriggered;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get shouldShowEmergencyBanner =>
      _user.survivalDays <= kEmergencyThreshold && !_user.emergencyModeActive;

  Future<void> loadDashboard({String userId = 'user_siti_001'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.fetchSurvivalScore(userId);
      _checkAndAutoTriggerEmergency();
    } catch (e) {
      _error = e.toString();
      _user = MockDataService.getSitiProfile();
      _checkAndAutoTriggerEmergency();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _checkAndAutoTriggerEmergency() {
    if (_user.survivalDays <= kEmergencyThreshold && !_user.emergencyModeActive) {
      _user = _user.copyWith(emergencyModeActive: true);
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
    _user = _user.copyWith(hasActiveLoan: true);
    notifyListeners();
  }

  void incrementNudgeStreak() {
    _nudgeStreak++;
    notifyListeners();
  }

  void updateMonthlyIncome(double newIncome) {
    _user = _user.copyWith(monthlyIncome: newIncome);
    notifyListeners();
  }
}

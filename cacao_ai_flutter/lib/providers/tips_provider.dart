import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/tip.dart';
import '../data/services/supabase_service.dart';
import '../../core/constants/app_constants.dart';

class TipsProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Tip> _tips = [];
  Set<String> _favoriteIds = {};
  List<String> _historyIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Tip> get tips => _tips;
  List<Tip> get favoriteTips => _tips.where((t) => _favoriteIds.contains(t.id)).toList();
  List<Tip> get historyTips => _tips.where((t) => _historyIds.contains(t.id)).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TipsProvider() {
    _loadPreferences().then((_) => fetchTips());
  }

  // Load preferences (Favorites and History from storage)
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList(AppConstants.keyFavoriteTips);
      if (favs != null) {
        _favoriteIds = favs.toSet();
      }
      final hist = prefs.getStringList(AppConstants.keyHistoryTips);
      if (hist != null) {
        _historyIds = hist;
      }
    } catch (e) {
      print("[TipsProvider] Error loading preferences: $e");
    }
  }

  // Save preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(AppConstants.keyFavoriteTips, _favoriteIds.toList());
      await prefs.setStringList(AppConstants.keyHistoryTips, _historyIds);
    } catch (e) {
      print("[TipsProvider] Error saving preferences: $e");
    }
  }

  // Fetch tips from Supabase DB
  Future<void> fetchTips() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _supabaseService.fetchTips();
      _tips = data.map((map) {
        final id = map['id']?.toString() ?? '';
        return Tip.fromMap(map, isFav: _favoriteIds.contains(id));
      }).toList();
    } catch (e) {
      _errorMessage = "Impossible de récupérer les conseils agricoles.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle Favorite state
  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    
    // Update the tip state in list
    _tips = _tips.map((t) => t.id == id ? t.copyWith(isFavorite: _favoriteIds.contains(id)) : t).toList();
    notifyListeners();
    _savePreferences();
  }

  // Add tip to reading history
  void addToHistory(String id) {
    if (_historyIds.contains(id)) {
      _historyIds.remove(id);
    }
    _historyIds.insert(0, id); // add to top
    if (_historyIds.length > 10) {
      _historyIds = _historyIds.sublist(0, 10); // cap history size
    }
    notifyListeners();
    _savePreferences();
  }
}

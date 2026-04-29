import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshio/data/services/storage_service.dart';

class FamilyMember {
  final String id;
  final String name;
  final String age;
  final String diet;
  final List<String> allergies;
  final String? medical;
  final String? photo;

  FamilyMember({
    required this.id,
    required this.name,
    required this.age,
    required this.diet,
    this.allergies = const [],
    this.medical,
    this.photo,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'diet': diet,
    'allergies': allergies,
    'medical': medical,
    'photo': photo,
  };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    diet: json['diet'],
    allergies: List<String>.from(json['allergies'] ?? []),
    medical: json['medical'],
    photo: json['photo'],
  );
}

class UserProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  bool _isLoggedIn = false;
  bool _isFirstTimeUser = true;
  String _userName = '';
  String _userEmail = '';
  String _userAge = '';
  String _userDiet = 'Vegetarian';
  String _userStorage = 'Fridge';
  String _password = 'password123'; // Default for demo
  String? _userPhoto;
  List<FamilyMember> _familyMembers = [];

  bool get isLoggedIn => _isLoggedIn;
  bool get isFirstTimeUser => _isFirstTimeUser;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userAge => _userAge;
  String get userDiet => _userDiet;
  String get userStorage => _userStorage;
  String? get userPhoto => _userPhoto;
  List<FamilyMember> get familyMembers => _familyMembers;

  UserProvider() {
    _loadUserData();
  }

  void _loadUserData() {
    _isLoggedIn = _storage.getBool('isLoggedIn') ?? false;
    _isFirstTimeUser = _storage.getBool('isFirstTimeUser') ?? true;
    _userName = _storage.getString('user_name') ?? '';
    _userEmail = _storage.getString('user_email') ?? '';
    _userAge = _storage.getString('user_age') ?? '';
    _userDiet = _storage.getString('user_diet') ?? 'Vegetarian';
    _userStorage = _storage.getString('user_storage') ?? 'Fridge';
    _password = _storage.getString('user_password') ?? 'password123';
    _userPhoto = _storage.getString('user_photo');

    final membersJson = _storage.getString('household_members');
    if (membersJson != null) {
      final List<dynamic> decoded = jsonDecode(membersJson);
      _familyMembers = decoded.map((e) => FamilyMember.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> updateProfilePhoto(String path) async {
    _userPhoto = path;
    await _storage.setString('user_photo', path);
    notifyListeners();
  }

  Future<void> login(String email, String name) async {
    _isLoggedIn = true;
    _userEmail = email;
    _userName = name;
    
    await _storage.setBool('isLoggedIn', true);
    await _storage.setString('user_email', email);
    await _storage.setString('user_name', name);
    notifyListeners();
  }

  Future<void> completeProfile({
    required String name,
    required String age,
    required String diet,
    required String storage,
    required String householdSize,
  }) async {
    _userName = name;
    _userAge = age;
    _userDiet = diet;
    _userStorage = storage;
    _isFirstTimeUser = false;

    await _storage.setString('user_name', name);
    await _storage.setString('user_age', age);
    await _storage.setString('user_diet', diet);
    await _storage.setString('user_storage', storage);
    await _storage.setString('user_household', householdSize);
    await _storage.setBool('isFirstTimeUser', false);
    notifyListeners();
  }

  Future<void> addFamilyMember(FamilyMember member) async {
    _familyMembers.add(member);
    await _saveFamilyMembers();
    notifyListeners();
  }

  Future<void> updateFamilyMember(FamilyMember member) async {
    final index = _familyMembers.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      _familyMembers[index] = member;
      await _saveFamilyMembers();
      notifyListeners();
    }
  }

  Future<void> deleteFamilyMember(String id) async {
    _familyMembers.removeWhere((m) => m.id == id);
    await _saveFamilyMembers();
    notifyListeners();
  }

  Future<void> _saveFamilyMembers() async {
    final data = _familyMembers.map((e) => e.toJson()).toList();
    await _storage.setString('household_members', jsonEncode(data));
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await _storage.setBool('isLoggedIn', false);
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    _password = newPassword;
    await _storage.setString('user_password', newPassword);
    notifyListeners();
  }
}

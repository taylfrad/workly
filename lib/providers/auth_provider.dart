import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isSigningIn = false; // Add flag to track sign-in process
  String? _errorMessage;
  DateTime? _lastAuthStateChange; // Add timestamp to debounce rapid changes

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _currentUser != null && !_currentUser!.isGuest;
  bool get isGuest => _currentUser?.isGuest ?? false;
  bool get hasUser => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  void _initializeAuth() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      // Debounce rapid auth state changes
      final now = DateTime.now();
      if (_lastAuthStateChange != null && 
          now.difference(_lastAuthStateChange!).inMilliseconds < 500) {
        return;
      }
      _lastAuthStateChange = now;
      
      
      if (firebaseUser != null) {
        // User is signed in with Firebase - try to load saved profile data
        UserModel? savedUser = await UserStorageService.loadUserProfile();
        
        
        if (savedUser != null && savedUser.userId == firebaseUser.uid) {
          // Use saved profile data
          _currentUser = savedUser;
          // Force multiple rebuilds to ensure UI updates
          notifyListeners();
          Future.delayed(const Duration(milliseconds: 100), () {
            notifyListeners();
          });
          Future.delayed(const Duration(milliseconds: 200), () {
            notifyListeners();
          });
        } else {
          // Create new user with Firebase data, but try to merge with any existing profile data
          _currentUser = UserModel(
            userId: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            isGuest: false,
            authProvider: 'google',
            photoUrl: firebaseUser.photoURL,
          );
          
          // If we have saved data but user ID doesn't match, try to merge it
          if (savedUser != null) {
            _currentUser!.phoneNumber = savedUser.phoneNumber;
            _currentUser!.location = savedUser.location;
            _currentUser!.summary = savedUser.summary;
            _currentUser!.portfolioUrl = savedUser.portfolioUrl;
            _currentUser!.githubUrl = savedUser.githubUrl;
            _currentUser!.linkedinUrl = savedUser.linkedinUrl;
            _currentUser!.skills = savedUser.skills;
            _currentUser!.workExperience = savedUser.workExperience;
            _currentUser!.education = savedUser.education;
            _currentUser!.resumeFileName = savedUser.resumeFileName;
            _currentUser!.resumeFilePath = savedUser.resumeFilePath;
            
            // Save the merged profile with the correct user ID
            await UserStorageService.saveUserProfile(_currentUser!);
          }
          
        }
      } else {
        // Only clear user if we're not in the middle of a sign-in process
        if (!_isLoading && !_isSigningIn) {
          _currentUser = null;
        } else {
        }
      }
      notifyListeners();
    });
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _isSigningIn = true; // Set flag to prevent auth state listener from clearing user
    _clearError();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        // Wait for the Firebase auth state listener to process the new user
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Force multiple rebuilds to ensure UI updates
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));
        notifyListeners();
        
        return true;
      } else {
        _setError('Sign-in was cancelled');
        return false;
      }
    } catch (e) {
      _setError('Failed to sign in with Google: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
      // Don't clear _isSigningIn immediately - let the auth state listener handle it
      Future.delayed(const Duration(milliseconds: 1000), () {
        _isSigningIn = false;
      });
    }
  }

  // Sign in as guest
  void signInAsGuest() {
    _currentUser = _authService.createGuestUser();
    notifyListeners();
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      // DON'T clear stored profile data - keep it for when user signs back in
      // await UserStorageService.clearUserProfile();
      
      // Clear the current user immediately
      _currentUser = null;
      notifyListeners();
      
      // Then sign out from services
      await _authService.signOut();
      
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      // Clear stored profile data when deleting account
      await UserStorageService.clearUserProfile();
      
      final success = await _authService.deleteAccount();
      if (success) {
        _currentUser = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_currentUser == null || _currentUser!.isGuest) {
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final success = await _authService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      
      if (success && _currentUser != null) {
        _currentUser = UserModel(
          userId: _currentUser!.userId,
          name: displayName ?? _currentUser!.name,
          email: _currentUser!.email,
          experience: _currentUser!.experience,
          skills: _currentUser!.skills,
          resumeFileName: _currentUser!.resumeFileName,
          resumeFilePath: _currentUser!.resumeFilePath,
          phoneNumber: _currentUser!.phoneNumber,
          location: _currentUser!.location,
          summary: _currentUser!.summary,
          workExperience: _currentUser!.workExperience,
          education: _currentUser!.education,
          portfolioUrl: _currentUser!.portfolioUrl,
          githubUrl: _currentUser!.githubUrl,
          linkedinUrl: _currentUser!.linkedinUrl,
          isGuest: _currentUser!.isGuest,
          authProvider: _currentUser!.authProvider,
          photoUrl: photoURL ?? _currentUser!.photoUrl,
        );
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update local user data (for profile editing)
  void updateLocalUser(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}

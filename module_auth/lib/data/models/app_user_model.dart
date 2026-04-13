import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    super.email,
    super.displayName,
    super.role,
  });

  factory AppUserModel.fromFirebaseUser(User user, {String role = 'user'}) {
    return AppUserModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      role: role,
    );
  }
}

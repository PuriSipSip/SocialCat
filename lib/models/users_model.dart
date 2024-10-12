class UsersModel {
  String email;
  String username;
  String photoURL;
  String bio;

  UsersModel({
    required this.email,
    required this.username,
    required this.photoURL,
    this.bio = 'loves cats!', // Default value for bio
  });

  // Convert model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'photoURL': photoURL,
      'bio': bio,
    };
  }

  // Factory method to create model from Firestore data
  factory UsersModel.fromMap(Map<String, dynamic> data) {
    return UsersModel(
      email: data['email'] ?? 'Unknown email',
      username: data['username'] ?? 'Unknown username',
      photoURL: data['photoURL'] ??
          'https://firebasestorage.googleapis.com/v0/b/socialcat-5e8af.appspot.com/o/dinosauravatar.png?alt=media&token=b3bbad75-a5ce-4866-a27b-447620405054',
      bio: data['bio'] ?? 'love cats!',
    );
  }
}

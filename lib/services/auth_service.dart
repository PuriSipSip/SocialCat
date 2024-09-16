import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // begin interactive sign in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) return null; // If the user cancels the login

      // obtain auth details from the request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // create a new credential for the user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // sign in to Firebase with the credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // get the signed-in user
      User? user = userCredential.user;

      if (user != null) {
        // ตรวจสอบว่าผู้ใช้มีข้อมูลใน Firestore แล้วหรือไม่
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.email)
            .get();

        if (!userDoc.exists) {
          // ถ้าไม่มีข้อมูลใน Firestore ให้บันทึกข้อมูลใหม่
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.email)
              .set({
            'email': user.email,
            'username': user.displayName,
            'photoURL': user.photoURL,
          });
        }
      }

      return userCredential;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }
}

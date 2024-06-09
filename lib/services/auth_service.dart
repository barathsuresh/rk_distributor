import 'dart:async'; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rk_distributor/screens/Home_Screens/home_screen_norm.dart';
import 'package:rk_distributor/screens/Home_Screens/home_screen_super_su.dart';
import 'package:rk_distributor/screens/login_screen.dart';

import '../screens/user_waiting_page.dart';

enum SignInStatus {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCancelled,
}

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GetStorage _localStorage = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final status = Rxn<SignInStatus>();
  var user = Rxn<Map<String, dynamic>>(); // Use Map to store user details
  var appAccess = false.obs;
  var superSu = false.obs;
  var writeAccess = false.obs;
  var updateAccess = false.obs;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  @override
  void onInit() {
    super.onInit();

    // Check for stored user data
    final storedUser = _localStorage.read('user');
    if (storedUser != null) {
      user.value = Map<String, dynamic>.from(storedUser);
      status.value = SignInStatus.authenticated;
      appAccess.value = storedUser['appAccess'] ?? false;
      superSu.value = storedUser['access']['superSu'] ?? false;
      updateAccess.value = storedUser['access']['updateAccess'] ?? false;
      writeAccess.value = storedUser['access']['writeAccess'] ?? false;
    }

    _auth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        user.value = {
          'uid': firebaseUser.uid,
          'name': firebaseUser.displayName,
          'email': firebaseUser.email ?? '',
          'photoUrl': firebaseUser.photoURL,
        };
        status.value = SignInStatus.authenticated;

        // Set up Firestore snapshot listener for appAccess
        // Cancel the previous subscription if it exists
        _userDocSubscription?.cancel();

        // Create a new subscription to listen for changes in the user document
        _userDocSubscription = _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .snapshots()
            .listen((docSnapshot) async {
          if (docSnapshot.exists) {
            bool isSuperSu = docSnapshot['access']['superSu'] ?? false;
            superSu.value = isSuperSu;
            if (isSuperSu) {
              appAccess.value = true;
              writeAccess.value = true;
              updateAccess.value = true;
              await _firestore
                  .collection('users')
                  .doc(firebaseUser.uid)
                  .update({
                'access.writeAccess': true,
                'access.updateAccess': true,
                'appAccess': true,
              });
            } else {
              appAccess.value = docSnapshot['appAccess'] ?? false;
              updateAccess.value =
                  docSnapshot['access']['updateAccess'] ?? false;
              writeAccess.value = docSnapshot['access']['writeAccess'] ?? false;
            }
            // Update local storage with the latest appAccess value
            _localStorage.write('user', {
              'uid': firebaseUser.uid,
              'email': firebaseUser.email,
              'name': firebaseUser.displayName,
              'photoUrl': firebaseUser.photoURL,
              'appAccess': docSnapshot['appAccess'],
              'access': {
                'superSu': docSnapshot['access']['superSu'],
                'writeAccess': docSnapshot['access']['writeAccess'],
                'updateAccess': docSnapshot['access']['updateAccess']
              }
            });
            bool loggedIn = docSnapshot['loggedIn'] ?? false;
            if (!loggedIn) {
              // If loggedIn is set to false, sign out the user
              signOut();
            }
          }
        });
      } else {
        user.value = null;
        status.value = SignInStatus.uninitialized;

        // Cancel the subscription when the user signs out
        _userDocSubscription?.cancel();
        _userDocSubscription = null;
      }
    });

    ever(status, (SignInStatus? status) {
      if (status != null) {
        switch (status) {
          case SignInStatus.authenticating:
            Fluttertoast.showToast(msg: "Signing in...");
            break;
          case SignInStatus.authenticated:
            Fluttertoast.showToast(msg: "Sign in successful");
            break;
          case SignInStatus.authenticateError:
            Fluttertoast.showToast(msg: "Sign in error");
            break;
          case SignInStatus.authenticateCancelled:
            Fluttertoast.showToast(msg: "Sign in cancelled");
            break;
          default:
            break;
        }
      }
    });

    // Listen to changes in appAccess
    ever(appAccess, (bool hasAccess) {
      if (!hasAccess) {
        Get.offAll(() => UserWaitingPage());
      } else {
        if (superSu.value) {
          Get.off(() => HomeScreenSuperSu());
        } else {
          Get.off(() => HomeScreenNorm());
        }
      }
    });

    ever(superSu, (bool hasAccess) {
      if (appAccess.value == false) {
        Get.offAll(() => UserWaitingPage());
      } else {
        if (!hasAccess) {
          Get.offAll(() => HomeScreenNorm());
        } else {
          Get.off(() => HomeScreenSuperSu());
        }
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      status.value = SignInStatus.authenticating;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        status.value = SignInStatus.authenticateCancelled;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? tempUser = userCredential.user;

      if (tempUser != null) {
        user.value = {
          'uid': tempUser.uid,
          'name': tempUser.displayName,
          'email': tempUser.email ?? '',
          'photoUrl': tempUser.photoURL,
        };

        status.value = SignInStatus.authenticated;

        final userDoc = _firestore.collection('users').doc(tempUser.uid);
        final docSnapshot = await userDoc.get();
        if (docSnapshot.exists) {
          // If document exists, update the fields
          await userDoc.update({
            'email': tempUser.email,
            'name': tempUser.displayName,
            'photoUrl': tempUser.photoURL,
            'loggedIn': true,
            'lastLoginAt': DateTime.now().microsecondsSinceEpoch.toString()
          });
          bool isSuperSu = docSnapshot['access']['superSu'] ?? false;
          superSu.value = isSuperSu;
          if (isSuperSu) {
            appAccess.value = true;
            writeAccess.value = true;
            updateAccess.value = true;
            await _firestore.collection('users').doc(tempUser.uid).update({
              'access.writeAccess': true,
              'access.updateAccess': true,
              'appAccess': true,
            });
          } else {
            appAccess.value = docSnapshot['appAccess'] ?? false;
            updateAccess.value = docSnapshot['access']['updateAccess'] ?? false;
            writeAccess.value = docSnapshot['access']['writeAccess'] ?? false;
          }
          _localStorage.write('user', {
            'uid': tempUser.uid,
            'email': tempUser.email,
            'name': tempUser.displayName,
            'photoUrl': tempUser.photoURL,
            'appAccess': docSnapshot['appAccess'],
            'access': {
              'superSu': docSnapshot['access']['superSu'],
              'writeAccess': docSnapshot['access']['writeAccess'],
              'updateAccess': docSnapshot['access']['updateAccess']
            }
          });
        } else {
          // If document does not exist, create a new document
          await userDoc.set({
            'uid': tempUser.uid,
            'email': tempUser.email,
            'name': tempUser.displayName,
            'photoUrl': tempUser.photoURL,
            'appAccess': false,
            'loggedIn': true,
            'access': {
              'superSu': false,
              'writeAccess': false,
              'updateAccess': false
            },
            'createdAt': DateTime.now().microsecondsSinceEpoch.toString(),
            'lastLoginAt': DateTime.now().microsecondsSinceEpoch.toString()
          });
          appAccess.value = false;
          superSu.value = false;
          updateAccess.value = false;
          writeAccess.value = false;
          _localStorage.write('user', {
            'uid': tempUser.uid,
            'email': tempUser.email,
            'name': tempUser.displayName,
            'photoUrl': tempUser.photoURL,
            'appAccess': false,
            'access': {
              'superSu': false,
              'writeAccess': false,
              'updateAccess': false
            }
          });
        }
      }
    } on Exception catch (e) {
      status.value = SignInStatus.authenticateError;
    }
  }

  void signOut() async {
    await _firestore
        .collection('users')
        .doc(user.value!['uid'])
        .update({"loggedIn": false});
    await _auth.signOut();
    await _googleSignIn.signOut();
    _localStorage.remove('user');
    user.value = null;
    status.value = SignInStatus.uninitialized;

    // Cancel the subscription when the user signs out
    _userDocSubscription?.cancel();
    _userDocSubscription = null;

    Fluttertoast.showToast(msg: "Signed out");
    Get.offAll(LoginScreen());
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_dersleri/cloud_firestore.dart';
import 'package:flutter_firebase_dersleri/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FirestoreIslemleri(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseAuth auth;
  final String _email = "mst.ttr02@gmail.com";
  final String _password = "yenisifre";

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen(
      (User? user) {
        if (user == null) {
          debugPrint("User oturumu kapalı");
        } else {
          debugPrint(
              "User oturumu açık ${user.email} ve email durumu ${user.emailVerified}  ");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                createUserEmailAndPassword();
              },
              child: const Text("Email/Şifre Kayıt"),
            ),
            ElevatedButton(
              onPressed: () {
                loginUserEmailAndPassword();
              },
              child: const Text("Email/Şifre Giriş"),
            ),
            ElevatedButton(
              onPressed: () {
                signOutUser();
              },
              child: const Text("oturumu kapat"),
            ),
            ElevatedButton(
              onPressed: () {
                deleteUser();
              },
              child: const Text("kullanıcıyı sil"),
            ),
            ElevatedButton(
              onPressed: () {
                changePassword();
              },
              child: const Text("Parola değiştir"),
            ),
            ElevatedButton(
              onPressed: () {
                changeEmail();
              },
              child: const Text("Parola değiştir"),
            ),
          ],
        ),
      ),
    );
  }

  void createUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      var _myUser = _userCredential.user;
      if (!_myUser!.emailVerified) {
        await _myUser.sendEmailVerification();
      }
      debugPrint(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loginUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      debugPrint(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void signOutUser() async {
    await auth.signOut();
  }

  void deleteUser() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
    } else {
      debugPrint("Kullanıcı oturum açmadığı için silinemez");
    }
  }

  void changePassword() async {
    try {
      await auth.currentUser!.updatePassword("yenisifre");
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        debugPrint("reauthenticate olunacak");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        await auth.currentUser!.updatePassword("yenisifre");
        await auth.signOut();
        debugPrint("şifre güncellendi");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void changeEmail() async {
    try {
      await auth.currentUser!.verifyBeforeUpdateEmail("mst@gmail.com");
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        debugPrint("reauthenticate olunacak");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        await auth.currentUser!.verifyBeforeUpdateEmail("mst@gmail.com");
        await auth.signOut();
        debugPrint("mail güncellendi");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

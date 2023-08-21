import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Псевдоним для Firebase классов
import 'package:yarytefit/domain/user.dart'; // Псевдоним для вашего класса

class AuthService {
  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  final CollectionReference _userDataCollection = FirebaseFirestore.instance.collection("userData");

Future<ProfUser> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential result = await _fAuth.signInWithEmailAndPassword(email: email, password: password);
    User firebaseUser = result.user;
    var user = ProfUser.fromFirebase(firebaseUser); // Используем Firebase.User
    return user;
  } catch (e) {
    print("Ошибка при входе: $e"); // Выводим ошибку в консоль
    return null;
  }
}


Future<ProfUser> registerWithEmailAndPassword(String email, String password) async {
  try {
    // Проверяем, есть ли пользователь с таким email
    var existingUser = await _fAuth.fetchSignInMethodsForEmail(email);
    if (existingUser.isNotEmpty) {
      print(' Пользователь с таким email уже существует!');
      return null;
    }

    // Регистрируем нового пользователя
    UserCredential result = await _fAuth.createUserWithEmailAndPassword(email: email, password: password);
    User firebaseUser = result.user;
    var user = ProfUser.fromFirebase(firebaseUser);

    var userData = UserData();
    await _userDataCollection.doc(user.id).set(userData.toMap());

    return user;
  } catch (e) {
    print("Ошибка при регистрации: $e");
    return null;
  }
}


  Future<void> logOut() async {
    await _fAuth.signOut();
  }

  Stream<ProfUser> get currentUser {
    return _fAuth.authStateChanges().map((User user) =>
        user != null ? ProfUser.fromFirebase(user) : null); 
  }

  Stream<ProfUser> getCurrentUserWithData(ProfUser user) {
  return _userDataCollection.doc(user?.id).snapshots().map((snapshot) {
    if (snapshot?.data == null) return null;

    var userData = UserData.fromJson(snapshot.id, snapshot.data());

    user.setUserData(userData); // Используем переданный объект user

    return user; // Возвращаем переданный объект user после обновления данных
  });
}


// Stream<ProfUser> getCurrentUserWithData(ProfUser user) {
//   return _userDataCollection.doc(user?.id).snapshots().map((snapshot) {
//     try {
//       if (snapshot?.data == null) return null;

//       var userData = UserData.fromJson(snapshot.id, snapshot.data());

//       var appUser = ProfUser.fromFirebase(user as User); 
//       appUser.setUserData(userData);

//       return appUser;
//     } catch (e) {
//       print("Error in getCurrentUserWithData: $e");
//       return null;
//     }
//   });
// }

}
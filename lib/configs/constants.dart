import '../controllers/firestore_controller.dart';
import 'typedefs.dart';

class QuestionType {
  static const String audio = "Audio";
  static const String image = "Image";
}

class LanguagesType {
  static const String english = "English";
  static const String hindi = "Hindi";
  static const String marathi = "Marathi";
  static const String tamil = "Tamil";
  static const String telugu = "Telugu";

  static const List<String> languages = <String>[
    english,
    hindi,
    marathi,
    tamil,
    telugu,
  ];
}

class FirebaseNodes {
  //region Users Collection
  static const String usersCollection = 'users';

  static MyFirestoreCollectionReference get usersCollectionReference => FirestoreController.collectionReference(collectionName: usersCollection);

  static MyFirestoreDocumentReference usersDocumentReference({String? userId}) => FirestoreController.documentReference(
    collectionName: usersCollection,
    documentId: userId,
  );
  //endregion

  //region Questions Collection
  static const String questionsCollection = 'questions';

  static MyFirestoreCollectionReference get questionsCollectionReference => FirestoreController.collectionReference(collectionName: questionsCollection);

  static MyFirestoreDocumentReference questionsDocumentReference({String? questionId}) => FirestoreController.documentReference(
    collectionName: questionsCollection,
    documentId: questionId,
  );
  //endregion
}

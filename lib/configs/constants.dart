import '../controllers/firestore_controller.dart';
import 'typedefs.dart';

class QuestionType {
  static const String audio = "Audio";
  static const String image = "Image";
}

class LanguagesType {
  // static const String english = "English";
  static const String hindi = "Hindi";
  static const String gujarati = "Gujarati";
  static const String marathi = "Marathi";
  static const String sanskrit = "Sanskrit";
  static const String kannad = "Kannad";

  static const List<String> languages = <String>[
    // english,
    hindi,
    gujarati,
    marathi,
    sanskrit,
    kannad,
  ];
}

class FirebaseNodes {
  //region Admin Collection
  static const String adminCollection = 'admin';

  //region Language-Wise Posters document
  static const String languagewisePostersDocument = 'languagewisePosters';

  static MyFirestoreDocumentReference languagewisePostersDocumentReference() => FirestoreController.documentReference(
    collectionName: adminCollection,
    documentId: languagewisePostersDocument,
  );
  //endregion
  //endregion

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

  //region Poster Collection
  static const String postersCollection = 'posters';

  static MyFirestoreCollectionReference get postersCollectionReference => FirestoreController.collectionReference(collectionName: postersCollection);

  static MyFirestoreDocumentReference postersDocumentReference({String? posterId}) => FirestoreController.documentReference(
    collectionName: postersCollection,
    documentId: posterId,
  );
  //endregion
}

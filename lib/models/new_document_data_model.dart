import 'package:cloud_firestore/cloud_firestore.dart';

class NewDocumentDataModel {
  String docid = "";
  Timestamp timestamp = Timestamp.now();

  NewDocumentDataModel({
    this.docid = "",
    required this.timestamp,
  });
}
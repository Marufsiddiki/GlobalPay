import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/worker.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;
  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Worker>> watchWorkers() => _firestore.collection('workers').snapshots().map((snapshot) => snapshot.docs.map((doc) => Worker.fromMap(doc.data())).toList());
  Future<void> saveWorker(Worker worker) => _firestore.collection('workers').add(worker.toMap());
  Future<void> deleteWorker(String id) => _firestore.collection('workers').doc(id).delete();
}
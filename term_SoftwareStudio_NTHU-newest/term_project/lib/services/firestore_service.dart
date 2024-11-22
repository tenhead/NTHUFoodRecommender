
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:term_project/models/my_record.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseService _instance = FirebaseService._privateConstructor();


  FirebaseService._privateConstructor();

  static FirebaseService get instance => _instance;
  
  Future<List<MyRecord>> loadAllRecords() async {
    try {
      var querySnapshot = await _db.collection('records').get();
      return querySnapshot.docs
          .map((doc) => MyRecord.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading records: $e');
      return [];
    }
  }
 Future<void> initializeCounter() async {
  final docRef = FirebaseFirestore.instance.collection('utils').doc('counter');
  final docSnapshot = await docRef.get();
  if (!docSnapshot.exists) {
    await docRef.set({'currentId': 0}); 
  }
 }

  Future<int> getAndUpdateId() async {
    final docRef = FirebaseFirestore.instance.collection('utils').doc('counter');
    return FirebaseFirestore.instance.runTransaction<int>((transaction) async {
      final docSnapshot = await transaction.get(docRef);
      if (!docSnapshot.exists) {
        transaction.set(docRef, {'currentId': 0});
        return 0;
      }
      int currentId = docSnapshot.data()?['currentId'] ?? 0;
      transaction.update(docRef, {'currentId': currentId + 1});
      return currentId;
    });
  }

  Future<bool> saveRecord(MyRecord record) async {
    try {
      await FirebaseFirestore.instance
          .collection('records')
          .doc(record.id.toString())
          .set(record.toJson());
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error saving record: $e');
      return false;
    }
  }

  Future<MyRecord> getRecordById(int id) async {
    try {
      final docSnapshot = await _db.collection('records').doc(id.toString()).get();
      return MyRecord.fromJson(docSnapshot.data()!);
    } catch (e) {
      // ignore: avoid_print
      print('Error loading record: $e');
      return MyRecord();
    }
  }


}

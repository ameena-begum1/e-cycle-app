import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class DonationBackend {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(Uint8List imageBytes) async {
    try {
      String fileId = Uuid().v4();
      Reference ref = _storage.ref().child('donations/$fileId.jpg');
      UploadTask uploadTask = ref.putData(imageBytes);
      TaskSnapshot snap = await uploadTask;
      return await snap.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> submitDonation({
    required String productName,
    required String productDesc,
    required String productCondition,
    required String repairStatus,
    required DateTime pickupDate,
    required String ngo,
    Uint8List? imageBytes,
  }) async {
    try {
      String? imageUrl;
      if (imageBytes != null) {
        imageUrl = await uploadImage(imageBytes);
      }

      await _firestore.collection('donations').add({
        'productName': productName,
        'productDesc': productDesc,
        'productCondition': productCondition,
        'repairStatus': repairStatus,
        'pickupDate': pickupDate.toIso8601String(),
        'ngo': ngo,
        'imageUrl': imageUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error submitting donation: $e");
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class DataBaseService {
  final _fire = FirebaseFirestore.instance;
  final _real = FirebaseDatabase.instance;
  //Real Time Database
  rlcreate() {
    try {
      _real.ref("users").child('user1').child("Hello").set({
        'name': "Rihan"
      }); //child is sub category like docs in store child('user1').child("Hello").set({'name': "rihan"})
    } catch (e) {
      (e.toString());
    }
  }

  rlread() async {
    try {
      final data =
          await _real.ref("users").child('user1').child("Hello").once();
      // String y = (data.snapshot.children.length.toString());//length of a data
      String y = (data.snapshot.children.toList()[0].value.toString());
      print(y);
    } catch (e) {
      (e.toString());
    }
  }

//This is the firesore database commands and

  create() {
    try {
      _fire.collection("users").add({"name": "Rihan", "age": 22});
    } catch (e) {
      (e.toString());
    }
    print("Sucessfully created");
  }

  read() async {
    try {
      final data = await _fire.collection("users").get();
      final user = data.docs[0]; //document id 0 = 1, 1= 2 etc

      String l = (user['name']);
      String y = (user['age'].toString());
      print(l);
      print(y);
    } catch (e) {
      (e.toString());
    }
  }

  update() async {
    try {
      await _fire
          .collection("users")
          .doc('x56Dppew08SOB3K9h5t5')
          .update({'name': 'Hiroosha', 'age': 15, 'address': 'SriLanka'});
    } catch (e) {
      (e.toString());
    }
  }

  delete() async {
    try {
      await _fire.collection("users").doc('x56Dppew08SOB3K9h5t5').delete();
    } catch (e) {
      (e.toString());
    }
  }

  getBins() async {
    try {
      final data = await _fire.collection("Dustbins").get();
      final binId = data.docs[0]; //document id 0 = 1, 1= 2 etc

      // String l = (user['name']);
      // String y = (user['age'].toString());
      // print(l);
      // print(y);
      print(binId['name']);
      print(binId['NetworkStatus']);
      print(binId['capacity']);
      print(binId['fillLevel']);
      print(binId['fillStatus']);
      print(binId['gasLevel']);
      print(binId['humidity']);
      print(binId['id']);
      print(binId['imageUrl']);
      print(binId['isClosed']);
      print(binId['isGay']);
      print(binId['isSub']);
      print(binId['latitude']);
      print(binId['location']);
      print(binId['longitude']);
      print(binId['mainBin']);
      print(binId['temperature']);
      print(binId['type']);
    } catch (e) {
      (e.toString());
    }
  }
}

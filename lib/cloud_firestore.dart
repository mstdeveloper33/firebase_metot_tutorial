import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreIslemleri extends StatefulWidget {
  const FirestoreIslemleri({super.key});

  @override
  State<FirestoreIslemleri> createState() => _FirestoreIslemleriState();
}

class _FirestoreIslemleriState extends State<FirestoreIslemleri> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription? _userSubscribe;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firestore Islemleri"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                veriEklemeAdd();
              },
              child: const Text("veri ekle add"),
            ),
            ElevatedButton(
              onPressed: () {
                veriEklemeSet();
              },
              child: const Text("veri ekle set"),
            ),
            ElevatedButton(
              onPressed: () {
                veriGuncelleme();
              },
              child: const Text("veri güncelle"),
            ),
            ElevatedButton(
              onPressed: () {
                veriSil();
              },
              child: const Text("veri sil"),
            ),
            ElevatedButton(
              onPressed: () {
                veriOkuOneTime();
              },
              child: const Text("veri oku one time"),
            ),
            ElevatedButton(
              onPressed: () {
                veriOkuOnRealTime();
              },
              child: const Text("veri oku real time"),
            ),
            ElevatedButton(
              onPressed: () {
                streamDurdur();
              },
              child: const Text("stream durdur"),
            ),
            ElevatedButton(
              onPressed: () {
                batchKavrami();
              },
              child: const Text("Batch Kavramı"),
            ),
            ElevatedButton(
              onPressed: () {
                tarnsactionKavrami();
              },
              child: const Text("Transaction Kavramı"),
            ),
            ElevatedButton(
              onPressed: () {
                queryingData();
              },
              child: const Text("Yeni Sorgulama"),
            ),
            ElevatedButton(
              onPressed: () {
                kamereGaleriImageUpload();
              },
              child: const Text("Yeni Sorgulama"),
            ),
          ],
        ),
      ),
    );
  }

  void veriEklemeAdd() async {
    Map<String, dynamic> _eklenecekUser = <String, dynamic>{};
    _eklenecekUser["isim"] = "mehmet";
    _eklenecekUser["yas"] = 25;
    _eklenecekUser["ogrenciMi"] = false;
    _eklenecekUser["adres"] = {"il": "Sakarya", "ilce": "Serdivan"};
    _eklenecekUser["renkler"] = FieldValue.arrayUnion(["mavi", "yeşil"]);
    _eklenecekUser["createdAt"] = FieldValue.serverTimestamp();
    await firestore.collection("users").add(_eklenecekUser);
  }

  void veriEklemeSet() async {
    var _yeniDocID = firestore.collection("users").doc().id;
    await firestore
        .doc("users/$_yeniDocID")
        .set({"isim": "sinan", "userID": _yeniDocID});
    await firestore.doc("users/uQBMvaT0CEC4QZEZbBdp").set(
      {"okul": "Sakarya Üniversitesi", "yas": 20},
      SetOptions(merge: true),
    );
  }

  void veriGuncelleme() async {
    await firestore
        .doc("users/uQBMvaT0CEC4QZEZbBdp")
        .update({"adres.ilce": " güncel ilce karasu "});
  }

  void veriSil() async {
    await firestore
        .doc("users/uQBMvaT0CEC4QZEZbBdp")
        .update({"okul": FieldValue.delete()});
  }

  void veriOkuOneTime() async {
    var _usersDocuments = await firestore.collection("users").get();
    debugPrint(_usersDocuments.size.toString());
    debugPrint(_usersDocuments.docs.length.toString());
    for (var eleman in _usersDocuments.docs) {
      debugPrint("Döküman id ${eleman.id}");
      eleman.data();
      Map userMap = eleman.data();
      debugPrint(userMap["isim"]);
    }
    var _mehmetDoc = await firestore.doc("users/luynmQjtLN859rYNrDor").get();
    debugPrint(_mehmetDoc.data()!["adres"]["ilce"].toString());
  }
  //TODO burada yapılan işlem veri okuma bu işlemde verilerin anlık olarak okunmasıdır.
  //TODO bu süreçte uygulama stream ile veritabanını dinliyor ve canlı olarak değişiklikleri gösteriyor.
  //TODO gösterilen veriler collection veya document olarak spesifik olarak işleme alınabilir.

  void veriOkuOnRealTime() async {
    var _userDocStream =
        // ignore: await_only_futures
        await firestore.doc("users/luynmQjtLN859rYNrDor").snapshots();
    _userSubscribe = _userDocStream.listen((event) {
      // event.docChanges.forEach((element) {
      //   debugPrint(element.doc.data().toString());
      // });

      debugPrint(event.data().toString());
    });
  }

  void streamDurdur() async {
    await _userSubscribe?.cancel();
  }

  void batchKavrami() async {
    WriteBatch _batch = firestore.batch();
    CollectionReference _counterColRef = firestore.collection("counter");
    //! yukarıda bir tane collection oluşturuluyor ve
    //! aşağıda yapılan işlemde batch ile bu collectionan bağlı documentleri toplu ekleme yapıyor.
    //! buranın avantajı şu şekilde batch eğer örneğin kullanıcı birden fazla ekleme yapmak istiyor ama olabilecek
    //! olumsuz durumlar için -internet gitmesi gibi vs- işlemi eğer sorun yok ise tamamlıyor ama sorun var ise işlemi bütün
    //! eklenecek veriler için iptal ediyor. çünkü aksi durumda bazı veriler eklenecek bazıları eklenemeyacek bu da iç tutarlılıkta sorun yapacak.

    /*  for (int i = 0; i < 100; i++) {
      var _yeniDoc = _counterColRef.doc();
      _batch.set(_yeniDoc, {"sayac": ++i, "id": _yeniDoc.id});
    } */

    //? aşağıda ise önceden eklenen verilerin içeriğinde güncelleme yapmak için örneğin yeni bir tarih eklemek
    //? için kullanılan yöntem burada da aynı şekilde olumsuz bir durumda eklenecek olan tüm verileri iptal ediyor
    //? aksi bir durum olmadığı takdirde tüm verileri ekliyor.

    /* var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.update(
          element.reference, {"createdAt": FieldValue.serverTimestamp()});
    });*/

    //TODO aşağıda ise collectionun bütün verilerini gezerek siliyor yani nihayetinde collectionun kendiisni siliyor.
    //TODO ama aynı şekilde olumsuz durumlara karşı işlemi iptal veya aksi bir durum yok ise işlemi tamamlıyor.

    var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.delete(element.reference);
    });
    await _batch.commit();
  }

  //! aşağıdaki metotla yapılacak işlem şunu içeriyor batch komutunu andırıyor ama şöyle bir farklılık var karşılıklı iletişime geçecek olan
  //! olan veriler arasında işlemin sonuçlanmasını sağlıyor. örneğin banka işlemlerinde bir kullanıcı başka bir kullanıcıya para işlemi yapacak
  //! ama bu işlemi yapabilmesi için kendi bakiyesinin yeterli olması gerekmektedir.bu kontrolleri sağlıyor.
  void tarnsactionKavrami() async {
    firestore.runTransaction((transaction) async {
      /*
      emrenin bakiyesini öğren
      emreden 100 lira düş 
      düşülen miktarı sinanın hesabına aktar.
      */
      DocumentReference<Map<String, dynamic>> emreRef =
          firestore.doc("users/9W1RJExPE9aKx9f9HHAN");
      DocumentReference<Map<String, dynamic>> sinanRef =
          firestore.doc("users/luynmQjtLN859rYNrDor");

      var _emreSnapshot = await transaction.get(emreRef);
      var _emreBakiye = _emreSnapshot.data()!["para"];
      if (_emreBakiye > 100) {
        var _yenibakiye = _emreSnapshot.data()!["para"] - 100;
        transaction.update(emreRef, {"para": _yenibakiye});
        transaction.update(sinanRef, {"para": FieldValue.increment(100)});
      }
    });
  }

  //TODO aşağıdaki sorgu işleminde documentler üzerinden işlem yapamayız ama collectionlar üzerinden işlem yapabiliriz.
  //Todo collectionlar üzerinden yaptığımız sorgulamalarda filtreleme işlemleri ile verimliliği arttırabiliriz.
  void queryingData() async {
    var _userRef = firestore.collection("users");
    var _sonuc =
        await _userRef.where("renkler", arrayContains: "kırmızı").get();
    for (var user in _sonuc.docs) {
      debugPrint(user.data().toString());
    }
  }

  void kamereGaleriImageUpload() async {
    final ImagePicker _picker = ImagePicker();
  }
}

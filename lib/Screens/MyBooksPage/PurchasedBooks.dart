
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'PurchasedBookDetail.dart';
import 'package:myapp/Screens/constants.dart';

class PurchasedBooks extends StatefulWidget {
  PurchasedBooks({Key? key}) : super(key: key);

  @override
  _PurchasedBooks createState() => _PurchasedBooks();
}

class _PurchasedBooks extends State<PurchasedBooks> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("books")
                .where("confirmed", isEqualTo: "Yes")
                .where("requestedBy.accepted",isEqualTo: user!.email)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {

              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data.size,
                  padding: EdgeInsets.all(5),
                  itemBuilder: (context, index) {
                    //return Container
                    var purbook = snapshot.data.docs[index];
                    return Card(
                      //height: 100,
                      child: ListTile(
                          contentPadding: EdgeInsets.all(5),
                          minVerticalPadding: 5,
                          tileColor: Colors.greenAccent[100],
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PurchasedBookDetail(bookid: purbook["bookid"])));
                          },
                          leading: Container(
                            height: 100,
                            width: 60,
                            child: Image.network(
                              (purbook["bookurl"]=="")?noimg:purbook["bookurl"],
                              fit: BoxFit.fill,
                            ),
                          ),
                          trailing: Text(""),
                          title: Text(
                              purbook["name"],
                            style: TextStyle(),
                          ),
                          subtitle: Text(
                            "Rs. " + purbook["price"],
                            style: TextStyle(color: Colors.redAccent),
                          )),
                    );
                  });
            }),
      ),
    );
  }
}

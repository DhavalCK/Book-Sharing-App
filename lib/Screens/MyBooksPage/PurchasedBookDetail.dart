import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'EditBookDetails.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/Screens/constants.dart';

class PurchasedBookDetail extends StatefulWidget {
  final bookid;
  PurchasedBookDetail({Key? key, required this.bookid}) : super(key: key);

  @override
  _PurchasedBookDetail createState() => _PurchasedBookDetail();
}

class _PurchasedBookDetail extends State<PurchasedBookDetail> {
  User? user = FirebaseAuth.instance.currentUser;
  late var book;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("books")
            .doc(widget.bookid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          book = snapshot.data;
          return Scaffold(
              body: SafeArea(
                  child: SingleChildScrollView(
            child: Column(children: <Widget>[
              //top bar and image
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.green, Colors.white, Colors.green])),
                child: Column(
                  children: [
                    //back screen icon
                    Container(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            onPressed: () => Navigator.of(context).pop(null),
                            icon: new Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ))),
                    // image of book
                    Container(
                      height: height * 0.3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Image.network(
                          (book["bookurl"] == "") ? noimg : book["bookurl"],
                          fit: BoxFit.fill,
                        )),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: Colors.black,
                height: 0,
              ),
              //book details
              Container(
                child: Center(
                  child: Column(
                    children: [
                      //book title
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "Book Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextBox(heading: "Title :", value: book["name"]),
                      TextBox(heading: "Author :", value: book["author"]),
                      TextBox(
                          heading: "Category :",
                          value: book["ctgs"].toString().replaceAll("[","").replaceAll("]","")),
                      TextBox(heading: "Publisher :", value: book["publisher"]),
                      TextBox(heading: "Edition :", value: book["edition"]),
                      TextBox(heading: "Description :", value: book["desc"]),
                      TextBox(heading: "Type :", value: book["type"]),
                      TextBox(heading: "Isbn :", value: book["isbn"]),
                      TextBox(heading: "Price :", value: book["price"]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Divider(color: Colors.black),
              //user details
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("email", isEqualTo: book["useremail"])
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot snapshot2) {
                    if (snapshot2.data == null)
                      return CircularProgressIndicator();
                    var seller = snapshot2.data.docs[0];
                    return Column(
                      children: [
                        //title of seller details
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            "Bought From " + seller["name"],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextBox(heading: "Name :", value: seller["name"]),
                        TextBox(heading: "Email :", value: seller["email"]),
                        TextBox(heading: "Contact :", value: seller["contact"]),
                        TextBox(
                            heading: "Address :",
                            value: seller["address"] +
                                ", " +
                                seller["city"] +
                                ", " +
                                seller["state"] +
                                ", " +
                                seller["country"]),
                        Divider(color: Colors.black),
                        (book["type"] == "On Rent")
                            ? StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("bookshare")
                                    .where("bookid",
                                        isEqualTo: book["bookid"])
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot3) {
                                  if (snapshot2.data == null)
                                    return CircularProgressIndicator();

                                  var bs = snapshot3.data.docs[0];
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                          "Rental Book",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      TextBox(heading: "From :",value: bs["date"]),
                                      TextBox(heading: "To : ",value: bs["duedate"]),
                                    ]

                                  );
                                })
                            : SizedBox(height: 0),

                        SizedBox(height: 30),
                      ],
                    );
                  }),
            ]),
          )));
        });
  }
}

class TextBox extends StatelessWidget {
  var heading, value;
  TextBox({Key? key, this.heading, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 110,
              child: Text(heading,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right)),
          SizedBox(width: 10),
          Flexible(
              child: (value == "")
                  ? Text(
                      "-",
                      style: TextStyle(fontSize: 16),
                    )
                  : Text(
                      value,
                      style: TextStyle(fontSize: 16),
                    ))
        ],
      ),
    );
  }
}

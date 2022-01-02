import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/Screens/constants.dart';

class RequestedBookDetail extends StatefulWidget {
  final bookid, declined;
  RequestedBookDetail({Key? key, required this.bookid, required this.declined})
      : super(key: key);

  @override
  _RequestedBookDetail createState() => _RequestedBookDetail();
}

class _RequestedBookDetail extends State<RequestedBookDetail> {
  User? user = FirebaseAuth.instance.currentUser;
  late var book;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    //cancel Request Dialog Widget when user clicked on Cancel request button
    final cancelRequestDialog = AlertDialog(
      title: Text("Cancel Request"),
      content: Text('Are sure want to cancel this Request ?'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("No")),
        TextButton(
            onPressed: () {
              //calling cancelRequest Function
              cancelRequest(book["bookid"]);
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("Yes")),
      ],
    );

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
          var clr = (widget.declined == "No") ? Colors.orange : Colors.red;
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
                  colors: [clr, Colors.white, clr],
                )),
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
                          value: book["ctgs"].toString().replaceAll("[","").replaceAll("]","")
                      ),
                      TextBox(heading: "Publisher :", value: book["publisher"]),
                      TextBox(heading: "Edition :", value: book["edition"]),
                      TextBox(heading: "Description :", value: book["desc"]),
                      TextBox(heading: "Type :", value: book["type"]),
                      TextBox(heading: "Isbn :", value: book["isbn"]),
                      TextBox(heading: "Price :", value: book["price"]),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
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
                    if (widget.declined == "No") {
                      return Column(
                        children: [
                          //title of seller details
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              "Seller Details",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextBox(heading: "Name :", value: seller["name"]),
                          TextBox(heading: "Email :", value: seller["email"]),
                          TextBox(
                              heading: "Contact :", value: seller["contact"]),
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
                          //if book type is on rent then show no of month for rent books
                          (book["type"] == "On Rent")
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        width: 150,
                                        child: Text(
                                            "No of Month :",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.right)),
                                    SizedBox(width: 10),
                                    Text(
                                      book["rentMonth"]+" (For Rent)",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                )
                              : SizedBox(height: 0),
                          SizedBox(height: 20),
                          //Call and Cancel Request Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              OutlinedButton.icon(
                                  onPressed: () =>
                                      launch("tel://" + seller["contact"]),
                                  icon: Icon(Icons.call,
                                      size: 25, color: Colors.white),
                                  label: Text(
                                    "Call Seller",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.greenAccent[400]),
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20)))),
                              OutlinedButton.icon(
                                  //call sendRequest Function
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            cancelRequestDialog);
                                    //                          cancelRequest(book["bookid"]);
                                  },
                                  icon: Icon(Icons.cancel,
                                      size: 25, color: Colors.white),
                                  label: Text(
                                    "Cancel Request",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.redAccent),
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20)))),
                            ],
                          ),
                          SizedBox(height: 30),
                        ],
                      );
                    }
                    //if book request declined than show status declined
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            "Request Status",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextBox(
                            heading: "Declined by :", value: seller["name"]),
                        SizedBox(height: 30),
                      ],
                    );
                  }),
            ]),
          )));
        });
  }

  //Cancel Request to the Seller
  cancelRequest(String bid) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    // User? user = FirebaseAuth.instance.currentUser;
    // final uemail = user!.email;

    await firebaseFirestore
        .collection("books")
        .doc(bid)
        .update({"isRequested": "No", "requestedBy.buyeremail": ""});
    Fluttertoast.showToast(msg: "Request Canceled Succesfully");
    Navigator.of(context).pop();
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

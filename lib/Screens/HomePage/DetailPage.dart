import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/Screens/constants.dart';

class DetailPage extends StatefulWidget {
  final bookid;
  DetailPage({Key? key, required this.bookid}) : super(key: key);

  @override
  _DetailPage createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  User? user = FirebaseAuth.instance.currentUser;
  late var book;
  static bool rentbook = false;

  String rent_month = "1";
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;


    final sendRequestDialog = AlertDialog(
        title: Text("Send Request"),
        content: Text('Are sure want to send this Request ?'),
        actions: [
        TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("No")),
          TextButton(
              onPressed: () {
                sendRequest(book["bookid"]);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("Yes")),
        ]
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
          return Scaffold(
              body: SafeArea(
                  child: SingleChildScrollView(
            child: Column(children: <Widget>[
              //topbar and image
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue, Colors.white, Colors.blue],
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

              //detail container
              Container(
                child: Center(
                  child: Column(
                    children: [
                      //book title
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          book["name"],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      //book details
                      TextBox(heading: "Author :", value: book["author"]),
                      TextBox(
                          heading: "Category :",
                          value: book["ctgs"].toString().replaceAll("[","").replaceAll("]","")),
                      TextBox(heading: "Publisher :", value: book["publisher"]),
                      TextBox(heading: "Edition :", value: book["edition"]),
                      TextBox(heading: "Description :", value: book["desc"]),
                      TextBox(heading: "Type :", value: book["type"]),
                      TextBox(heading: "Isbn :", value: book["isbn"]),

                      TextBox(
                          heading: (book["type"]=="On Rent")?"Price Per Month :":"Price :",
                          value: book["price"]),

                      Divider(color: Colors.black),

                      //user details
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .where("email", isEqualTo: book["useremail"])
                              .snapshots(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot2) {
                            if (snapshot2.data == null)
                              return CircularProgressIndicator();
                            var seller = snapshot2.data.docs[0];
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
                                TextBox(
                                    heading: "Name :", value: seller["name"]),
                                TextBox(
                                    heading: "Email :", value: seller["email"]),
                                TextBox(
                                    heading: "Contact :",
                                    value: seller["contact"]),
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
                                //show dropdown menu for rent month select
                                (book["type"]=="On Rent")?
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical:10,horizontal: 0),
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Text("No of Month for Rent Book",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),),
                                        Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Text("Select Month : ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),),
                                            DropdownButton<String>(
                                            value: rent_month,
                                            alignment: AlignmentDirectional.centerEnd,
                                            hint: Text("Select Month"),
                                            onChanged: (String? value) {
                                            setState((){
                                            rent_month = value!;
                                            });
                                            },
                                            items: <String>["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
                                                .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                            value: value, child: Text(value));
                                            }).toList(),
                                            ),

                                          ],
                                        ),
                                        Divider(color: Colors.black),
                                      ],
                                    ),
                                  ),
                                )
                                    :SizedBox(height: 0,),
                                //Call and Send Request Button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    OutlinedButton.icon(
                                        onPressed: () => launch(
                                            "tel://" + seller["contact"]),
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
                                                    vertical: 10,
                                                    horizontal: 20)))),
                                    OutlinedButton.icon(
                                        //call sendRequest Function
                                        onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (
                                                    BuildContext context) =>
                                                sendRequestDialog
                                            );
                                            //  sendRequest(book["bookid"]);
                                          },
                                        icon: Icon(Icons.send,
                                            size: 25, color: Colors.white),
                                        label: Text(
                                          "Send Request",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.lightBlueAccent),
                                            padding: MaterialStateProperty.all(
                                                EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 20)))),
                                  ],
                                ),
                                SizedBox(height: 20),
                              ],
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ]),
          )));
        });
  }

  //Send Request to ther Seller
  sendRequest(String bid) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    final uemail = user!.email;
    if(book["type"]=="On Rent"){
      await firebaseFirestore
          .collection("books")
          .doc(bid)
          .update({"isRequested": "Yes", "requestedBy.buyeremail": uemail,"rentMonth":rent_month});
    }
    else {
      await firebaseFirestore
          .collection("books")
          .doc(bid)
          .update({"isRequested": "Yes", "requestedBy.buyeremail": uemail});

    }

    Fluttertoast.showToast(msg: "Request Sended Succesfully");
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

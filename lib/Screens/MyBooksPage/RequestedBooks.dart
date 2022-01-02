import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'RequestedBookDetail.dart';
import 'package:myapp/Screens/constants.dart';


class RequestedBooks extends StatefulWidget {
  RequestedBooks({Key? key}) : super(key: key);

  @override
  _RequestedBooks createState() => _RequestedBooks();
}

class _RequestedBooks extends State<RequestedBooks> {
  User? user = FirebaseAuth.instance.currentUser;
  var uemail;
  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    uemail = user!.email;

    Widget reqBooksList = StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("books")
            .where("requestedBy.buyeremail", isEqualTo: uemail)
            .where("confirmed", isEqualTo: "No")
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
                var reqbook = snapshot.data.docs[index];
                return Card(
                  //height: 100,
                  child: ListTile(
                      contentPadding: EdgeInsets.all(5),
                      minVerticalPadding: 5,
                      tileColor: Colors.orange[100],
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RequestedBookDetail(
                                    bookid:
                                    snapshot.data.docs[index].get("bookid"),
                                    declined: "No")));
                      },
                      leading: Container(
                        height: 100,
                        width: 60,
                        child: Image.network(
                          (reqbook["bookurl"] == "")
                              ? noimg
                              : reqbook["bookurl"],
                          fit: BoxFit.fill,
                        ),
                      ),
                      trailing: Text(""),
                      title: Text(
                        reqbook["name"],
                        style: TextStyle(),
                      ),
                      subtitle: Text(
                        "Rs. " + snapshot.data.docs[index].get("price"),
                        style: TextStyle(color: Colors.redAccent),
                      )),
                );
              });
        });
    Widget decBooksList = StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("books")
            .where("requestedBy.declined", arrayContains: uemail)
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
                var reqbook = snapshot.data.docs[index];
                return Card(
                  //height: 100,
                  child: ListTile(
                      contentPadding: EdgeInsets.all(5),
                      minVerticalPadding: 5,
                      tileColor: Colors.red[100],
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RequestedBookDetail(
                                    bookid:
                                    snapshot.data.docs[index].get("bookid"),
                                    declined: "Yes")));
                      },
                      leading: Container(
                        height: 100,
                        width: 60,
                        child: Image.network(
                          (reqbook["bookurl"] == "")
                              ? noimg
                              : reqbook["bookurl"],
                          fit: BoxFit.fill,
                        ),
                      ),
                      trailing: Text(""),
                      title: Text(
                        reqbook["name"],
                        style: TextStyle(),
                      ),
                      subtitle: Text(
                        "Rs. " + snapshot.data.docs[index].get("price"),
                        style: TextStyle(color: Colors.redAccent),
                      )),
                );
              });
        });

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: Column(
            children: [
              TabBar(
                indicatorColor: Colors.blueAccent,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black45,
                padding: EdgeInsets.fromLTRB(0,15,0,5),
                tabs: [
                  Text(
                    "My Requests",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Declined",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Center(child: reqBooksList),
                    Center(child: decBooksList),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

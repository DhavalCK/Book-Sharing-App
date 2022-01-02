import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/Model/BookShareModel.dart';
import 'RequestedBookDetail.dart';
import 'package:myapp/Screens/constants.dart';
import 'package:myapp/Screens/MyBooksPage/AddedBookDetail.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'AddBook.dart';

class AddedBooks extends StatefulWidget {
  const AddedBooks({Key? key}) : super(key: key);

  @override
  _AddedBooksState createState() => _AddedBooksState();
}

class _AddedBooksState extends State<AddedBooks> {
  User? user = FirebaseAuth.instance.currentUser;
  var uemail;
  var book;
  var buyer;
  var pendingtype = "All";
  Stream<dynamic>? query = null;


  void refresh() {
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    uemail = user!.email;

    Widget PendingBooksList =
    Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical:5,horizontal: 10),
          child: DropdownButtonFormField<String>(
              value: pendingtype,
              // alignment: AlignmentDirectional.centerEnd,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                ),
              onChanged: (String? value) {
                setState((){
                  pendingtype = value!;
                  if(value == "All") {
                    query = FirebaseFirestore.instance
                        .collection("books")
                        .where("confirmed", isEqualTo: "No")
                        .where("useremail", isEqualTo: user!.email)
                        .snapshots();
                  }
                  else if(value == "Pending"){
                    query = FirebaseFirestore.instance
                        .collection("books")
                        .where("isRequested", isEqualTo: "No")
                        .where("useremail", isEqualTo: user!.email)
                        .snapshots();
                  }
                  else{
                    query = FirebaseFirestore.instance
                        .collection("books")
                        .where("isRequested", isEqualTo: "Yes")
                        .where("confirmed", isEqualTo: "No")
                        .where("useremail", isEqualTo: user!.email)
                        .snapshots();
                  }
                  refresh();
                });
              },
              items: <String>["All", "Pending", "Get Request"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value));
              }).toList(),
            ),
        ),

         StreamBuilder(
            stream: (query==null)
                ?FirebaseFirestore.instance
                .collection("books")
                .where("confirmed", isEqualTo: "No")
                .where("useremail", isEqualTo: user!.email)
                .snapshots()
                :query,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              //buyer = snapshot.data.docs[0];
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Expanded(
                child: ListView.builder(
                      itemCount: snapshot.data.size,
                      padding: EdgeInsets.all(5),
                      itemBuilder: (context, index) {
                        book = snapshot.data.docs[index];
                        //return Container
                        return Card(
                          //height: 100,
                          child: ListTile(
                              contentPadding: EdgeInsets.all(5),
                              minVerticalPadding: 5,
                              tileColor: Colors.yellow[100],
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddedBookDetail(bookid: snapshot.data.docs[index].get("bookid"))));
                              },
                              leading: Container(
                                height: 100,
                                width: 60,
                                child: Image.network(
                                  (snapshot.data.docs[index].get("bookurl")=="")
                                      ?noimg
                                      :
                                  snapshot.data.docs[index].get("bookurl"),
                                  fit: BoxFit.fill,
                                ),
                              ),

                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  (book["isRequested"]=="No")
                                      ? SizedBox(height: 20)
                                      :
                                  Icon(Icons.ac_unit,
                                  color:Colors.green),

                                  IconButton(
                                    icon: Icon(Icons.delete,),
                                    iconSize: 30,
                                    color: Colors.red,
                                    onPressed: (){
                                      showDialog(context: context, builder:(BuildContext context) => AlertDialog(
                                        title: Text("Delete Book!!!",style: TextStyle(color:Colors.red),),
                                        content: Text('Are sure want to delete this Book ?',style: TextStyle(color:Colors.red[200]),),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context,rootNavigator: true).pop();
                                              },
                                              child: Text("No")
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                deleteBook(snapshot.data.docs[index].get("bookid"));
                                                Navigator.of(context,rootNavigator: true).pop();
                                              },
                                              child: Text("Yes")
                                          ),
                                        ],
                                      )
                                      );
                                    },
                                  ),
                                ],
                              ),
                              title: Text(
                                snapshot.data.docs[index].get("name"),
                                style: TextStyle(),
                              ),
                              subtitle: Text(
                                "Rs. " + snapshot.data.docs[index].get("price"),
                                style: TextStyle(color: Colors.redAccent),
                              )),
                        );
                      }),
              );
            }),
      ],
    );

    Widget SoldBooksList = StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("books")
        .where("confirmed", isEqualTo: "Yes")
            .where("useremail", isEqualTo: user!.email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot2) {
          if (!snapshot2.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              itemCount: snapshot2.data.size,
              padding: EdgeInsets.all(5),
              itemBuilder: (context, index) {
                book = snapshot2.data.docs[index];
                //return Container
                return Card(
                  //height: 100,
                  child: ListTile(
                      contentPadding: EdgeInsets.all(5),
                      minVerticalPadding: 5,
                      tileColor: Colors.yellow[100],
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddedBookDetail(bookid: snapshot2.data.docs[index].get("bookid"))));
                      },
                      leading: Container(
                        height: 100,
                        width: 60,
                        child: Image.network(
                          (snapshot2.data.docs[index].get("bookurl")=="")
                              ?noimg
                              :
                          snapshot2.data.docs[index].get("bookurl"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      title: Text(
                        snapshot2.data.docs[index].get("name"),
                        style: TextStyle(),
                      ),
                      subtitle: Text(
                        "Rs. " + snapshot2.data.docs[index].get("price"),
                        style: TextStyle(color: Colors.redAccent),
                      )),
                );
              });
        }
    );

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
                    "Pending Books",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Sold Books",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Center(child: PendingBooksList),
                    Center(child: SoldBooksList),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddBook()));
              }),

        ));
  }
}

deleteBook(String bid) async {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  final uemail = user!.email;

  await firebaseFirestore
      .collection("books")
      .doc(bid)
      .delete();
  Fluttertoast.showToast(msg: "Book Deleted Succesfully");
}


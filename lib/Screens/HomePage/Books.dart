//import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Category.dart';
import 'DetailPage.dart';
import 'package:myapp/Screens/constants.dart';
import 'package:myapp/Screens/SearchPage/Search.dart';

class Books extends StatefulWidget {
  Books({Key? key, required this.ctgname}) : super(key: key);
  final String ctgname;

  @override
  _Books createState() => _Books();
}

class _Books extends State<Books> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    print(widget.ctgname.runtimeType);
    return StreamBuilder(
          stream: FirebaseFirestore.instance.collection("books")
              .where("ctgs",arrayContains: widget.ctgname)
               .where("isRequested",isEqualTo: "No")
               .where("useremail",isNotEqualTo: user!.email)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            int length = snapshot.data.size;
            return Scaffold(
                body: SafeArea(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //Top bar
                      Row(children: <Widget>[
                        //Category Name
                        Container(
                            margin: EdgeInsets.fromLTRB(20,5,10,10),
                            width: 300,
                            height: 50,
                            child: TextButton(
                              child: Text(
                                widget.ctgname,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ),
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.lightBlueAccent),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => Category()));
                              },
                            )),
                        //search button
                        IconButton(
                            padding: EdgeInsets.fromLTRB(0,0,0,5),
                            alignment: Alignment.centerRight,
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => Search()));
                            },
                            iconSize: 35,
                            icon: new Icon(
                              Icons.search,
                              color: Colors.black,
                            )),
                        //Filter Icon
                        // IconButton(
                        //     padding: EdgeInsets.fromLTRB(0,0,0,5),
                        //     alignment: Alignment.centerRight,
                        //     onPressed: () => null,
                        //     iconSize: 35,
                        //     icon: new Icon(
                        //       Icons.settings_suggest,
                        //       color: Colors.black,
                        //     ))
                      ]),

                      Expanded(
                        child:
                        Container(
                          child: CustomScrollView(
                            primary: false,
                            slivers: [
                              SliverPadding(
                                //Paddinng Of Scroll Bar
                                padding: EdgeInsets.only(left: 15, right: 15),
                                sliver: SliverGrid.count(
                                    crossAxisCount: 2,
                                    children: List.generate(length, (index) {
                                      print(length);
                                      var book = snapshot.data.docs[index];
                                      print(book);
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 5),
                                        child: BookCard(bid: book.get("bookid"),
                                            bname: book.get("name"),
                                            bimg: book.get("bookurl"),
                                            brs: book.get("price")),
                                      );

                                    })),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
          }
      );
    
  }
}

class BookCard extends StatelessWidget {
  var bid,bname,bimg,brs;
  BookCard({Key? key, this.bid,this.bname,this.bimg,this.brs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(10),
      child: new InkResponse(
        //onclick to book
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailPage(bookid: bid)));
        },

        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(children: [
            //image of book
            Container(
                  height: 98,
                  width: 80,
                  child :Image.network((bimg=="")
                      ?noimg
                      :bimg,fit: BoxFit.fill,
                  )
              ),

            //Book title
            Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  bname,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: 15),
                )),
            Text("Rs."+brs,
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
            )
          ]),
        ),
      ),
      shadowColor: Colors.black,
    );
  }
}

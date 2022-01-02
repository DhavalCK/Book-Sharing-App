import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Screens/constants.dart';
import 'package:myapp/Screens/HomePage/DetailPage.dart';

class Search1 extends StatefulWidget {
  Search1({Key? key}) : super(key: key);

  @override
  _Search createState() => _Search();
}

class _Search extends State<Search1> {
  User? user = FirebaseAuth.instance.currentUser;
  static var str = "";

  //List<Future<QuerySnapshot<Map<String,dynamic>>>> streams = [];
  @override
  void initState(){
    // FirebaseFirestore.instance.collection("books")
    //      .where("useremail",isNotEqualTo: user!.email)
    //      .get()
    //     .then((value){
    //     });
    // streams.add(firstQuery);
    super.initState();
  }

  void search(){
    setState((){});
  }

  final searchBookBar = Container(
      width:330,
      margin: EdgeInsets.fromLTRB(10, 10, 0, 5),
      child :TextField(
          onChanged: (value){
            str = value;
          },
          onSubmitted: (value){
            str = value;
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Type book name here...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          )));

  @override
  Widget build(BuildContext context) {
    var uemail = user!.email;
    return StreamBuilder(
      //same name
      //.where("useremail",isNotEqualTo: uemail)
      //         .where("name",isEqualTo: str)
      // .where("useremail",isNotEqualTo: user!.email)
      // .orderBy("useremail")
      // .orderBy("name")
      // .startAt([str])
      // .endAt([str + '\uf8ff'])

        stream:
        FirebaseFirestore.instance.collection("books")
        //.where("name",isEqualTo: str.toUpperCase())
        //    .orderBy("useremail")
            .orderBy("name")
         //   .where("useremail",isNotEqualTo: uemail)
            .startAt([str.toUpperCase()])
            .endAt([str.toUpperCase() + '\uf8ff'])
            .snapshots()
        ,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          int length = snapshot.data.size;
          // print(ref.map((event) => print(event)));
          return Scaffold(
              body: SafeArea(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        searchBookBar,
                        IconButton(onPressed: search, icon: Icon(Icons.search),iconSize: 35),
                      ],
                    ),
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
                                    var book = snapshot.data.docs[index];
                                    //          print(book.get("name"));

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
                  builder: (context) => DetailPage(bookid:bid)));
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

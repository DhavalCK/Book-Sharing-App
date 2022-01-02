import 'package:flutter/material.dart';
import 'Books.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Category extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () => Navigator.of(context).pop(null),
                icon: new Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
            title: Text("Category"),
            centerTitle: true,
            titleSpacing: 5,
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("categories").orderBy("name").snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              //var ctg = snapshot.data.docs;
              int length = snapshot.data.size.toInt();
              return CustomScrollView(
                primary: false,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(5),
                    sliver: SliverGrid.count(
                        crossAxisCount: 3,
                        children: List.generate(length, (index) {
                          var ctg = snapshot.data.docs[index];
                          return Container(
                            child: CtgCard(cid: ctg.get("id"),cname: ctg.get("name"),cimg: ctg.get("imgUrl")),
                          );
                        })),
                  )
                ],
              );
            },
          ),
        )
    );
  }
}

class CtgCard extends StatelessWidget {
  var cid,cname,cimg;
  CtgCard({Key? key, this.cid,this.cname,this.cimg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        margin: EdgeInsets.all(10),
        child: new InkResponse(
          //onclick to category
          onTap: () {
            //print(ctg);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Books(ctgname: cname)));
          },

          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: [
              //image of category icon
              Container(
                  height: 55,
                  width: 75,
                  child :Image.network(cimg,height: 50,fit: BoxFit.fill,)
              ),

              //category name
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    cname,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(fontSize: 14),
                  ))
            ]),
          ),
        ));
  }
}
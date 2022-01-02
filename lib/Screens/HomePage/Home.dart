import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'Books.dart';
import 'Category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("categories").orderBy("name").snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              var size = MediaQuery.of(context).size;
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                children: <Widget>[
                  //Good Thoughs about Book Slider
                  CarouselSlider(
                        items: [
                          //Image 1
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 20, 10, 30),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: AssetImage("assets/Thoughts/thought1.jpg"),
                                  fit: BoxFit.fill,
                                )),
                          ),
                          //Image 2
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 20, 10, 30),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: AssetImage("assets/Thoughts/thought2.jpg"),
                                  fit: BoxFit.fill,
                                )),
                          ),
                          //Image 3
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 20, 10, 30),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: AssetImage("assets/Thoughts/thought3.jpg"),
                                  fit: BoxFit.fill,
                                )),
                          )
                        ],
                        options: CarouselOptions(
                          //height: 250,
                            height: (size.height)*0.34,
                            autoPlay: true,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            autoPlayAnimationDuration: Duration(milliseconds: 5000))
                  ),
                  //Categories Text Widget
                  Text(
                    "Categories",
                    textAlign: TextAlign.right,
                    style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.w400, shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(1, 2),
                        blurRadius: 5,
                      )
                    ]),
                  ),


                  //Category GridView Widget
                  GridView.count(
                      padding: EdgeInsets.all(5),
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      children: List.generate(9, (index) {
                        var ctg = snapshot.data.docs[index];
                        //when index 8 show more icon photo else show ctg photo
                        if(index==8){
                          return Container(
                            child: CtgCard(cid: 0,cname: "More",cimg: "https://firebasestorage.googleapis.com/v0/b/booksharing-7467c.appspot.com/o/category_pics%2Fmore.png?alt=media&token=86fc2e26-82bb-4d0b-ab68-edb80dbbebde"),
                          );
                        }
                        return Container(
                          child: CtgCard(cid: ctg.get("id"), cname: ctg.get("name"), cimg: ctg.get("imgUrl")),
                        );

                      }))
                ],
              );
            }
        ),
      ),
    );
  }
}

class CtgCard extends StatelessWidget {
  var cid,cname,cimg;
  CtgCard({Key? key,this.cid,this.cname,this.cimg}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        margin: EdgeInsets.all(10),
        child: new InkResponse(
          //onclick to category
          onTap: () {
            //print(ctg);
            if (cname == "More") {
              Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context) => Category()));
            } else {
              //passing parameter as category name
              Navigator.push(
                  context, MaterialPageRoute(
                      builder: (context) => Books(ctgname: cname)));
            }
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
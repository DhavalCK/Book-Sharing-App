import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'EditBookDetails.dart';
import 'package:myapp/Screens/constants.dart';
import 'package:myapp/Model/BookShareModel.dart';
import 'package:intl/intl.dart';

class AddedBookDetail extends StatefulWidget {
  final bookid;
  AddedBookDetail({Key? key,required this.bookid}) : super(key: key);

  @override
  _AddedBookDetail createState() => _AddedBookDetail();
}

class _AddedBookDetail extends State<AddedBookDetail> {
  User? user = FirebaseAuth.instance.currentUser;
  late var book,buyer,rent_month;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    //decline Request Dialog Widget when user clicked on Decline request button
    final declineRequestDialog =
    AlertDialog(
      title: Text("Decline Request"),
      content: Text('Are sure want to decline this Request ?'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context,rootNavigator: true).pop();
            },
            child: Text("No")
        ),
        TextButton(
            onPressed: () {
              //calling cancelRequest Function
                declineRequest(book["bookid"],buyer["email"]);
               Navigator.of(context,rootNavigator: true).pop();
            },
            child: Text("Yes")
        ),
      ],
    );

    //accept Request Dialog Widget when user clicked on Accept request button
    final acceptRequestDialog = AlertDialog(
      title: Text("Accept Request"),
      content: Text('Are sure want to accept this Request ?'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context,rootNavigator: true).pop();
            },
            child: Text("No")
        ),
        TextButton(
            onPressed: () {
              //calling acceptRequest Function
              acceptRequest(book["bookid"],buyer["email"]);
              Navigator.of(context,rootNavigator: true).pop();
            },
            child: Text("Yes")
        ),
      ],
    );

    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("books").doc(widget.bookid).snapshots(),
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
                    child: Column(
                        children: <Widget>[
                          //top bar and image
                          Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin:Alignment.topLeft,
                                  end:Alignment.bottomRight,
                                  colors: [Colors.yellow,Colors.white,Colors.yellow])
                            ),
                            child: Column(
                              children: [
                                //top bar
                                Row(
                                  children: [
                                    //back screen icon
                                    Container(
                                        alignment: Alignment.topLeft,
                                        child: IconButton(
                                            onPressed: () => Navigator.of(context).pop(null),
                                            icon: new Icon(
                                              Icons.arrow_back,
                                              color: Colors.black,
                                            ),)
                                    ),
                                    Spacer(),
                                    (book["confirmed"]=="Yes")
                                        ?SizedBox.shrink()
                                    ://Edit Button
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: OutlinedButton(
                                        child: Text(
                                          "Edit",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.deepPurple,
                                              fontSize: 20),
                                        ),onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => EditBook(bookid: book["bookid"])));
                                      },
                                      ),
                                    ),

                                  ],
                                ),
                                // image of book
                                Container(
                                  height: height*0.3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Image.network(
                                          (book["bookurl"]=="")
                                              ?noimg
                                              :book["bookurl"],fit: BoxFit.fill,)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color:Colors.black,height: 0,),
                          //book details
                          Container(
                            child: Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 10,),
                                  //book title
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      book["name"],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
          //                        Text(book["bookid"]),
                                  TextBox(heading: "Author :",value: book["author"]),
                                  TextBox(heading: "Category :",value: book["ctgs"].toString().replaceAll("[","").replaceAll("]","")),
                                  TextBox(heading: "Publisher :",value: book["publisher"]),
                                  TextBox(heading: "Edition :",value: book["edition"]),
                                  TextBox(heading: "Description :",value: book["desc"]),
                                  TextBox(heading: "Type :",value: book["type"]),
                                  TextBox(heading: "Isbn :",value: book["isbn"]),
                                  TextBox(heading: "Price :",value: book["price"]),
                                ],
                              ),
                            ),
                          ),
                          Divider(color:Colors.black),

                          (book["isRequested"]=="No")
                              ? SizedBox(height: 20)
                          :
                          //if any buyer send request user details and show accept and decline button
                          Column(
                            children:[
                              //user details
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance.collection("users")
                                      .where("email",isEqualTo: book["requestedBy.buyeremail"]).snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot snapshot2) {
                                    if(snapshot2.data == null) return CircularProgressIndicator();
                                    buyer = snapshot2.data.docs[0];
                                    return Column(
                                      children: [
                                        //title of buyer details
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5),
                                          child: Text(
                                            (book["confirmed"]=="No")?
                                            "Buyer Details":"Sold To Buyer",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        TextBox(heading: "Name :",value: buyer["name"]),
                                        TextBox(heading: "Email :",value: buyer["email"]),
                                        TextBox(heading: "Contact :",value: buyer["contact"]),
                                        TextBox(heading: "Address :",value: buyer["address"]
                                            +", "+buyer["city"] +", "+buyer["state"]+", "
                                            +buyer["country"]),
                                        (book["type"]=="On Rent")?
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    width: 150,
                                                    child: Text(
                                                        "No of Month : ",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight
                                                                .bold),
                                                        textAlign: TextAlign
                                                            .right
                                                    )
                                                ),
                                                SizedBox(width: 10),
                                                Text(book["rentMonth"]+ " (For Rent)",
                                                  style: TextStyle(
                                                      fontSize: 16),),

                                              ],
                                            ),
                                          ):
                                    SizedBox(height: 0),
                                        Divider(height: 0),
                                        SizedBox(height: 20),

                                      ],
                                    );
                                  }
                              ),
                              (book["confirmed"]=="No")?
                              //accept and decline button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  OutlinedButton.icon(
                                      onPressed: () {
                                        showDialog(context: context, builder:(BuildContext context) => declineRequestDialog);
                                      },
                                      icon:Icon(Icons.cancel_outlined,size: 25, color: Colors.white),
                                      label: Text("Decline",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10,horizontal: 20)))),
                                  OutlinedButton.icon(
                                      onPressed: () {
                                        showDialog(context: context, builder:(BuildContext context) => acceptRequestDialog);
                                      },
                                      icon:Icon(Icons.done_outline,size: 25, color: Colors.white),
                                      label: Text("Accept",
                                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(Colors.greenAccent[400]),
                                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10,horizontal: 20)))),

                                ],
                              )
                              :
                              SizedBox(height: 0),
                              SizedBox(height: 30)
                            ]
                          ),

                       ]),
                  )));
        }
    );
  }

  //Decline Request to the Buyer
  declineRequest(String bid,String buyeremail) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    // User? user = FirebaseAuth.instance.currentUser;
    // final uemail = user!.email;

    await firebaseFirestore
        .collection("books")
        .doc(bid)
        .update({"isRequested": "No",
      "requestedBy.declined": FieldValue.arrayUnion([buyeremail]),
      "requestedBy.buyeremail":""});
    Fluttertoast.showToast(msg: "Request Declined Succesfully");
    Navigator.of(context).pop();
  }
  //accept Request to the Buyer
  acceptRequest(String bid,String buyeremail) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
     User? user = FirebaseAuth.instance.currentUser;
     final uemail = user!.email;

    await firebaseFirestore
        .collection("books")
        .doc(bid)
        .update({"confirmed": "Yes","requestedBy.accepted": buyeremail});

    BookShareModel bsModel = BookShareModel();
    bsModel.sellerid = uemail;
    bsModel.buyerid = buyeremail;
    bsModel.bookid = bid;
    var Date = DateTime.now();
    String nowdate = DateFormat("yyyy-MM-dd").format(Date);
    bsModel.date = nowdate;

     if(book["type"]=="On Rent"){
       var newdate = new DateTime(Date.year,Date.month+(int.parse(book["rentMonth"])),Date.day);
       bsModel.duedate = DateFormat("yyyy-MM-dd").format(newdate);
     }

    //insert detail in bookshare collection
    await firebaseFirestore.collection("bookshare").add(bsModel.toMap());

    Fluttertoast.showToast(msg: "Request Accepted Succesfully");
    Navigator.of(context).pop();
  }
}

class TextBox extends StatelessWidget {
  var heading,value;
  TextBox({Key? key, this.heading,this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 110,
              child: Text(
                  heading,
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right
              )
          ),
          SizedBox(width: 10),
          Flexible(child: (value=="")
              ?Text("-",style: TextStyle(fontSize: 16),)
              :Text(value,style: TextStyle(fontSize: 16),))
        ],
      ),
    );
  }
}

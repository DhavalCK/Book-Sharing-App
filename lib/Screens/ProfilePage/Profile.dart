import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Screens/Login.dart';
import 'EditProfileDetail.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    final logoutDialog = AlertDialog(
        title: Text("Logout!!!"),
        content: Text('Are sure want to LOGOUT ?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("No")),
          TextButton(
              onPressed: () {
                logout(context);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("Yes")),
        ]
    );

    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").doc(user!.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          var user = snapshot.data;
          return Scaffold(
              body: SafeArea(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                          children: <Widget>[
                            SizedBox(height: 40),
                            CircleAvatar(
                              radius: 90,
                              backgroundImage: NetworkImage(
                                  (user["profileurl"]=="")
                                  ?"https://firebasestorage.googleapis.com/v0/b/booksharing-7467c.appspot.com/o/blank-profile-picture-973460_1280.png?alt=media&token=6d7eb49a-e7e9-4354-ba8c-13c8b6dbac43"
                                  :user["profileurl"]),
                            ),
                            Container(
                              child: Center(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      child: Text(
                                        user["name"],
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    TextBox(heading: "Email :",value: user["email"]),
                                    TextBox(heading: "Contact No. :",value: user["contact"]),
                                    TextBox(heading: "Adress :",value: user["address"] + ", " +
                                        user["city"] +", "+user["state"] +", "+user["country"]),

                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            MaterialButton(
                              minWidth: 300,
                              height: 60,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProfileDetail(id: user["uid"])));
                              },
                              color: Colors.orange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              child: Text(
                                "Edit",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22),
                              ),
                            ),
                            SizedBox(height: 30),

                            //logout button
                            MaterialButton(
                              minWidth: 300,
                              height: 60,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (
                                        BuildContext context) =>
                                    logoutDialog
                                );

                              },
                              color: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              child: Wrap(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    size: 30,
                                  color: Colors.white),
                                  SizedBox(width: 20),
                                  Text(
                                    "Logout",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ),
                  )));
        }
    );
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

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()));
}

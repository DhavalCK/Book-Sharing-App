import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:path/path.dart'as Path;

class EditProfileDetail extends StatefulWidget {
  var id;

  EditProfileDetail({Key? key,required this.id}) : super(key: key);

  @override
  _EditProfileDetailState createState() => _EditProfileDetailState();
}

class _EditProfileDetailState extends State<EditProfileDetail> {
  final _formKey = GlobalKey<FormState>();
  final nameEditingController = new TextEditingController();
  final contactEditingController = new TextEditingController();
  final addressEditingController = new TextEditingController();
  final emailEditingController = new TextEditingController();
  static String profileurl = "";
  static String countryValue = "";
  static String stateValue = "";
  static String cityValue = "";
  var user;

  @override
  void initState() {
    _getThingsOnStartUp().then((value){
      print("Async Done");

      nameEditingController.text = user["name"];
      addressEditingController.text=user["address"];
      contactEditingController.text=user["contact"];

      countryValue = user["country"];

      stateValue = user["state"];
      cityValue = user["city"];
      profileurl = user["profileurl"];

      setState((){});
    });
    super.initState();
  }

  final picker = ImagePicker();
  File _image = File("");

  Future _getThingsOnStartUp() async {
    await Future.delayed(Duration(seconds: 1));
  }
  @override
  Widget build(BuildContext context) {
    Future chooseImage() async{
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState((){
        _image = File(pickedFile!.path);
      });
    }
    Future uploadFile() async {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('profilephotos/${Path.basename(_image.path)}');
      firebase_storage.UploadTask task = ref.putFile(_image);
      task.whenComplete(() async {
        print("File Uploaded");
        await ref.getDownloadURL().then((fileURL){
          setState(() {
            profileurl = fileURL;
          });
        });
      });
    }

    final NameField = TextFormField(
        autofocus: false,
        controller: nameEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Name cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid name(Min. 3 Character)");
          }
          return null;
        },
        onSaved: (value) {
          nameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));


    //State And City
    final stateCity = Container(
        padding: EdgeInsets.symmetric(horizontal: 0),
        height: 94,
        child: Column(
          children: [
            ///Adding CSC Picker Widget in app
            CSCPicker(
              ///Enable (get flag with country name) / Disable (Disable flag) / ShowInDropdownOnly (display flag in dropdown only) [OPTIONAL PARAMETER]
              flagState: CountryFlag.DISABLE,

              ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
              dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white,
                  border:
                  Border.all(color: Colors.grey.shade500, width: 1)),

              ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
              disabledDropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.grey.shade300,
                  border:
                  Border.all(color: Colors.grey.shade500, width: 1)),

              selectedItemStyle: TextStyle(fontSize: 16),
              dropdownItemStyle: TextStyle(),
              ///placeholders for dropdown search field
              countrySearchPlaceholder: "Search Country",
              stateSearchPlaceholder: "Search State",
              citySearchPlaceholder: "Search City",

              ///labels for dropdown
              countryDropdownLabel: "Select Country",
              stateDropdownLabel: "Select State",
              cityDropdownLabel: "Select City",

              ///Default Country
              //defaultCountry: DefaultCountry.India,

              currentCountry: countryValue,
              currentState: stateValue,
              currentCity: cityValue,
              ///Disable country dropdown (Note: use it with default country)
              //disableCountry: true,

              ///triggers once country selected in dropdown
              onCountryChanged: (value) {
                setState(() {
                  ///store value in country variable
                  countryValue = value.toString();
                });
              },

              ///triggers once state selected in dropdown
              onStateChanged: (value) {
                setState(() {
                  ///store value in state variable
                  stateValue = value.toString();
                });
              },

              ///triggers once city selected in dropdown
              onCityChanged: (value) {
                setState(() {
                  ///store value in city variable
                  cityValue = value.toString();
                });
              },
            ),
          ],
        ));

    final AddressField = TextFormField(
        autofocus: false,
        controller: addressEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          if(value!.isEmpty){
            return "Address Must be filled";
          }
        },
        onSaved: (value) {
          addressEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.home),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Address",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final contactField = TextFormField(
        autofocus: false,
        controller: contactEditingController,
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter Your Contact Number");
          }
          if(!RegExp(r'^[0-9]{10}').hasMatch(value)){
            return ("Contact Number must have 10 digits");
          }
          return null;
        },
        onSaved: (value) {
          contactEditingController.text = value.toString();
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Contact Number",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final updateDialog = AlertDialog(
        title: Text("Update Profile"),
        content: Text('Are sure want to update your profile ?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("No")),
          TextButton(
              onPressed: () {
                update();
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("Yes")),
        ]
    );

    final updateButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.indigoAccent,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            showDialog(
                context: context,
                builder: (
                    BuildContext context) =>
                updateDialog
            );

            //  updateBook();
          },
          child: Text(
            "Update Profile",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(70,0,0,0),
          child: Text("Edit Profile",style: TextStyle(color:Colors.white,fontSize: 24)),
        ),
        shadowColor: Colors.black,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<Object>(
        stream: FirebaseFirestore.instance.collection("users").doc(widget.id).snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            user = snapshot.data;
          return Center(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: (){
                            chooseImage().whenComplete(() => uploadFile());
                            },
                          child: CircleAvatar(
                            radius: 90,
                            backgroundImage: NetworkImage(
                                (profileurl=="")
                                    ?"https://firebasestorage.googleapis.com/v0/b/booksharing-7467c.appspot.com/o/blank-profile-picture-973460_1280.png?alt=media&token=6d7eb49a-e7e9-4354-ba8c-13c8b6dbac43"
                                    :profileurl),
                          ),
                        ),
                        SizedBox(height: 20),
                        NameField,
                        SizedBox(height: 20),
                        contactField,
                        SizedBox(height: 20),
                        stateCity,
                        SizedBox(height: 20),
                        AddressField,
                        SizedBox(height: 20),
                        updateButton,
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
  void update() async {
    if (_formKey.currentState!.validate()) {
      storeDetailsToFirestore();
    };
  }
  storeDetailsToFirestore() async {
    // calling our firestore
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    //update user details in user collection
    await firebaseFirestore
        .collection("users")
        .doc(widget.id)
        .update({
      "name":nameEditingController.text,
      "contact":contactEditingController.text,
      "address":addressEditingController.text,
      "country":countryValue,
      "state":stateValue,
      "city":cityValue,
      "profileurl":profileurl
    });
    Fluttertoast.showToast(msg: "Updated Profile Successfully.");
    Navigator.of(this.context).pop();

  }
}



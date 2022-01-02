import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:myapp/Model/UserModel.dart';
import 'package:myapp/Screens/HomeMainPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:email_auth/email_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;

  EmailAuth emailAuth = new EmailAuth(sessionName: "Signup Session");

  // our form key
  final _formKey = GlobalKey<FormState>();
  final _otpform = GlobalKey<FormState>();

  // editing Controller
  final NameEditingController = new TextEditingController();
  final AddressEditingController = new TextEditingController();
  final contactEditingController = new TextEditingController();
  final emailEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();
  final confirmPasswordEditingController = new TextEditingController();
  final otpEditingController = new TextEditingController();

  String countryValue = "";
  String stateValue = "";
  String cityValue = "";
  String address = "";
  static String _ProfilePhotoUrl = "";
  final picker = ImagePicker();
  File _image = File("");

  late Dialog otpDialog ;

  @override
  Widget build(BuildContext context) {
    //GlobalKey<CSCPickerState> _cscPickerKey = GlobalKey();

    //upload profile photo
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
            _ProfilePhotoUrl = fileURL;
          });
        });
      });
    }
    final UploadProfilePhoto = Row(
      children: [
        RaisedButton(
            child: Text("Upload Profile Photo"),
            onPressed: (){
              chooseImage().whenComplete(() => uploadFile());
            }
        ),

        Container(
            child: (_ProfilePhotoUrl!="")
                ?  Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(Icons.done,color: Colors.green,size: 40,),
            )
                :  Text("")
        ),
      ],
    );

    //name field
    final NameField = TextFormField(
        autofocus: false,
        controller: NameEditingController,
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
          NameEditingController.text = value!;
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
              defaultCountry: DefaultCountry.India,
              ///Disable country dropdown (Note: use it with default country)
              //disableCountry: true,

              ///triggers once country selected in dropdown
              onCountryChanged: (value) {
                setState(() {
                  ///store value in country variable
                  countryValue = value;
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

    //address field
    final AddressField = TextFormField(
        autofocus: false,
        controller: AddressEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          if(value!.isEmpty){
            return "Address Must be filled";
          }
        },
        onSaved: (value) {
          AddressEditingController.text = value!;
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

    //contact field
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
          NameEditingController.text = value.toString();
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

    //email field
    final emailField = TextFormField(
        autofocus: false,
        controller: emailEditingController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter Your Email");
          }
          // reg expression for email validation
          if (!RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]{2,3}$')
              .hasMatch(value)) {
            return ("Please Enter a valid email");
          }
          return null;
        },
        onSaved: (value) {
          NameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.mail),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //password field
    final passwordField = TextFormField(
        autofocus: false,
        controller: passwordEditingController,
        obscureText: true,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Password is required for login");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password(Min. 6 Character)");
          }
        },
        onSaved: (value) {
          NameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //confirm password field
    final confirmPasswordField = TextFormField(
        autofocus: false,
        controller: confirmPasswordEditingController,
        obscureText: true,
        validator: (value) {
          if (confirmPasswordEditingController.text !=
              passwordEditingController.text) {
            return "Password don't match";
          }
          return null;
        },
        onSaved: (value) {
          confirmPasswordEditingController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Confirm Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //otp field
    final otpField = TextFormField(
        autofocus: false,
        controller: otpEditingController,
        obscureText: true,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{6}$');
          if (value!.isEmpty) {
            return ("Otp is required for verification");
          }
          if (!regex.hasMatch(value)) {
            return ("Otp must be contain 6 Number");
          }
        },
        onSaved: (value) {
          otpEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Enter OTP",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //otp verify  button
    final otpVerifyButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.orange,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            verifyOtp(emailEditingController.text, passwordEditingController.text);
          },
          child: Text(
            "Verify",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    final otpForm = Form(
      key: _otpform,
      child: Container(
        height: 300,
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: Text("Enter OTP for Email Verification",style:TextStyle(
                  fontWeight: FontWeight.bold,
                ))
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: otpField,
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: otpVerifyButton,
            ),
          ],
        ),
      ),
    );

    //otp Dialog Box
    otpDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: otpForm,
    );

    //signup button
    final signUpButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.greenAccent,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            signUp(emailEditingController.text, passwordEditingController.text);
          },
          child: Text(
            "SignUp",
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
          child: Text("Sign Up",style: TextStyle(color:Colors.white,fontSize: 24)),
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
      body: Center(
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
                    UploadProfilePhoto,
                    SizedBox(height: 20),
                    NameField,
                    SizedBox(height: 20),
                    contactField,
                    SizedBox(height: 20),
                    stateCity,
                    SizedBox(height: 20),
                    AddressField,
                    SizedBox(height: 20),
                    emailField,
                    SizedBox(height: 20),
                    passwordField,
                    SizedBox(height: 20),
                    confirmPasswordField,
                    SizedBox(height: 20),
                    signUpButton,
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      sendOtp();
      showDialog(context: context, builder:(BuildContext context) => otpDialog);
    //   await _auth
    //       .createUserWithEmailAndPassword(email: email, password: password)
    //       .then((value) => {postDetailsToFirestore()})
    //       .catchError((e) {
    //     Fluttertoast.showToast(msg: e!.message);
    // });
  }
  }

  void sendOtp() async{
    //EmailAuth.sessionName = "Register Session";
    var res = await emailAuth.sendOtp(recipientMail: emailEditingController.text ,otpLength: 6);
  }

  void verifyOtp(String email, String password) async{
    var res = emailAuth.validateOtp(recipientMail: emailEditingController.text, userOtp: otpEditingController.text);
    if(res){
      //Navigator.of(context).pop();
      //email verfied then create account
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postDetailsToFirestore()})
          .catchError((e) {
        Fluttertoast.showToast(msg: e!.message);
      });
      Navigator.of(context).pop(otpDialog);

    }
    else{
      Fluttertoast.showToast(msg: "Enter Valid Otp");
    }
  }

  postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    // writing all the values
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.name = NameEditingController.text;
    userModel.contact = contactEditingController.text;
    userModel.profileurl = _ProfilePhotoUrl;
    userModel.country = countryValue;
    userModel.state = stateValue;
    userModel.city = cityValue;
    userModel.address = AddressEditingController.text;
    userModel.password = passwordEditingController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Account created successfully :) ");

    Navigator.pushAndRemoveUntil((context),
        MaterialPageRoute(builder: (context) => MyHomeMain()),
            (route) => false);
  }
}
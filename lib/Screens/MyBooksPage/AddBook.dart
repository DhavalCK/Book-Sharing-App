import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/Model/BookModel.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:multiselect/multiselect.dart';

import 'package:flutter_multiselect/flutter_multiselect.dart';
class AddBook extends StatefulWidget {
  AddBook({Key? key}) : super(key: key);

  @override
  _AddBook createState() => _AddBook();
}

class _AddBook extends State<AddBook> {

  // our form key
  final _formKey = GlobalKey<FormState>();

  // editing Controller
  final nameEditingController = new TextEditingController();
  final authorEditingController = new TextEditingController();
  final publisherEditingController = new TextEditingController();
  final editionEditingController = new TextEditingController();
  final descEditingController = new TextEditingController();
  final priceEditingController = new TextEditingController();
  final isbnEditingController = new TextEditingController();

 // static List ctgList = [];
//  late List categories;

  static List<String> ctgList = [];
  late List<String> categories;
  late String categoriesResult;
  late String type,category;

  static late bool isReadOnly;


  @override
  void initState() {
    super.initState();
    type = "";
    category = "";
    categories = [];
    categoriesResult = '';
    isReadOnly = false;
  }

  static String BookPhotoUrl = "";
  final picker = ImagePicker();
  File _image = File("");

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    var height = size.height;
    var width = size.width;

    //book name field
    final bookNameField = TextFormField(
        autofocus: false,
        controller: nameEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          //RegExp regex = new RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Book name cannot be Empty");
          }
          // if (!regex.hasMatch(value)) {
          //   return ("Enter Valid name(Min. 3 Character)");
          // }
          return null;
        },
        onSaved: (value) {
          nameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Book Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //description name field
    final descField = Container(
        width: 200,
        child: TextFormField(
            maxLines: 5,
            autofocus: false,
            controller: descEditingController,
            keyboardType: TextInputType.multiline,
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              descEditingController.text = value!;
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Description",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            )));

    //upload profile photo
    Future chooseImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = File(pickedFile!.path);
      });
    }
    Future uploadFile() async {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref().child('bookphotos/${Path.basename(_image.path)}');
      firebase_storage.UploadTask task = ref.putFile(_image);
      task.whenComplete(() async {
        print("File Uploaded");
        await ref.getDownloadURL().then((fileURL) {
          setState(() {
            BookPhotoUrl = fileURL;
          });
        });
      });
    }
    final UploadBookPhoto = Container(
        width: 110,
        height: 135,
        child: (BookPhotoUrl != "")
            ? RaisedButton(
            child: Image.network(BookPhotoUrl, width: 110, fit: BoxFit.fill,),
            onPressed: () {
              chooseImage().whenComplete(() => uploadFile());
            }
        )
            : RaisedButton(
            child: Icon(Icons.image, size: 75,),
            onPressed: () {
              chooseImage().whenComplete(() => uploadFile());
            }
        )
    );

    //author name field
    final authorNameField = TextFormField(
        autofocus: false,
        controller: authorEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Author name cannot be Empty");
          }
          return null;
        },
        onSaved: (value) {
          authorEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Author Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //create category list
    var ref = FirebaseFirestore.instance.collection("categories").orderBy(
        "name");
    ref.get().then((refsnapshot) {
      var len = refsnapshot.docs.length.toInt();
      ctgList = [];
      for (var i = 0; i < len; i++) {
        ctgList.add(refsnapshot.docs[i].get("name"));
      }
    });

    //category dropdown menu
    final categoryDropDown = DropDownMultiSelect(
      onChanged : (List<String> x){
        setState((){
          categories =x ;
        });
      },
      options : ctgList as List<String>,
      selectedValues: categories as List<String>,
      whenEmpty:'Select Categories',
    );

    //publisher name field
    final publisherNameField = TextFormField(
        autofocus: false,
        controller: publisherEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Publisher name cannot be Empty");
          }
          return null;
        },
        onSaved: (value) {
          publisherEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Publisher Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //edition name field
    final editionField = TextFormField(
        autofocus: false,
        controller: editionEditingController,
        keyboardType: TextInputType.number,
        validator: (value) {
          // if((int.tryParse(value!)) !< 0){
          //   return ("Year Can't be Negative");
          // }
          return null;
        },
        onSaved: (value) {
          editionEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Edition(year)",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //selling type field
    final typeDropDown = DropDownFormField(
      titleText: 'Type Of sell Book',
      hintText: 'Select Type',
      value: type,
      validator: (value){
        if(value==null){
          return "Please Select Type";
        }
        return null;
      },
      onSaved: (value) {
        setState(() {
          type = value;
        });
      },
      onChanged: (value) {
        setState(() {
          type = value;
          if(value=="Donate") {
            priceEditingController.text = "0";
            isReadOnly = true;
          }
          else{
            priceEditingController.text = "";
            isReadOnly = false;
          }
        });
      },
      dataSource: [
        {
          "display": "Sell",
          "value": "Sell",
        },
        {
          "display": "On Rent",
          "value": "On Rent",
        },
        {
          "display": "Donate",
          "value": "Donate",
        },
      ],
      textField: 'display',
      valueField: 'value',
    );

    //price name field
    final priceField = Container(

        width: (type=="On Rent")?190:260,
      child: TextFormField(
        readOnly: isReadOnly,
        autofocus: false,
        controller: priceEditingController,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Price cannot be Empty");
          }

          if((int.tryParse(value)) !< 0){
            return ("Price must be greater than 0");
          }
          return null;
        },
        onSaved: (value) {
          priceEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Price",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        )));

    final isbnField = TextFormField(
        autofocus: false,
        controller: isbnEditingController,
        keyboardType: TextInputType.number,
        validator: (value) {
          return null;
        },
        onSaved: (value) {
          isbnEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "ISBN Number",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //show dialog when click on Add Button
    // final addBookDialog = AlertDialog(
    //     title: Text("Add Book"),
    //     content: Text('Are sure want to add new Book ?'),
    //     actions: [
    //       TextButton(
    //           onPressed: () {
    //             Navigator.of(context, rootNavigator: true).pop();
    //           },
    //           child: Text("No")),
    //       TextButton(
    //           onPressed: () {
    //             //    addBook();
    //             Navigator.of(context, rootNavigator: true).pop();
    //           },
    //           child: Text("Yes")),
    //     ]
    // );
    //
    // showDialog(
    //     context: context,
    //     builder: (
    //         BuildContext context) =>
    //     addBookDialog);
    //

    //signup button
    final addBookButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.indigoAccent,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
              addBook();
          },
          child: Text(
            "Add Book",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(70,0,0,0),
          child: Text("Add Book",style: TextStyle(color:Colors.white,fontSize: 24)),
        ),
        backgroundColor: Colors.indigoAccent,
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
            color: Colors.white10,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    bookNameField,
                    SizedBox(height: 20),
                    Row(children:[descField , SizedBox(width: 10),UploadBookPhoto]),
                    SizedBox(height: 20),
                    authorNameField,
                    //SizedBox(height: 20),
                    categoryDropDown,
                    //SizedBox(height: 20),
                    publisherNameField,
                    SizedBox(height: 20),
                    editionField,
                    SizedBox(height: 20),
                    isbnField,
                    SizedBox(height: 20),
                    typeDropDown,
                    SizedBox(height: 20),
                    Row(children:[
                      priceField,
                      SizedBox(width: 10,),
                      (type=="On Rent")
                          ?Text("Rs. Per Month",style:TextStyle(fontSize: 16))
                          :Text("Rs.",style:TextStyle(fontSize: 16))
                    ]),
                    SizedBox(height: 20),
                    addBookButton,
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


  void addBook() async {
    //print(categories);
    if (_formKey.currentState!.validate()) {
      storeDetailsToFirestore();
    };

  }
  storeDetailsToFirestore() async {
    // calling our firestore

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    final uemail = user!.email;

    // calling our book model and bookshare
    BookModel bookModel = BookModel();
//    BookShareModel bsModel = BookShareModel();

    // writing all the values
    bookModel.name = nameEditingController.text.toUpperCase();
    bookModel.author = authorEditingController.text;
    bookModel.bookurl = BookPhotoUrl;
   // bookModel.ctg = category;
    bookModel.type = type;
    bookModel.publisher = publisherEditingController.text;
    bookModel.edition = editionEditingController.text;
    bookModel.price = priceEditingController.text;
    bookModel.desc = descEditingController.text;
    bookModel.isbn = isbnEditingController.text;
    bookModel.useremail = uemail;
    bookModel.isRequested = "No";
    bookModel.confirmed = "No";
    bookModel.requestedBy = {
      "buyeremail" : "",
      "accepted" : "",
      "declined" : []
    };
    bookModel.ctgs = categories;
    //late var tempbookid;

    //insert book details in book collection
    await firebaseFirestore
        .collection("books")
        .add(bookModel.toMap())
        .then((value){
      firebaseFirestore.collection("books").doc(value.id).update({"bookid":value.id});
      //tempbookid = value.id;
    });
    Fluttertoast.showToast(msg: "Book Posted successfully :) ");
    Navigator.of(context).pop();

    // bsModel.sellerid = uemail;
    // bsModel.status = "On Sell";
    // bsModel.bookid = tempbookid;
    //
    // //insert detail in bookshare collection
    // await firebaseFirestore.collection("bookshare").add(bsModel.toMap());

  }
}


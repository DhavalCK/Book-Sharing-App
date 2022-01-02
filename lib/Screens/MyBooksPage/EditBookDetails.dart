import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:multiselect/multiselect.dart';


class EditBook extends StatefulWidget {
  var bookid;
  EditBook({Key? key,required this.bookid}) : super(key: key);

  @override
  _EditBook createState() => _EditBook();
}

class _EditBook extends State<EditBook> {
  _EditBook();

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

  var book;
  static List<String> ctgList = [];
  static List<String> categories = [];
  String type = "";
  static late bool isReadOnly = false;

  @override
  void initState() {
    _getThingsOnStartUp().then((value){
      print("Async Done");

      nameEditingController.text = book["name"];
      authorEditingController.text = book["author"];
      publisherEditingController.text = book["publisher"];
      editionEditingController.text = book["edition"];
      descEditingController.text =book["desc"];
      priceEditingController.text = book["price"];
      isbnEditingController.text = book["isbn"];
      setState((){});
      BookPhotoUrl = book["bookurl"];
      type = book["type"];
      categories = List<String>.from(book["ctgs"]);
      if(book[type]=="Donate"){
        isReadOnly = true;
      }
      setState((){
      });
    });
    super.initState();
  }

  static String BookPhotoUrl = "";
  final picker = ImagePicker();
  File _image = File("");

  Future _getThingsOnStartUp() async {
    await Future.delayed(Duration(seconds: 1));
  }
  @override
  Widget build(BuildContext context) {
    //book name field
    final bookNameField = TextFormField(
        autofocus: false,
        controller: nameEditingController,
        keyboardType: TextInputType.name,

        validator: (value) {
          if (value!.isEmpty) {
            return ("Book name cannot be Empty");
          }
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
    //fetch category from firestoreand store into  ctgList
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
          categories = x ;
        });
      },
      options : ctgList as List<String>,
      selectedValues: categories,
      whenEmpty:'Select Categories',
    );

    //publisher name field
    final publisherNameField = TextFormField(
        autofocus: false,
        controller: publisherEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
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
    final updateBookDialog = AlertDialog(
        title: Text("Update Book"),
        content: Text('Are sure want to update this Book ?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("No")),
          TextButton(
              onPressed: () {
                updateBook();
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("Yes")),
        ]
    );

    //signup button
    final updateBookButton = Material(
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
                updateBookDialog
            );

          },
          child: Text(
            "Update",
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
          child: Text("Edit Book",style: TextStyle(color:Colors.white,fontSize: 24)),
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("books").doc(widget.bookid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          book = snapshot.data;

          return Center(
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
                        categoryDropDown,
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
                        updateBookButton,
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
  void updateBook() async {
    print(categories);
    if (_formKey.currentState!.validate()) {
      storeDetailsToFirestore();
    };
  }
  storeDetailsToFirestore() async {
    // calling our firestore

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    //update book details in book collection
    await firebaseFirestore
        .collection("books")
    .doc(widget.bookid)
    .update({
      "name":nameEditingController.text.toUpperCase(),
      "author":authorEditingController.text,
      "bookurl":BookPhotoUrl,
      "ctgs": categories,
      "type" :type,
      "publisher": publisherEditingController.text,
      "edition": editionEditingController.text,
      "price": priceEditingController.text,
      "desc": descEditingController.text,
      "isbn": isbnEditingController.text,
    });

        // .update(bookModel.toMap());
    Fluttertoast.showToast(msg: "Book Updated Successfully.");
    Navigator.of(context).pop();

  }
}


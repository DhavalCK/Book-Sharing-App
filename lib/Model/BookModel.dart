class BookModel {
  String? bookid;
  String? name;
  String? author;
  String? publisher;
  List? ctgs;
  String? bookurl;
  String? edition;
  String? desc;
  String? price;
  String? type;
  String? isbn;
  String? useremail;
  String? isRequested;
  String? confirmed;
  Map? requestedBy;

  BookModel({this.bookid, this.name, this.author, this.publisher,this.ctgs,this.bookurl, this.edition,
    this.desc, this.price, this.type, this.isbn ,this.useremail,this.isRequested,this.confirmed,this.requestedBy});

  // receiving data from server
  factory BookModel.fromMap(map) {
    return BookModel(
        bookid: map['bookid'],
        name: map['name'],
        author: map['author'],
        publisher: map['publisher'],
        ctgs: map['ctgs'],
        bookurl: map['bookurl'],
        edition: map['edition'],
        desc: map['desc'],
        price: map['price'],
        type: map['type'],
        isbn: map['isbn'],
        useremail: map['useremail'],
        isRequested: map['isRequested'],
        confirmed:map['confirmed'],
        requestedBy: map['requestedBy'],

    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'bookid': bookid,
      'name': name,
      'author': author,
      'publisher': publisher,
      'ctgs':ctgs,
      'bookurl': bookurl,
      'edition': edition,
      'desc': desc,
      'price': price,
      'type': type,
      'isbn': isbn,
      'useremail':useremail,
      'isRequested':isRequested,
      'confirmed':confirmed,
      'requestedBy':requestedBy,

    };
  }
}
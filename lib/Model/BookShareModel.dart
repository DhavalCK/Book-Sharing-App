class BookShareModel {
  String? sellerid;
  String? buyerid;
  String? bookid;
  String? date;
  String? duedate;

  BookShareModel({this.sellerid, this.buyerid, this.bookid,this.date,this.duedate});

  // receiving data from server
  factory BookShareModel.fromMap(map) {
    return BookShareModel(
        sellerid: map['sellerid'],
        buyerid: map['buyerid'],
        bookid: map['bookid'],
        date: map['date'],
        duedate: map['duedate'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'sellerid': sellerid,
      'buyerid': buyerid,
      'bookid': bookid,
      'date':date,
      'duedate': duedate,
    };
  }
}
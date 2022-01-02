class UserModel {
  String? uid;
  String? email;
  String? name;
  String? contact;
  String? profileurl;
  String? country;
  String? state;
  String? city;
  String? address;
  String? password;

  UserModel({this.uid, this.email, this.name, this.contact,this.profileurl,this.country,this.state,
    this.city,this.address,this.password});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
        uid: map['uid'],
        email: map['email'],
        name: map['name'],
        contact: map['contact'],
        profileurl: map['profileurl'],
        country: map['country'],
        state: map['state'],
        city: map['city'],
        address: map['address'],
        password: map['password']
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'contact':contact,
      'profileurl':profileurl,
      'country':country,
      'state':state,
      'city':city,
      'address': address,
      'password':password
    };
  }
}
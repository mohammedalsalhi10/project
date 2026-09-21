class AccountModel {
  final int? id;
  final String platformName; 
  final String username;     
  final String password;     

  AccountModel({
    this.id,
    required this.platformName,
    required this.username,
    required this.password,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'platformName': platformName,
      'username': username,
      'password': password,
    };
  }

  
  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      platformName: map['platformName'],
      username: map['username'],
      password: map['password'],
    );
  }
}
class RegisterParamsModel {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String? confirmPassword;
  final String carBrand;
  final String licensePlate;

  RegisterParamsModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    this.confirmPassword,
    required this.carBrand,
    required this.licensePlate,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'email': email,
    'password': password,
    'carBrand': carBrand,
    'licensePlate': licensePlate,
  };
}

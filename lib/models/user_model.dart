class UserModel {
  String userId; // Unique identifier for the user
  String name;
  String email;
  String experience;
  Set<String> skills;
  String resumeFileName;
  String resumeFilePath;
  String phoneNumber;
  String location;
  String summary;
  List<String> workExperience;
  List<String> education;
  String portfolioUrl;
  String githubUrl;
  String linkedinUrl;
  bool isGuest; // Whether this is a guest user
  String? authProvider; // 'google', 'email', etc.
  String? photoUrl; // Profile photo URL from Google

  UserModel({
    this.userId = '',
    this.name = '',
    this.email = '',
    this.experience = 'Entry-Level',
    Set<String>? skills,
    this.resumeFileName = '',
    this.resumeFilePath = '',
    this.phoneNumber = '',
    this.location = '',
    this.summary = '',
    List<String>? workExperience,
    List<String>? education,
    this.portfolioUrl = '',
    this.githubUrl = '',
    this.linkedinUrl = '',
    this.isGuest = false,
    this.authProvider,
    this.photoUrl,
  }) : skills = skills ?? <String>{},
       workExperience = workExperience ?? <String>[],
       education = education ?? <String>[]; // Fixed: Initializes a new mutable set
}
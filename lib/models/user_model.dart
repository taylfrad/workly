class UserModel {
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

  UserModel({
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
  }) : skills = skills ?? <String>{},
       workExperience = workExperience ?? <String>[],
       education = education ?? <String>[]; // Fixed: Initializes a new mutable set
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_tinder/themes/app_theme.dart';

import '../models/user_model.dart';
import '../services/file_upload_service.dart';
import '../services/user_storage_service.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'job_swipe_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserModel _user;
  final _skillsController = TextEditingController();
  final List<String> _experienceLevels = ['Entry-Level', 'Mid-Level', 'Senior'];

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _summaryController;
  late TextEditingController _portfolioController;
  late TextEditingController _githubController;
  late TextEditingController _linkedinController;

  bool _isUploadingResume = false;

  @override
  void initState() {
    super.initState();
    // Get user from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _user = authProvider.currentUser ?? UserModel();
    
    _nameController = TextEditingController(text: _user.name);
    _emailController = TextEditingController(text: _user.email);
    _phoneController = TextEditingController(text: _user.phoneNumber);
    _locationController = TextEditingController(text: _user.location);
    _summaryController = TextEditingController(text: _user.summary);
    _portfolioController = TextEditingController(text: _user.portfolioUrl);
    _githubController = TextEditingController(text: _user.githubUrl);
    _linkedinController = TextEditingController(text: _user.linkedinUrl);
    
  }

  @override
  void dispose() {
    _skillsController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _portfolioController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  void _addSkill() {
    if (_skillsController.text.trim().isNotEmpty) {
      setState(() {
        _user.skills.add(_skillsController.text.trim());
        _skillsController.clear();
      });
    }
  }

  Future<void> _uploadResume() async {
    if (_isUploadingResume) return;

    setState(() {
      _isUploadingResume = true;
    });

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Uploading and parsing resume...'),
            ],
          ),
        ),
      );

      // Pick and parse file (works on all platforms including web)
      final extractedData = await FileUploadService.pickAndParseResumeFile();
      
      if (extractedData != null) {
        
        // Update user model with extracted data
        setState(() {
          _user.resumeFilePath = 'uploaded_resume_${DateTime.now().millisecondsSinceEpoch}';
          _user.resumeFileName = extractedData['fileName'] ?? 'resume_uploaded.${extractedData['fileExtension'] ?? 'docx'}';
          
          
          // Update fields with extracted data if they're empty
          if (_user.name.isEmpty && extractedData['name'].toString().isNotEmpty) {
            _user.name = extractedData['name'];
            _nameController.text = _user.name;
          }
          if (_user.email.isEmpty && extractedData['email'].toString().isNotEmpty) {
            _user.email = extractedData['email'];
            _emailController.text = _user.email;
          }
          if (_user.phoneNumber.isEmpty && extractedData['phoneNumber'].toString().isNotEmpty) {
            _user.phoneNumber = extractedData['phoneNumber'];
            _phoneController.text = _user.phoneNumber;
          }
          if (_user.location.isEmpty && extractedData['location'].toString().isNotEmpty) {
            _user.location = extractedData['location'];
            _locationController.text = _user.location;
          }
          if (_user.summary.isEmpty && extractedData['summary'].toString().isNotEmpty) {
            _user.summary = extractedData['summary'];
            _summaryController.text = _user.summary;
          }
          if (_user.portfolioUrl.isEmpty && extractedData['portfolioUrl'].toString().isNotEmpty) {
            _user.portfolioUrl = extractedData['portfolioUrl'];
            _portfolioController.text = _user.portfolioUrl;
          }
          if (_user.githubUrl.isEmpty && extractedData['githubUrl'].toString().isNotEmpty) {
            _user.githubUrl = extractedData['githubUrl'];
            _githubController.text = _user.githubUrl;
          }
          if (_user.linkedinUrl.isEmpty && extractedData['linkedinUrl'].toString().isNotEmpty) {
            _user.linkedinUrl = extractedData['linkedinUrl'];
            _linkedinController.text = _user.linkedinUrl;
          }
          
          // Add extracted skills
          final extractedSkills = extractedData['skills'] as Set<String>;
          _user.skills.addAll(extractedSkills);
          
          // Update experience level
          _user.experience = extractedData['experience'];
          
          // Add work experience and education
          _user.workExperience = extractedData['workExperience'];
          _user.education = extractedData['education'];
        });

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resume uploaded successfully! Extracted ${extractedData['skills'].length} skills.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No file selected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading resume: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingResume = false;
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Update user model from controllers
      _user.name = _nameController.text;
      _user.email = _emailController.text;
      _user.phoneNumber = _phoneController.text;
      _user.location = _locationController.text;
      _user.summary = _summaryController.text;
      _user.portfolioUrl = _portfolioController.text;
      _user.githubUrl = _githubController.text;
      _user.linkedinUrl = _linkedinController.text;
      
      
      // Save profile data to local storage
      await UserStorageService.saveUserProfile(_user);
      
      // Update the user in AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.updateLocalUser(_user);
      
      // Navigate to job swipe screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JobSwipeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user.isGuest ? 'Create Your Profile' : 'Complete Your Profile'),
        actions: [
          if (!_user.isGuest)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                
                // Navigate back to auth screen after sign out
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                }
              },
              tooltip: 'Sign Out',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Guest user notice
              if (_user.isGuest)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guest Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your progress won\'t be saved. Sign in with Google to save your profile and job preferences.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location (City, State)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(labelText: 'Professional Summary'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portfolioController,
                decoration: const InputDecoration(labelText: 'Portfolio Website'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _githubController,
                decoration: const InputDecoration(labelText: 'GitHub Profile'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkedinController,
                decoration: const InputDecoration(labelText: 'LinkedIn Profile'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _user.experience,
                decoration: const InputDecoration(labelText: 'Experience Level'),
                items: _experienceLevels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) => setState(() => _user.experience = value!),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(labelText: 'Add a Skill (e.g., Flutter)'),
                      onFieldSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 36),
                    onPressed: _addSkill,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _user.skills.map((skill) {
                  return Chip(
                    label: Text(skill, style: const TextStyle(color: Colors.white)),
                    onDeleted: () => setState(() => _user.skills.remove(skill)),
                    backgroundColor: AppTheme.primaryColor,
                    deleteIconColor: Colors.white70,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: _isUploadingResume 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(_user.resumeFileName.isEmpty 
                    ? 'Upload Resume (PDF/DOC/TXT)' 
                    : 'Resume: ${_user.resumeFileName}'),
                onPressed: _isUploadingResume ? null : _uploadResume,
              ),
              if (_user.resumeFileName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Resume uploaded successfully! Skills and experience extracted.',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                  ),
                ),
              ],
              
              // Display extracted work experience
              if (_user.workExperience.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Work Experience (from resume)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(_user.workExperience.map((exp) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $exp',
                    style: const TextStyle(fontSize: 14),
                  ),
                ))),
              ],
              
              // Display extracted education
              if (_user.education.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Education (from resume)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(_user.education.map((edu) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $edu',
                    style: const TextStyle(fontSize: 14),
                  ),
                ))),
              ],
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text(_user.phoneNumber.isNotEmpty && _user.location.isNotEmpty 
                    ? 'Update Profile & Continue Swiping' 
                    : (_user.isGuest ? 'Start Swiping as Guest' : 'Start Swiping')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
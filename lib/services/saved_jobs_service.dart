import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_model.dart';

class SavedJobsService {
  static const String _savedJobsKey = 'saved_jobs_data';
  
  // Save swiped jobs to local storage
  static Future<void> saveSwipedJobs(List<JobModel> savedJobs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jobsJson = savedJobs.map((job) => {
        'title': job.title,
        'company': job.company,
        'location': job.location,
        'experienceLevel': job.experienceLevel,
        'requiredSkills': job.requiredSkills.toList(),
        'description': job.description,
        'companyLogo': job.companyLogo.codePoint, // Convert IconData to int
      }).toList();
      
      final jsonString = jsonEncode(jobsJson);
      await prefs.setString(_savedJobsKey, jsonString);
    } catch (e) {
      // Handle error silently
    }
  }
  
  // Load swiped jobs from local storage
  static Future<List<JobModel>> loadSwipedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_savedJobsKey);
      
      if (jsonString != null) {
        final List<dynamic> jobsData = jsonDecode(jsonString);
        final jobs = jobsData.map((jobData) => JobModel(
          title: jobData['title'] ?? '',
          company: jobData['company'] ?? '',
          location: jobData['location'] ?? '',
          experienceLevel: jobData['experienceLevel'] ?? '',
          requiredSkills: (jobData['requiredSkills'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? <String>{},
          description: jobData['description'] ?? '',
          companyLogo: IconData(jobData['companyLogo'] as int? ?? 0xe7f1, fontFamily: 'MaterialIcons'),
        )).toList();
        
        return jobs;
      }
    } catch (e) {
      // Handle error silently
    }
    return [];
  }
  
  // Clear saved jobs
  static Future<void> clearSavedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedJobsKey);
    } catch (e) {
      // Handle error silently
    }
  }
}
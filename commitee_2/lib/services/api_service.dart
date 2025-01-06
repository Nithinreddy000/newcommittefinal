import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/announcement.dart';
import '../models/payment.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String announcementsCacheKey = 'announcements_cache';
  static const Duration cacheDuration = Duration(minutes: 5);

  Future<List<Announcement>> getAnnouncements() async {
    try {
      final cachedAnnouncements = await _getCachedAnnouncements();
      if (cachedAnnouncements != null) {
        return cachedAnnouncements;
      }

      final response = await http.get(Uri.parse('$baseUrl/announcements'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        final announcements = jsonResponse.map((data) => Announcement.fromJson(data)).toList();
        await _cacheAnnouncements(announcements);
        return announcements;
      } else {
        throw Exception('Failed to load announcements');
      }
    } catch (e) {
      throw Exception('Error fetching announcements: $e');
    }
  }

  Future<Announcement> createAnnouncement(String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/announcements'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'content': content}),
      );

      if (response.statusCode == 201) {
        return Announcement.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create announcement');
      }
    } catch (e) {
      throw Exception('Error creating announcement: $e');
    }
  }

  Future<List<Payment>> getPayments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/payments'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Payment.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load payments');
      }
    } catch (e) {
      throw Exception('Error fetching payments: $e');
    }
  }

  Future<Payment> makePayment(String paymentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/$paymentId/pay'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Payment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to make payment');
      }
    } catch (e) {
      throw Exception('Error making payment: $e');
    }
  }

  Future<List<Announcement>?> _getCachedAnnouncements() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(announcementsCacheKey);
    if (cachedData != null) {
      final cachedTime = prefs.getInt('${announcementsCacheKey}_time');
      if (cachedTime != null &&
          DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(cachedTime)) < cacheDuration) {
        final List<dynamic> decodedData = json.decode(cachedData);
        return decodedData.map((item) => Announcement.fromJson(item)).toList();
      }
    }
    return null;
  }

  Future<void> _cacheAnnouncements(List<Announcement> announcements) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = json.encode(announcements.map((a) => a.toJson()).toList());
    await prefs.setString(announcementsCacheKey, encodedData);
    await prefs.setInt('${announcementsCacheKey}_time', DateTime.now().millisecondsSinceEpoch);
  }
}


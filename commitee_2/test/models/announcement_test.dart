import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/models/announcement.dart';

void main() {
  group('Announcement', () {
    test('should create an Announcement instance from JSON', () {
      final json = {
        'id': '1',
        'title': 'Test Announcement',
        'content': 'This is a test announcement',
        'createdAt': '2023-05-01T12:00:00Z',
      };

      final announcement = Announcement.fromJson(json);

      expect(announcement.id, '1');
      expect(announcement.title, 'Test Announcement');
      expect(announcement.content, 'This is a test announcement');
      expect(announcement.createdAt, DateTime.parse('2023-05-01T12:00:00Z'));
    });

    test('should convert Announcement instance to JSON', () {
      final announcement = Announcement(
        id: '1',
        title: 'Test Announcement',
        content: 'This is a test announcement',
        createdAt: DateTime.parse('2023-05-01T12:00:00Z'),
      );

      final json = announcement.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Test Announcement');
      expect(json['content'], 'This is a test announcement');
      expect(json['createdAt'], '2023-05-01T12:00:00Z');
    });
  });
}


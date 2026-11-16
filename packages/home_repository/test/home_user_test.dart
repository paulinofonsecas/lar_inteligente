import 'dart:convert';

import 'package:home_repository/src/home_user.dart';
import 'package:test/test.dart';

void main() {
  group('HomeUser', () {
    test('parses json and compares by value', () {
      final json = {'id': 'palmira', 'name': 'Palmira', 'role': 'host'};
      expect(
        HomeUser.fromJson(json),
        const HomeUser(id: 'palmira', name: 'Palmira', role: 'host'),
      );
      expect(
        HomeUser.fromJson(json).hashCode,
        const HomeUser(id: 'palmira', name: 'Palmira', role: 'host').hashCode,
      );
    });

    test('decodes the photo and leaves it out of equality', () {
      final user = HomeUser.fromJson({
        'id': 'palmira',
        'name': 'Palmira',
        'role': 'host',
        'photo': base64Encode([1, 2, 3]),
      });

      expect(user.photo, [1, 2, 3]);
      expect(
        user,
        const HomeUser(id: 'palmira', name: 'Palmira', role: 'host'),
      );
    });

    test('prompt names the user id and the screen rules', () {
      const user = HomeUser(id: 'paulino', name: 'Paulino', role: 'logistics');
      expect(user.prompt, contains('user_id "paulino"'));
      expect(user.prompt, contains('Call the tools'));
      expect(user.prompt, contains('landscape kitchen wall tablet'));
      expect(user.prompt, contains('without scrolling'));
      expect(user.prompt, contains('the ask bar sit above it'));
      expect(user.prompt, contains('The clock sits at the bottom-left'));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:farm_connect/src/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('Email Validator', () {
      test('returns true for a valid email', () {
        expect(Validators.isValidEmail('test@example.com'), isTrue);
      });

      test('returns false for an invalid email', () {
        expect(Validators.isValidEmail('test'), isFalse);
        expect(Validators.isValidEmail('test@'), isFalse);
        expect(Validators.isValidEmail('test@example'), isFalse);
        expect(Validators.isValidEmail('@example.com'), isFalse);
      });
    });

    group('Password Validator', () {
      test('returns true for a valid password', () {
        expect(Validators.isValidPassword('password123'), isTrue);
      });

      test('returns false for a password shorter than 8 characters', () {
        expect(Validators.isValidPassword('1234567'), isFalse);
      });
    });
  });
}

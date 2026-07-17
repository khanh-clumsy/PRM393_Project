import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_mobile/vn/edu/fpt/controllers/forgot_password_controller.dart';

void main() {
  late ForgotPasswordController controller;

  setUp(() {
    controller = ForgotPasswordController();
  });

  group('validateEmail', () {
    test('email rong tra loi', () {
      expect(controller.validateEmail(''), isNotNull);
    });

    test('email sai dinh dang tra loi', () {
      expect(controller.validateEmail('abc'), isNotNull);
    });

    test('email hop le tra null', () {
      expect(controller.validateEmail('student@fschool.edu.vn'), isNull);
    });
  });

  group('validateReset', () {
    test('OTP khong du 6 so tra loi', () {
      expect(
        controller.validateReset('123', 'password1', 'password1'),
        isNotNull,
      );
    });

    test('mat khau duoi 8 ky tu tra loi', () {
      expect(controller.validateReset('123456', 'short', 'short'), isNotNull);
    });

    test('mat khau khong khop tra loi', () {
      expect(
        controller.validateReset('123456', 'password1', 'password2'),
        isNotNull,
      );
    });

    test('hop le tra null', () {
      expect(
        controller.validateReset('123456', 'password1', 'password1'),
        isNull,
      );
    });
  });
}

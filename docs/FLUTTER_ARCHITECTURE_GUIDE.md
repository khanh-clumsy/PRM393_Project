# Cấu trúc chuẩn của một Repository Mobile (Flutter)

Dựa trên các quy chuẩn (Clean Architecture & MVC/GetX pattern) và tài liệu `GEMINI.md` của dự án, đây là cấu trúc thư mục chuẩn và cách tổ chức mã nguồn:

## 1. Cấu trúc thư mục (Directory Structure)

Các file mã nguồn chính nên được đặt trong `lib/vn/edu/fpt/` (hoặc cấu trúc package tương tự) và chia thành các tầng rõ ràng:

```text
lib/
└── vn/edu/fpt/
    ├── core/                   # Chứa các thành phần cốt lõi dùng chung
    │   ├── theme/              # Cấu hình màu sắc, font chữ (ví dụ: FSchool Orange #FF6B00)
    │   ├── network/            # Cấu hình Dio client, interceptors
    │   └── storage/            # Quản lý local storage (SharedPreferences/SecureStorage)
    ├── models/                 # Chứa các Data Models (phải kết thúc bằng _model.dart)
    │   ├── user_model.dart
    │   └── student_model.dart
    ├── controllers/            # Xử lý logic, gọi API (phải kết thúc bằng _controller.dart)
    │   ├── auth_controller.dart
    │   └── student_controller.dart
    ├── view/                   # Giao diện UI (phải kết thúc bằng _view.dart hoặc _screen.dart)
    │   ├── login_screen.dart
    │   └── academic_view.dart
    ├── widgets/                # Các UI Component dùng chung (Button, Dialog, Textfield...)
    │   ├── custom_button.dart
    │   └── loading_overlay.dart
    └── main.dart               # Entry point của ứng dụng
```

> [!IMPORTANT]
> **Quy tắc quan trọng (Separation of Concerns):**
> - **View (UI):** Chỉ hiển thị dữ liệu và nhận tương tác từ người dùng. Cố gắng sử dụng Stateless (ví dụ: GetView) và tách biệt hoàn toàn logic.
> - **Controller:** Chứa toàn bộ state, logic xử lý, validate form và thực hiện gọi API.

---

## 2. Demo: Gọi API và lưu Token

Trong ví dụ này, chúng ta sẽ sử dụng **Dio** (bắt buộc theo quy chuẩn) để gọi API và một thư viện như `flutter_secure_storage` hoặc `shared_preferences` để lưu token.

### Bước 2.1: Cấu hình API Client (Dio Interceptor)
Tạo file `lib/vn/edu/fpt/core/network/api_client.dart`. Interceptor này sẽ tự động gắn Token vào mỗi request (trừ các request login/refresh).

```dart
import 'package:dio/dio.dart';
import '../storage/local_storage.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.yourdomain.com', // Thay bằng URL API thật
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static void init() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Lấy token từ local storage
        final token = await LocalStorage.getToken();
        
        // Bỏ qua gắn token cho các endpoint auth
        bool isAuthRoute = options.path.contains('/api/auth/login') || 
                           options.path.contains('/api/auth/forgot-password');
                           
        if (token != null && !isAuthRoute) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Xử lý lỗi global ở đây (ví dụ: token hết hạn 401 -> gọi refresh token)
        return handler.next(e);
      },
    ));
  }

  static Dio get instance => _dio;
}
```

### Bước 2.2: Local Storage (Lưu Token)
Tạo file `lib/vn/edu/fpt/core/storage/local_storage.dart`.

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
```

### Bước 2.3: Model (Response DTO)
Tạo `lib/vn/edu/fpt/models/auth_response_model.dart`.

```dart
class AuthResponseModel {
  final String token;
  final String refreshToken;

  AuthResponseModel({required this.token, required this.refreshToken});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }
}
```

### Bước 2.4: Controller xử lý Đăng nhập
Tạo `lib/vn/edu/fpt/controllers/auth_controller.dart`. Chứa logic gọi API và điều hướng, không để logic này ở View.

```dart
import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../models/auth_response_model.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;

  Future<void> login(String username, String password) async {
    isLoading.value = true;
    try {
      final response = await ApiClient.instance.post(
        '/api/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = AuthResponseModel.fromJson(response.data);
        
        // 1. Lưu token vào Storage
        await LocalStorage.saveToken(data.token);
        
        // 2. Chuyển hướng sang màn hình chính
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Lỗi đăng nhập', 'Tài khoản hoặc mật khẩu không đúng');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    await LocalStorage.deleteToken();
    Get.offAllNamed('/login');
  }
}
```

### Bước 2.5: View (Giao diện hiển thị)
Tạo `lib/vn/edu/fpt/view/login_screen.dart`. View gọi các hàm trong Controller.

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inject controller nếu dùng GetX
    Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập FSchool'),
        backgroundColor: const Color(0xFFFF6B00), // FSchool Orange
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
            ),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
            ),
            const SizedBox(height: 20),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      controller.login(userCtrl.text, passCtrl.text);
                    },
                    child: const Text('Đăng nhập'),
                  )),
          ],
        ),
      ),
    );
  }
}
```

> [!TIP]
> **Tóm tắt quy trình:**
> 1. Người dùng bấm "Đăng nhập" trên `LoginScreen`.
> 2. Sự kiện được truyền tới `AuthController.login()`.
> 3. `AuthController` dùng `ApiClient` (Dio) gọi API POST `/api/auth/login`.
> 4. Nhận về JSON, parse sang `AuthResponseModel`.
> 5. Lấy chuỗi Token và gọi `LocalStorage.saveToken()` để lưu cục bộ (dùng SecureStorage).
> 6. Các request API tiếp theo, `Dio Interceptor` sẽ tự động đọc token từ LocalStorage và gắn vào Header `Authorization: Bearer <token>`.

---

## 3. Các UI Component dùng chung (Shared Widgets)

Đối với các UI Component được sử dụng lặp lại ở nhiều nơi (như Custom Button, TextField, Dialog, Loading Spinner, Card...), bạn nên đặt chúng trong thư mục `lib/vn/edu/fpt/widgets/` (hoặc `lib/vn/edu/fpt/core/widgets/`).

### Quy tắc khi tạo Shared Widgets:
- **Stateless ưu tiên**: Hầu hết các component dùng chung nên là `StatelessWidget`.
- **Nhận data qua tham số (Props)**: Component không nên tự gọi API hoặc chứa business logic. Hãy truyền dữ liệu và callback (`onPressed`, `onChanged`) vào qua constructor.
- **Tuân thủ Design System**: Sử dụng màu sắc, font chữ từ `core/theme/` để đồng nhất giao diện (ví dụ: dùng màu FSchool Orange `#FF6B00`).

### Ví dụ: `custom_button.dart`
Đặt file tại `lib/vn/edu/fpt/widgets/custom_button.dart`:

```dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B00), // FSchool Orange
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
```

Cách dùng lại component này trong `LoginScreen`:
```dart
// Import widget
import '../widgets/custom_button.dart';

// Trong hàm build() thay thế ElevatedButton mặc định:
CustomButton(
  text: 'Đăng nhập',
  isLoading: controller.isLoading.value,
  onPressed: () {
    controller.login(userCtrl.text, passCtrl.text);
  },
)
```

---

## 4. Quản lý tài nguyên (Assets - Ảnh, Icons, Fonts)

Trong Flutter, ảnh và các tài nguyên tĩnh không được đặt trong thư mục `lib/` mà phải đặt ở thư mục `assets/` ngang hàng với `lib/` (nghĩa là ở thư mục gốc của project mobile).

### Cấu trúc thư mục Assets:
```text
mobile/
├── assets/
│   ├── images/         # Chứa ảnh tĩnh (ví dụ: logo.png, background.jpg)
│   ├── icons/          # Chứa các icon tĩnh (ví dụ: ic_home.svg)
│   └── fonts/          # Chứa các file font chữ (ví dụ: Inter-Regular.ttf)
├── lib/
└── pubspec.yaml
```

### Cách khai báo và sử dụng:

**1. Khai báo trong file `pubspec.yaml`**:
Bạn bắt buộc phải khai báo đường dẫn thư mục assets vào `pubspec.yaml` thì Flutter mới nhận diện và bundle ảnh vào app:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

**2. Tạo class hằng số (Constants) cho Assets**:
Để tránh việc gõ chuỗi text cứng (hardcode string) dễ gây lỗi sai chính tả khi gọi ảnh, bạn nên tạo một file chứa các hằng số đường dẫn, ví dụ tại `lib/vn/edu/fpt/core/constants/asset_paths.dart`:

```dart
class AssetPaths {
  // Thư mục gốc
  static const String imagePath = 'assets/images';
  static const String iconPath = 'assets/icons';

  // Định nghĩa từng ảnh
  static const String logo = '$imagePath/logo_fschool.png';
  static const String defaultAvatar = '$imagePath/default_avatar.png';
  
  // Định nghĩa từng icon
  static const String icSuccess = '$iconPath/ic_success.svg';
}
```

**3. Cách sử dụng trên UI**:
```dart
import '../core/constants/asset_paths.dart';

// Hiển thị ảnh PNG/JPG
Image.asset(AssetPaths.logo, width: 100, height: 100),

// Hoặc nếu dùng SVG (cần cài đặt package flutter_svg)
SvgPicture.asset(AssetPaths.icSuccess),
```

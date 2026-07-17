# Tiến độ triển khai Mobile — FSchool

Tài liệu theo dõi tiến độ phát triển ứng dụng Flutter (`mobile/`). Cập nhật lần cuối: **15/07/2026**.

**Tham chiếu:** [SRS.md](./SRS.md) · [API_DESIGN.md](./API_DESIGN.md) · [FLUTTER_ARCHITECTURE_GUIDE.md](./FLUTTER_ARCHITECTURE_GUIDE.md) · [MOBILE_COMPLETION_PLAN.md](./MOBILE_COMPLETION_PLAN.md) *(kế hoạch 80–90% → 100%)* · [tests/MOBILE_TEST_MATRIX.md](./tests/MOBILE_TEST_MATRIX.md) *(QA sprint Completion)* · [tests/MOBILE_TEST_MATRIX_NEWSFEED_LEAVE.md](./tests/MOBILE_TEST_MATRIX_NEWSFEED_LEAVE.md) *(QA Bảng tin & Đơn nghỉ)*

---

## 1. Tổng quan

| Hạng mục | Giá trị |
|----------|---------|
| Commit mobile mới nhất | `cfcf883` (27/06/2026) |
| Tiến độ ước lượng (so với SRS) | **~75–80%** |
| Tổng file Dart | 79 |
| View / Screen | 33 |
| Controller | 18 |
| Model | 19 |

Kiến trúc đã theo chuẩn dự án: **View → Controller → ApiClient (Dio) → API**, routing GetX (`app_router.dart`), state management GetX.

---

## 2. Lịch sử commit liên quan mobile

| Commit | Ngày | Nội dung chính |
|--------|------|----------------|
| `e414913` | 11/06/2026 | Khởi tạo project Flutter + scaffold cơ bản |
| `1d471b4` | — | UI cơ bản, bottom nav, màn hình mẫu |
| `349f421` | — | Tổ chức lại assets, tài liệu kiến trúc |
| `1a447d2` | — | Kiến trúc core: GetX, Dio `ApiClient`, JWT, login, routing theo role |
| `31978db` | 26/06/2026 | Master data Admin — CRUD đầy đủ danh mục |
| `cfcf883` | 27/06/2026 | Module nghiệp vụ chính: điểm danh, điểm số, TKB, phân quyền đa role |

---

## 3. Bảng tiến độ tổng thể

```
Tiến độ ước lượng theo SRS mobile:

█████████████████░░░  ~85–90%

✅ Nền tảng + Auth + Routing role      [██████████] 100%
✅ Admin / HeadOfDept master data      [██████████] 100%
✅ TKB + Phân công + Phân lớp          [██████████] 100%
✅ Điểm danh + Nhập/xem điểm           [██████████] 100%
✅ Bảng tin & Thông báo               [██████████] 100%
✅ Đơn xin nghỉ                        [██████████] 100%
✅ Học bạ / Tổng kết (demo 3 role)     [██████████] 100%
❌ Bảo mật tài khoản (đổi/quên MK)     [░░░░░░░░░░]   0%
```

| Module | Tiến độ | Trạng thái |
|--------|---------|------------|
| Nền tảng + Auth + Routing role | 100% | ✅ Hoàn thành |
| Admin / HeadOfDept master data | 100% | ✅ Hoàn thành (sprint 09/07/2026) |
| TKB + Phân công + Phân lớp | 100% | ✅ Hoàn thành (sprint 09/07/2026) |
| Điểm danh + Nhập/xem điểm | 100% | ✅ Hoàn thành (sprint 09/07/2026) |
| Bảng tin & Thông báo | 100% | ✅ Đã nối API thật; chờ QA Flutter |
| Đơn xin nghỉ | 100% | ✅ HS/PH tạo đơn, GV duyệt; chờ QA Flutter |
| Học bạ / Tổng kết (demo HS/PH/GV) | 100% | ✅ HS/PH xem học bạ; GVCN xem bảng lớp (GET, chỉ đọc). Chốt PUT qua Swagger; seed summary pending |
| Bảo mật tài khoản (đổi/quên MK) | 0% | ❌ Chưa bắt đầu |

---

## 4. Đã implement (hoàn thiện / gần hoàn thiện)

### 4.1. Xác thực & hạ tầng

| Tính năng | File / vị trí chính | Ghi chú |
|-----------|---------------------|---------|
| Login JWT + Refresh Token | `auth_controller.dart`, `login_view.dart` | Lưu token qua `LocalStorage` |
| Routing theo 5 role | `app_router.dart`, `auth_controller.dart` | Admin, HeadOfDept, Teacher, Student, Parent |
| ApiClient (Dio) + interceptor JWT | `core/network/api_client.dart` | Chuẩn hóa gọi API |
| Xem hồ sơ tài khoản | `account_controller.dart`, `account_view.dart` | Chỉ **đọc** profile từ API |

### 4.2. Admin — Quản lý đào tạo

Dashboard `admin_home_view.dart` với 13 module, mỗi module có view + controller + model:

| Module | View |
|--------|------|
| Tài khoản | `user_management_view.dart` |
| Phòng ban / Khoa | `department_management_view.dart` |
| Năm học | `academic_year_management_view.dart` |
| Học kỳ | `semester_management_view.dart` |
| Môn học | `subject_management_view.dart` |
| Lớp học | `class_management_view.dart` |
| Xếp loại học lực | `academic_rank_management_view.dart` |
| Ca học (Slot) | `timetable_slot_management_view.dart` |
| Phân công GV | `teaching_assignment_management_view.dart` |
| Thời khóa biểu | `timetable_management_view.dart` |
| Phân lớp HS | `student_class_management_view.dart` |
| Phụ huynh – HS | `parent_student_management_view.dart` |
| Bảng tin | `announcement_management_view.dart` |

### 4.3. Trưởng bộ môn (HeadOfDept)

| Tính năng | File chính |
|-----------|------------|
| Dashboard module | `head_of_dept_home_view.dart`, `head_of_dept_main_view.dart` |
| Lớp học (scope tổ) | `class_management_view.dart` + `ScopeMode.head` |
| Phân công giảng dạy | `teaching_assignment_management_view.dart` |
| Thời khóa biểu | `timetable_management_view.dart` |
| GV tổ / Phân công tổ | `head_dept_teachers_view.dart`, `head_dept_assignments_view.dart` |

### 4.4. Giáo viên — Nghiệp vụ dạy học

| Tính năng | File chính | API |
|-----------|------------|-----|
| Dashboard + quick actions | `teacher_home_view.dart` | — |
| Điểm danh GV | `teacher_attendance_view.dart`, `teacher_attendance_controller.dart` | ✅ |
| Tab Lớp của tôi | `teacher_classes_view.dart`, `teacher_classes_controller.dart` | ✅ |
| Xem thời khóa biểu | `timetable_view.dart`, `timetable_controller.dart` (weekly/by-teacher) | ✅ |
| Tổng kết lớp (GVCN, chỉ đọc) | `teacher_class_summary_view.dart`, `teacher_class_summary_controller.dart` | ✅ GET board + `by-homeroom` |

### 4.5. Học sinh — Tra cứu học tập

| Tính năng | File chính | API |
|-----------|------------|-----|
| Xem điểm số (GPA học kỳ/cả năm) | `student_grade_view.dart`, `student_grade_controller.dart` | ✅ |
| Chi tiết điểm từng môn | `student_grade_detail_view.dart` | ✅ |
| Học bạ theo năm | `academic_report_view.dart`, `academic_report_controller.dart` | ✅ `yearly-transcript` |
| Thời khóa biểu | `timetable_view.dart` | ✅ |

### 4.6. Phụ huynh

| Tính năng | File chính | API |
|-----------|------------|-----|
| Home + chọn con | `parent_home_view.dart`, `parent_main_view.dart` | ✅ |
| Xem TKB của con | `timetable_view.dart` | ✅ |
| Xem điểm danh của con | `attendance_view.dart` | ✅ |
| Xem bảng điểm con | `student_grade_view.dart` (targetStudentId) | ✅ |
| Tạo/theo dõi đơn nghỉ cho con | `parent_home_view.dart`, `leave_request_view.dart` | ✅ |
| Học bạ con | `parent_home_view.dart` → `academic_report_view.dart` | ✅ |

### 4.7. Bảng tin, thông báo & đơn nghỉ

| Tính năng | File chính | API |
|-----------|------------|-----|
| Feed bảng tin theo user đăng nhập | `announcement_feed_controller.dart`, `student_home_view.dart`, `notifications_view.dart` | ✅ `/api/announcement/my-feed` |
| GV đăng thông báo lớp | `teacher_class_announcement_view.dart`, `teacher_home_view.dart` | ✅ `/api/announcement` |
| HS tạo và theo dõi đơn nghỉ | `leave_request_controller.dart`, `leave_request_view.dart` | ✅ `/api/studentrequest` |
| GV duyệt/từ chối đơn nghỉ | `teacher_leave_review_controller.dart`, `teacher_leave_review_view.dart` | ✅ `/api/studentrequest/pending/for-teacher`, `/review` |

---

## 5. Implement dở (UI có / logic chưa đủ)

| Tính năng | File chính | Vấn đề hiện tại | Ưu tiên |
|-----------|------------|-----------------|---------|
| Tab Tin nhắn (Student) | `student_main_view.dart` | Placeholder — module chat **đã loại khỏi SRS** | Thấp (nên gỡ) |

---

## 6. Chưa implement

Theo [SRS.md](./SRS.md), các hạng mục sau **chưa có** trên mobile:

| Module SRS | Mô tả | Ghi chú |
|------------|-------|---------|
| **Học bạ điện tử** | Xem tổng kết học kỳ/năm (GPA, Hạnh kiểm, Xếp loại) | ✅ HS/PH: `academic_report_view`; empty nếu chưa seed summary |
| **GVCN chốt GPA & Hạnh kiểm** | Flow giáo viên chủ nhiệm chốt sổ cuối kỳ/năm | Mobile chỉ **xem** bảng lớp; chốt qua API PUT / Swagger |
| **Đổi mật khẩu** | Bảo mật tài khoản | `AccountController` chỉ đọc, chưa có form đổi MK |
| **Quên mật khẩu** | Khôi phục qua email bằng OTP 6 số | Đã có UI hai bước gửi OTP/đặt mật khẩu mới; reset endpoints public và không log body nhạy cảm |
| **Cập nhật hồ sơ cá nhân** | Sửa họ tên, ngày sinh, địa chỉ, avatar… | Chưa có form chỉnh sửa |
| **Push notification** | Thông báo đẩy trên điện thoại | Chưa tích hợp FCM |
| **Module Chat** | Tin nhắn 1-1 / nhóm | **Out of scope** — cần gỡ placeholder trên UI Student |

---

## 7. Ma trận theo vai trò (RBAC)

| Vai trò | Đã có | Làm dở | Chưa có |
|---------|-------|--------|---------|
| **Admin** | CRUD toàn bộ master data, TKB, phân công, bảng tin | Dashboard thống kê | — |
| **HeadOfDept** | Lớp, phân công, TKB trong phạm vi tổ; GV tổ | — | — |
| **Teacher** | Điểm danh GV, TKB, tab Lớp, thông báo lớp, duyệt đơn nghỉ, xem tổng kết lớp chủ nhiệm | — | UI chốt sổ (PUT) trên app |
| **Student** | Xem điểm, TKB, bảng tin/thông báo, tạo/theo dõi đơn nghỉ, Học bạ | — | — |
| **Parent** | TKB con, điểm danh con, xem điểm con, đơn nghỉ cho con, Học bạ con | — | — |

---

## 8. Kế hoạch hoàn thiện module 80–90%

Đã lập kế hoạch chi tiết tại **[MOBILE_COMPLETION_PLAN.md](./MOBILE_COMPLETION_PLAN.md)** với 5 phase:

| Phase | Nội dung | Ước lượng |
|-------|----------|-----------|
| 0 | Bug P0 + API hỏng (giữ nút test TKB) | 0.5–1 ngày |
| 1 | Admin / HeadOfDept master data → 100% | 1–2 ngày |
| 2 | TKB + Phân công + Phân lớp → 100% | 2–3 ngày |
| 3 | Điểm danh GV + xem điểm PH → 100% | 2–3 ngày |
| 4–5 | Polish, QA, cập nhật docs | 1–1.5 ngày |

**Sprint Mobile Completion (09/07/2026):** 3 module mục tiêu đã đạt **100%** (Admin/HeadOfDept, TKB/Phân công/Phân lớp, Điểm danh/Nhập-xem điểm). Tổng tiến độ SRS ~75–80%.

**Blocker đã gỡ:** PUT phân công backend, API department HeadOfDept, màn điểm danh GV, PH xem điểm, RBAC `departmentId`.

---

## 9. Backlog ưu tiên (gợi ý sprint tiếp theo)

| # | Task | Phụ thuộc API | Độ ưu tiên |
|---|------|---------------|------------|
| 1 | Chạy QA sprint Bảng tin & Đơn nghỉ | `docs/tests/MOBILE_TEST_MATRIX_NEWSFEED_LEAVE.md` | 🔴 Cao |
| 2 | Học bạ điện tử + flow GVCN chốt GPA/Hạnh kiểm | `StudentSemesterSummaries`, `StudentYearlySummaries` | 🟠 Trung bình |
| 3 | Cập nhật profile + đổi mật khẩu + quên MK | Auth/User endpoints | 🟡 Thấp |
| 4 | Dọn UI: gỡ tab Tin nhắn, hoàn thiện tab Lớp GV | — | 🟡 Thấp |
| 5 | Push notification (FCM) | Backend + mobile config | 🟡 Thấp |

**Đã loại khỏi scope:** Module Bài tập/Assignments và nộp bài đã được bỏ khỏi sản phẩm. UI nhập điểm giáo viên đã gỡ khỏi mobile (endpoint `/api/grade/*` vẫn giữ).

---

## 10. Cách cập nhật tài liệu này

Khi hoàn thành một module:

1. Chuyển mục từ **§5** hoặc **§6** sang **§4** tương ứng.
2. Cập nhật **§3** (bảng tiến độ và thanh %).
3. Ghi commit tham chiếu vào **§2** nếu là milestone lớn.
4. Đổi ngày “Cập nhật lần cuối” ở đầu file.

---

## 11. Lịch sử cập nhật tài liệu

| Phiên bản | Ngày | Nội dung |
|-----------|------|----------|
| v1.3 | 14/07/2026 | Implement Bảng tin/Thông báo + Đơn xin nghỉ mobile; QA Flutter để sprint sau |
| v1.2 | 09/07/2026 | Hoàn thành Mobile Completion Sprint — 3 module → 100%, tổng ~75–80% |
| v1.1 | 09/07/2026 | Thêm §8 link tới MOBILE_COMPLETION_PLAN.md |
| v1.0 | 09/07/2026 | Khởi tạo báo cáo tiến độ từ đánh giá commit `cfcf883` |

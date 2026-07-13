# Kế hoạch hoàn thiện Mobile — 3 module 80–90% → 100%

Tài liệu triển khai cho sprint hoàn thiện các module đang ở **80–90%** trong [MOBILE_PROGRESS.md](./MOBILE_PROGRESS.md).

**Phạm vi:** Chỉ 3 nhóm sau — **không** mở rộng sang Bài tập, Học bạ GVCN, Đơn nghỉ, Push notification.

| Module hiện tại | % | Mục tiêu |
|-----------------|---|----------|
| Admin / HeadOfDept master data | 90% | **100%** |
| TKB + Phân công + Phân lớp | 90% | **100%** |
| Điểm danh + Nhập/xem điểm | 80% | **100%** |

**Tham chiếu:** [SRS.md](./SRS.md) §3.2–3.4 · [API_DESIGN.md](./API_DESIGN.md) · [FLUTTER_ARCHITECTURE_GUIDE.md](./FLUTTER_ARCHITECTURE_GUIDE.md) · [MOBILE_TEST_MATRIX.md](./MOBILE_TEST_MATRIX.md) *(kịch bản QA thủ công)*

**Cập nhật lần cuối:** 09/07/2026

---

## 1. Định nghĩa hoàn thành (Definition of Done)

Một module được coi là **100%** khi:

1. Đáp ứng đủ yêu cầu SRS tương ứng cho role liên quan.
2. Không còn placeholder / flow gọi API không tồn tại. *(Ngoại lệ: nút dev "Xóa lịch đã sinh" trên TKB được **giữ lại** để test.)*
3. RBAC đúng phạm vi (Admin toàn trường; HeadOfDept theo `departmentId`).
4. Validation + error message từ server hiển thị rõ cho người dùng.
5. Đã test thủ công ít nhất 1 happy path + 1 error path trên emulator.
6. Cập nhật [MOBILE_PROGRESS.md](./MOBILE_PROGRESS.md) §3 sau khi merge.

---

## 2. Quyết định kiến trúc cần chốt trước khi code

### 2.1. HeadOfDept — Write hay View-only?

| Nguồn | Quy định |
|-------|----------|
| **SRS v2.0** | HeadOfDept có **Write** Lớp / Phân công / TKB **trong tổ** |
| **API_DESIGN §7** | HeadOfDept chủ yếu **GET** theo `departmentId` |

**Quyết định đề xuất (theo SRS):**

- HeadOfDept **được Write** trên Lớp, Phân công, TKB — nhưng **lọc theo tổ**.
- **Gỡ** khỏi dashboard HeadOfDept: Phân lớp HS, Phụ huynh–HS (thuộc Admin).
- **Bổ sung** màn xem: GV tổ, phân công tổ (`API_DESIGN §7`).

### 2.2. Lưu `departmentId` khi login

- Mở rộng `AuthModel` + `LocalStorage` lưu `departmentId` (nếu role Teacher/HeadOfDept).
- Nếu API login chưa trả `departmentId` → bổ sung backend hoặc gọi `GET /api/user/{id}` sau login.

### 2.3. Sửa phân công (PUT) — Backend vs Mobile

- Backend hiện **không có** `PUT /api/teachingassignment/{id}`.
- **Phương án A (khuyến nghị):** Thêm PUT trên API.
- **Phương án B:** Gỡ nút Sửa trên mobile; chỉ Create + Delete.

---

## 3. Lộ trình triển khai (theo thứ tự)

```
Phase 0: Bug P0 + cleanup          (0.5–1 ngày)
Phase 1: HeadOfDept RBAC           (1–2 ngày)
Phase 2: TKB + Phân công + Phân lớp  (2–3 ngày)
Phase 3: Điểm danh GV + xem điểm PH  (2–3 ngày)
Phase 4: Polish master data Admin    (1–2 ngày)
Phase 5: QA + cập nhật docs          (0.5 ngày)
```

**Tổng ước lượng:** 7–11 ngày làm việc (1 dev).

---

## Phase 0 — Bug P0 & dọn code (ưu tiên cao nhất)

> Mục tiêu: Gỡ blocker khiến tính năng **hỏng** hoặc **sai nghiệp vụ**.

| # | Task | File / API | Acceptance criteria |
|---|------|------------|---------------------|
| 0.1 | ~~Gỡ nút test~~ **Giữ nút test** | `timetable_management_view.dart` | Giữ nút "Xóa lịch đã sinh" + `clearGeneratedTimetables()` để tiếp tục test; có thể đổi label bỏ chữ `TODO` (tùy chọn) |
| 0.2 | Sửa edit phân công GV | `teaching_assignment_controller.dart` + API | Hoặc PUT backend hoạt động, hoặc gỡ nút Sửa + hiện snackbar hướng dẫn xóa/tạo lại |
| 0.3 | Sửa payload update tiết TKB | `timetable_controller.dart` | Không gửi field backend không nhận (`teachingAssignmentId` nếu DTO không hỗ trợ) |
| 0.4 | Sửa GV mở AttendanceView sai | `teacher_home_view.dart` | GV **không** dùng `StudentAttendanceController` cho đến khi Phase 3 xong; tạm ẩn/disable quick action hoặc redirect màn mới |
| 0.5 | Sửa hiển thị tiết trùng slot | `timetable_management_view.dart` | Hiện tất cả tiết trong slot, không `.first` ẩn mất |

**Kết quả Phase 0:** Không còn flow broken trên 3 module.

---

## Phase 1 — Admin / HeadOfDept master data → 100%

### 1A. Hạ tầng RBAC HeadOfDept

| # | Task | File | Acceptance criteria |
|---|------|------|---------------------|
| 1.1 | Lưu `departmentId` sau login | `auth_model.dart`, `local_storage.dart`, `auth_controller.dart` | HeadOfDept/Teacher có `departmentId` trong storage |
| 1.2 | Helper đọc role + department | `core/` (vd. `role_context.dart`) | Controller gọi `RoleContext.isHeadOfDept`, `departmentId` |
| 1.3 | Cập nhật dashboard HeadOfDept | `head_of_dept_home_view.dart` | Chỉ còn: Lớp, Phân công, TKB, GV tổ; **gỡ** Phân lớp HS & PH–HS |
| 1.4 | Truyền `scopeMode` vào shared views | `class_management_view.dart`, `teaching_assignment_management_view.dart`, `timetable_management_view.dart` | `admin` = toàn trường; `head` = lọc theo tổ |

### 1B. Lọc dữ liệu theo tổ (HeadOfDept)

| # | Task | Cách lọc | Acceptance criteria |
|---|------|----------|---------------------|
| 1.5 | Lọc danh sách GV | `GET /api/user/by-department/{id}` hoặc lookup scoped | Dropdown GV chỉ hiện GV thuộc tổ |
| 1.6 | Lọc phân công | Filter client theo `teacherId` thuộc tổ, hoặc `GET /api/departments/{id}/assignments` | HeadOfDept không thấy phân công tổ khác |
| 1.7 | Lọc lớp / TKB | Lớp có môn do GV tổ dạy, hoặc theo rule nghiệp vụ đã chốt | HeadOfDept chỉ quản lý phạm vi tổ |

### 1C. Màn mới HeadOfDept (API_DESIGN §7)

| # | Task | File mới | Acceptance criteria |
|---|------|----------|---------------------|
| 1.8 | Xem GV tổ | `head_dept_teachers_view.dart` + controller | Gọi `GET /api/departments/{id}/teachers` |
| 1.9 | Xem phân công tổ | `head_dept_assignments_view.dart` (hoặc reuse với filter) | Gọi `GET /api/departments/{id}/assignments` |

### 1D. Hoàn thiện Admin master data

| # | Task | File | Acceptance criteria |
|---|------|------|---------------------|
| 1.11 | Khóa/mở tài khoản | `user_management_view.dart`, `user_controller.dart` | `PUT /api/admin/users/{id}/status` hoặc endpoint tương đương; hiển thị `isActive` |
| 1.12 | Bổ sung trường hồ sơ user | `user_management_view.dart` | Form có `dateOfBirth`, `gender`, `address` theo API |
| 1.13 | Validation học kỳ trong năm học | `semester_management_view.dart` | Client chặn ngày học kỳ ngoài khoảng năm học |
| 1.14 | Validation xếp loại không chồng lấn | `academic_rank_management_view.dart` | Cảnh báo khi `minScore`–`maxScore` trùng rank khác |
| 1.15 | Giới hạn 10 tiết / slot không chồng giờ | `timetable_slot_management_view.dart` | Validate tối đa 10 slot; cảnh báo overlap thời gian |
| 1.16 | Parse lỗi server thống nhất | Tất cả `*_controller.dart` admin | Hiển thị `response.data['message']` khi có |
| 1.17 | Admin dashboard | `admin_main_view.dart` | Thay placeholder bằng màn thống kê đơn giản (số user, lớp, môn, thông báo) **hoặc** gỡ tab Dashboard, chỉ giữ Trang chủ + Tài khoản |

**Kết quả Phase 1:** Admin CRUD đủ SRS §3.2; HeadOfDept đúng phạm vi tổ.

---

## Phase 2 — TKB + Phân công + Phân lớp → 100%

### 2A. Thời khóa biểu quản lý

| # | Task | File | Acceptance criteria |
|---|------|------|---------------------|
| 2.1 | UI cập nhật trạng thái tiết | `timetable_management_view.dart` | Dùng `updateTimetableStatus()` — hủy/báo nghỉ/ghi chú |
| 2.2 | Sửa template — đổi thứ | Form template trong `timetable_management_view.dart` | Edit giữ/đổi được `dayOfWeek` |
| 2.3 | Validate ngày trong học kỳ | `timetable_controller.dart` | Chặn tạo/xem lịch ngoài `startDate`–`endDate` kỳ |
| 2.4 | Cảnh báo trùng lịch (client) | `timetable_management_view.dart` | Trước khi lưu: check GV/lớp trùng slot cùng ngày |
| 2.5 | HS resolve lớp đúng năm học | `timetable_controller.dart` | Không dùng `[0]` mù; lọc `StudentClasses` theo năm active |

### 2B. Phân công giảng dạy

| # | Task | File | Acceptance criteria |
|---|------|------|---------------------|
| 2.6 | Lọc môn `isActive` | `teaching_assignment_management_view.dart` | Dropdown chỉ môn đang hoạt động |
| 2.7 | Xem phân công theo GV (Admin) | Optional tab/filter | Dùng `GET /api/teachingassignment/by-teacher/{id}` |
| 2.8 | Thông báo lỗi trùng phân công | `teaching_assignment_controller.dart` | Hiện message server khi POST trùng |

### 2C. Phân lớp học sinh

| # | Task | File | Acceptance criteria |
|---|------|------|---------------------|
| 2.9 | Lọc HS khả dụng theo năm học | `student_class_management_view.dart` | Không hiện HS đã thuộc lớp khác cùng năm |
| 2.10 | Tìm kiếm HS khi thêm | `student_class_management_view.dart` | Search theo tên/mã, tránh load toàn bộ nếu >50 HS |
| 2.11 | (Optional) Bulk thêm HS | `student_class_controller.dart` | Chọn nhiều HS → POST hàng loạt hoặc loop có progress |
| 2.12 | (Optional) Xem lịch sử phân lớp | View mới hoặc bottom sheet | Tra `StudentClasses` theo HS qua các năm |

### 2D. Phụ huynh – HS (Admin only)

| # | Task | File | Acceptance criteria |
|---|------|------|---------------------|
| 2.13 | Lọc HS đã liên kết PH khác | `parent_student_management_view.dart` | Dropdown chỉ HS chưa có PH hoặc theo rule nghiệp vụ |
| 2.14 | Gỡ route HeadOfDept | `app_router.dart`, `head_of_dept_home_view.dart` | `/head/parent-student`, `/head/student-classes` bị loại |

**Kết quả Phase 2:** TKB + phân công + phân lớp ổn định, không bug P0, HeadOfDept scope đúng.

---

## Phase 3 — Điểm danh + Nhập/xem điểm → 100%

### 3A. Điểm danh Giáo viên (gap lớn nhất — SRS §3.3)

| # | Task | File mới / sửa | Acceptance criteria |
|---|------|----------------|---------------------|
| 3.1 | Controller điểm danh GV | `teacher_attendance_controller.dart` | Load tiết GV được phân công; load HS lớp; POST/PUT bulk |
| 3.2 | Màn điểm danh GV | `teacher_attendance_view.dart` | Chọn ngày/tiết → danh sách HS → P/A/L + ghi chú → Lưu |
| 3.3 | API integration | Controller | `GET /api/attendance/by-timetable/{id}`, `POST /api/attendance/bulk`, `PUT /api/attendance/bulk` |
| 3.4 | Sửa quick action GV | `teacher_home_view.dart` | Attendance → `TeacherAttendanceView` |
| 3.5 | Map trạng thái thống nhất | `attendance_model.dart`, views | `P`/`A`/`L` ↔ hiển thị tiếng Việt nhất quán |
| 3.6 | Sửa `attendanceRate` | `student_attendance_controller.dart` | Tỷ lệ tính có mặt + muộn (hoặc ghi rõ công thức trên UI) |

### 3B. Nhập điểm GV — hoàn thiện

| # | Task | File | Acceptance criteria |
|---|------|------|---------------------|
| 3.7 | Thêm ô nhận xét | `teacher_grade_entry_view.dart` | Gửi `comment` lên API |
| 3.8 | Max điểm động | `teacher_grade_entry_view.dart` | Lấy từ assessment/type, không hardcode 10 |
| 3.9 | Validate 0–max trước lưu | `teacher_grade_entry_controller.dart` | Chặn điểm âm / vượt max |
| 3.10 | Bind `isSaving` | `teacher_grade_entry_view.dart` | Disable nút Lưu khi đang gửi |
| 3.11 | Việt hóa label | `teacher_grade_entry_view.dart` | Label tiếng Việt thống nhất app |

### 3C. Xem điểm HS + PH (SRS §3.4)

| # | Task | File | Acceptance criteria |
|---|------|------|---------------------|
| 3.12 | Refactor `StudentGradeController` | `student_grade_controller.dart` | Nhận `targetStudentId` (giống pattern attendance) |
| 3.13 | PH xem bảng điểm con | `parent_home_view.dart`, routing | Quick action "Xem bảng điểm" → `StudentGradeView` với `studentId` con |
| 3.14 | Sửa preview card điểm | `student_grade_view.dart` | Filter theo `assessmentTypeId` / tên tiếng Việt, không keyword `'mid'`/`'final'` |
| 3.15 | Hiện comment trên chi tiết | `student_grade_detail_view.dart` | Hiển thị `comment` nếu có |

### 3D. Tab Lớp học Giáo viên

| # | Task | File mới / sửa | Acceptance criteria |
|---|------|----------------|---------------------|
| 3.16 | Màn lớp của tôi | `teacher_classes_view.dart` + controller | Danh sách phân công GV: lớp + môn + học kỳ |
| 3.17 | Shortcut từ tab Lớp | `teacher_main_view.dart` | Tap lớp → Điểm danh / Nhập điểm |
| 3.18 | TKB GV đúng API | `timetable_controller.dart` | Role teacher dùng `weekly/by-teacher/{id}` |

**Kết quả Phase 3:** GV điểm danh được; PH xem điểm được; nhập điểm đủ field; tab Lớp GV có nghiệp vụ thật.

---

## Phase 4 — Polish & QA chéo module

| # | Task | Mô tả |
|---|------|-------|
| 4.1 | Pull-to-refresh | Các màn list admin chính |
| 4.2 | Loading khi submit form | Tránh double-submit |
| 4.3 | Empty state thống nhất | Copy tiếng Việt, icon, nút retry |
| 4.4 | `flutter analyze` | Không warning mới |
| 4.5 | Test matrix 5 role | Checklist bên dưới |

### Ma trận test thủ công

| Role | Kịch bản | Module |
|------|----------|--------|
| Admin | CRUD năm học → học kỳ → lớp → phân công → sinh TKB | 1, 2 |
| Admin | Khóa user, thêm HS vào lớp, link PH–HS | 1, 2 |
| HeadOfDept | Chỉ thấy GV/phân công/TKB tổ mình | 1, 2 |
| Teacher | Điểm danh 1 tiết, nhập điểm bulk, xem TKB | 3 |
| Teacher | Tab Lớp → shortcut điểm danh/nhập điểm | 3 |
| Student | Xem điểm + TKB + điểm danh | 3 |
| Parent | Chọn con → xem điểm + điểm danh + TKB | 3 |

> Chi tiết từng bước, error path và checkbox tick trong Preview: **[MOBILE_TEST_MATRIX.md](./MOBILE_TEST_MATRIX.md)**

---

## Phase 5 — Cập nhật tài liệu (sau khi code xong)

| File | Nội dung cập nhật |
|------|-------------------|
| `docs/MOBILE_PROGRESS.md` | §3: 3 module lên **100%**; §5: chuyển mục đã xong; §10: log phiên bản |
| `docs/MOBILE_COMPLETION_PLAN.md` | Đánh dấu task done; ghi ngày hoàn thành |
| `docs/API_DESIGN.md` | (Nếu thêm PUT phân công / điều chỉnh HeadOfDept Write) |

---

## 4. Phụ thuộc Backend (cần xác nhận trước Phase 1–3)

| API | Trạng thái cần | Ảnh hưởng |
|-----|----------------|-----------|
| `PUT /api/teachingassignment/{id}` | Có hoặc bỏ UI Sửa | Phase 0.2 |
| `GET /api/departments/{id}/teachers` | Có | Phase 1.8 |
| `GET /api/departments/{id}/assignments` | Có | Phase 1.9 |
| `PUT /api/admin/users/{id}/status` | Có | Phase 1.11 |
| Login response có `departmentId` | Có | Phase 1.1 |
| `POST/PUT /api/attendance/bulk` | Có & ổn định | Phase 3.1–3.3 |
| `GET /api/timetable/weekly/by-teacher/{id}` | Có | Phase 3.18 |

> Nếu endpoint HeadOfDept §7 chưa có trên backend → ưu tiên implement API trước hoặc filter client tạm (teacher theo `departmentId`).

---

## 5. Checklist tổng hợp (copy vào issue tracker)

### Module 1: Admin / HeadOfDept master data
- [x] 1.1–1.4 RBAC HeadOfDept + dashboard
- [x] 1.5–1.7 Lọc theo tổ
- [x] 1.8–1.9 Màn HeadOfDept mới
- [x] 1.11–1.17 Hoàn thiện Admin CRUD + dashboard

### Module 2: TKB + Phân công + Phân lớp
- [x] 0.2–0.3, 0.5 Bug P0 TKB/phân công *(0.1 giữ nút test — không làm)*
- [x] 2.1–2.5 TKB quản lý
- [x] 2.6–2.8 Phân công
- [x] 2.9–2.10 Phân lớp *(2.11–2.12 optional — chưa làm)*
- [x] 2.13–2.14 PH–HS Admin only

### Module 3: Điểm danh + Nhập/xem điểm
- [x] 0.4 Tạm sửa routing GV attendance → TeacherAttendanceView
- [x] 3.1–3.6 Điểm danh GV
- [x] 3.7–3.11 Nhập điểm hoàn thiện
- [x] 3.12–3.15 Xem điểm HS/PH
- [x] 3.16–3.18 Tab Lớp GV + TKB teacher

### Hoàn tất
- [x] 4.1–4.5 QA (`flutter analyze` pass)
- [x] 5 Cập nhật MOBILE_PROGRESS.md + API_DESIGN.md

---

## 6. Rủi ro & giảm thiểu

| Rủi ro | Mức | Giảm thiểu |
|--------|-----|------------|
| API HeadOfDept §7 chưa implement | Cao | Spike backend 0.5 ngày trước Phase 1 |
| Mâu thuẫn SRS vs API_DESIGN HeadOfDept | Trung bình | Chốt quyết định §2.1 với team, ghi vào ADR |
| Subject không có `DepartmentId` | Trung bình | Lọc qua GV thuộc tổ, không lọc qua môn |
| Phạm vi phình (bulk, lịch sử phân lớp) | Thấp | Đánh dấu Optional; không chặn 100% |

---

## 7. Lịch sử tài liệu

| Phiên bản | Ngày | Nội dung |
|-----------|------|----------|
| v1.1 | 09/07/2026 | Triển khai xong sprint — tick checklist §5, cập nhật MOBILE_PROGRESS |
| v1.0 | 09/07/2026 | Lập kế hoạch hoàn thiện 3 module 80–90% → 100% |

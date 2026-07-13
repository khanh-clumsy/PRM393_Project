# Changelog — FSchool (PRM393)

Ghi nhận các thay đổi đáng chú ý theo phiên **Mobile Completion Sprint** (07/2026).

**Tham chiếu:** [MOBILE_TEST_MATRIX.md](./MOBILE_TEST_MATRIX.md) · [API_DESIGN.md](./API_DESIGN.md)

---

## [Unreleased] — 13/07/2026

### Backend (API)

- **Academic context theo ngày:** Thêm `AcademicContextService` — resolve năm học / học kỳ / phân lớp theo `StartDate–EndDate` (không dùng `IsActive`).
- **Endpoints mới:**
  - `GET /api/academic-context/at-date?date=`
  - `GET /api/studentclass/by-student/{id}/enrollment?date=`
  - `GET /api/timetable/weekly/by-student/{id}?date=` — TKB tuần + enrollment + điểm danh cho mobile
- **Parent dashboard:** Resolve lớp con theo ngày tham chiếu thay vì `FirstOrDefault` mù.
- **Điểm danh bulk:** Map trạng thái `Present/Absent/Late/Excused` → `P/A/L/E` khi lưu DB.
- **User update:** Sửa `UpdateUserDto` + `UserService` — đổi tổ/phòng ban (`DepartmentId`) lưu đúng khi đổi role Teacher/HeadOfDept.
- **Năm học:** Sắp xếp danh sách theo thứ tự thời gian (`StartDate`).
- **Điểm HS:** `GradeRepository` lọc học kỳ theo tên tiếng Việt (GK/CK).

### Mobile (Flutter)

- **Giáo viên — điều hướng:** Bỏ tab Lớp học; gộp "Lớp học của tôi" vào Hành động nhanh (`teacher_my_classes_view.dart`); nav còn Trang chủ + Tài khoản.
- **Giáo viên — điểm danh:** Nút "Tất cả có mặt" / "Tất cả vắng mặt"; badge TKB "Chưa điểm danh" / "Đã quá hạn"; chỉ cho điểm danh tiết hôm nay.
- **Giáo viên — nhập điểm:** Việt hóa UI; validate điểm 0–10; gộp thành một nút **Lưu điểm** (bỏ Save Draft giả).
- **Học sinh:** Việt hóa giao diện; welcome app bar; TKB dùng endpoint `by-student` theo ngày.
- **Phụ huynh:** Dropdown quan hệ cố định (`parent_relationship_helper`); hiển thị mô tả quan hệ trên trang chủ; fix overflow dropdown trong dialog sửa liên kết.
- **TKB:** `timetable_controller` — HS/PH gọi `/api/timetable/weekly/by-student/{id}`.
- **Dev login:** Panel đăng nhập nhanh debug (`dev_login_panel.dart`, `dev_login_accounts.dart`).
- **Shared:** `api_error_helper`, `submit_guard_mixin`, `app_button`, `app_dialog_actions`.

### Đã gỡ / thay thế

- Báo cáo điểm tổ (FE + BE).
- `teacher_classes_view.dart` → thay bằng `teacher_my_classes_view.dart`.

- **PH–HS:** `ParentStudentService.CreateAsync` — chặn liên kết trùng / HS đã có PH (TC-A07).

### QA & Tests

- Ma trận test thủ công `MOBILE_TEST_MATRIX.md` — **đã test pass toàn bộ** (13/07/2026).
- **Integration tests API (40 tests, 206 total suite):**
  - `Integration/MobileTestMatrixIntegrationTests.cs` — luồng runtime (TKB, điểm danh, điểm, PH)
  - `Integration/MasterDataIntegrationTests.cs` — TC-A03 (năm học, lớp, môn, ca, xếp loại)
  - `Integration/TeachingAssignmentIntegrationTests.cs` — TC-A04
  - `Integration/TimetableMasterIntegrationTests.cs` — TC-A05 (template, sinh lịch, conflict, xóa)
  - `Integration/EnrollmentIntegrationTests.cs` — TC-A06, A07, A02 unlock, user department
  - `Integration/MasterDataE2EIntegrationTests.cs` — E2E-1 full chain master → vận hành

#### P1 — Integration tests sprint tiếp theo (chưa làm)

| Ưu tiên | Map TC | Nội dung | Ghi chú |
| ------- | ------ | -------- | ------- |
| P1 | TC-H02, H06 | HeadOfDept write scoped + guard ngoài tổ | Cần RBAC controller hoặc `WebApplicationFactory` |
| P1 | Parent dashboard | `GET /api/parentstudent/dashboard/{id}` resolve lớp theo ngày | HTTP integration |
| P1 | TC-S02 | GV nhập điểm → HS transcript/GPA | `GradeService.GetStudentTranscriptAsync` |
| P1 | TC-T06 | Map P/A/L/E xuyên role end-to-end | Đã có unit; nối integration |
| P1 | TC-A08 | Admin vs HeadOfDept phạm vi module | HTTP + JWT |
| P2 | E1–E5 | Error path mobile | Giữ manual |
| P2 | HTTP layer | `WebApplicationFactory` + auth headers | Refactor `Program.cs` partial |

---

## [v1.0] — 12/07/2026

- Khởi tạo ma trận test mobile Batch 2–5.
- Mobile Completion Sprint: TKB, phân công, phân lớp, điểm danh, nhập/xem điểm, polish Admin/HeadOfDept.

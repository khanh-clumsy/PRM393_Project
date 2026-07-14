# Ma trận test thủ công Mobile — FSchool

Kịch bản QA cho phạm vi **Mobile Completion Sprint** (Batch 2–5): TKB, phân công, phân lớp, điểm danh, nhập/xem điểm, Admin/HeadOfDept polish.

**Tham chiếu:** [MOBILE_PROGRESS.md](../MOBILE_PROGRESS.md) · [MOBILE_COMPLETION_PLAN.md](../MOBILE_COMPLETION_PLAN.md) · [API_DESIGN.md](../API_DESIGN.md)

**Cập nhật lần cuối:** 13/07/2026

> **Trạng thái QA:** Đã test thủ công **toàn bộ** kịch bản trong ma trận này (13/07/2026). Integration tests API (40 tests): `api/PRM393API.Tests/Integration/` · Changelog: [CHANGELOG.md](../CHANGELOG.md)

> **Cách tick:** Mở **Markdown Preview** (`Ctrl+Shift+V` / `Cmd+Shift+V`) → click trực tiếp vào ô `- [ ]`. Thay đổi được lưu vào file `.md` khi tick trong Preview (Cursor/VS Code).

---

## 1. Chuẩn bị môi trường

- [x] **0.1** API chạy (`dotnet run` trong `api/`) — Swagger/API phản hồi bình thường
- [x] **0.2** DB đã migrate + seed — có năm học, HK1, lớp 10A1/10A2, phân công, TKB mẫu
- [x] **0.3** Mobile `flutter run` (debug) — màn login có panel **Đăng nhập nhanh (dev)**
- [x] **0.4** Emulator Android → API `10.0.2.2:5088` — login không báo lỗi kết nối



### Tài khoản test

- **Dev Quick Login:** chỉ hiện khi chạy debug — cấu hình tại `mobile/lib/vn/edu/fpt/core/dev/dev_login_accounts.dart`
- **Mật khẩu chung (seed migration):** `12345678`
- **Seed gốc** (`api/Migrations/20260612042441_SeedData.cs`):


| Role       | Username  | SĐT seed   | Ghi chú             |
| ---------- | --------- | ---------- | ------------------- |
| Admin      | admin01   | 0901000001 | Toàn quyền          |
| HeadOfDept | hodept01  | 0901000002 | Tổ Văn              |
| Teacher    | teacher01 | 0901000003 | GVCN 10A1, dạy Toán |
| Student    | student01 | 0901000006 | Lớp 10A1            |
| Parent     | parent01  | 0912000001 | PH của student01    |


> Nếu Dev Quick Login fail: kiểm tra SĐT trong DB khớp file `dev_login_accounts.dart` hoặc dùng SĐT seed ở bảng trên.

---



## 2. ADMIN

Phạm vi: Batch 1 (master data, RBAC), Batch 2 (TKB/phân công/phân lớp), Batch 4 (polish).

### TC-A01 · Dashboard thống kê


|              |                                                                           |
| ------------ | ------------------------------------------------------------------------- |
| **Màn hình** | Tab Dashboard / `admin_dashboard_view.dart`                               |
| **Bước**     | 1. Dev login → Admin 2. Mở tab Dashboard                                  |
| **Kỳ vọng**  | Hiển thị số liệu tổng quan (user, lớp, môn…), không còn placeholder trống |


- [x] **Pass · TC-A01**



### TC-A02 · Khóa / mở tài khoản


|                |                                                                                                                          |
| -------------- | ------------------------------------------------------------------------------------------------------------------------ |
| **Màn hình**   | Tài khoản → `user_management_view.dart`                                                                                  |
| **Bước**       | 1. Chọn 1 user (vd. học sinh) 2. Khóa / toggle `isActive` 3. Đăng xuất → login user vừa khóa 4. Admin mở lại → login lại |
| **Kỳ vọng**    | User khóa không login được; mở lại login được                                                                            |
| **Error path** | Server trả lỗi → hiện message rõ (qua `api_error_helper`)                                                                |


- [x] **Pass · TC-A02**



### TC-A03 · Chuỗi master data


|                |                                                                                                                                                           |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Màn hình**   | Năm học, Học kỳ, Môn học, Lớp, Ca học, Xếp loại                                                                                                           |
| **Bước**       | 1. Năm học → xem/tạo 2. Học kỳ → gắn năm học 3. Môn học → kiểm tra `isActive` 4. Lớp → gắn năm + GVCN 5. Ca học → tạo slot 6. Xếp loại → nhập khoảng điểm |
| **Kỳ vọng**    | CRUD hoạt động; form đủ trường hồ sơ user                                                                                                                 |
| **Error path** | Ngày HK ngoài năm học → client chặn · Slot overlap giờ → cảnh báo · Khoảng xếp loại trùng rank → cảnh báo                                                 |


- [x] **Pass · TC-A03**



### TC-A04 · Phân công giảng dạy


|              |                                                                                             |
| ------------ | ------------------------------------------------------------------------------------------- |
| **Màn hình** | Phân công GV → `teaching_assignment_management_view.dart`                                   |
| **Bước**     | 1. Chọn Năm / HK / Lớp 2. Thêm phân công (GV + môn) 3. Sửa phân công (PUT) 4. Thử tạo trùng |
| **Kỳ vọng**  | Thêm/sửa thành công; dropdown môn chỉ `isActive`; trùng → message server                    |


- [x] **Pass · TC-A04**



### TC-A05 · Thời khóa biểu quản lý


|                |                                                                                                                                                                                                                                                                                        |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Màn hình**   | Thời khóa biểu → `timetable_management_view.dart`                                                                                                                                                                                                                                      |
| **Bước**       | 1. Chọn Năm / HK / Lớp 2. Template: thêm tiết (thứ, slot, phân công, phòng) 3. Sửa template: chỉ đổi **GV/phân công + phòng** (thứ/tiết read-only) 4. Sinh lịch từ template 5. Cập nhật trạng thái: Bình thường / Đổi lịch / Nghỉ / Dạy bù + ghi chú 6. (Dev) Nút **Xóa lịch đã sinh** |
| **Kỳ vọng**    | Trạng thái tiết lưu đúng; hiện đủ tiết trong slot (không `.first` ẩn mất)                                                                                                                                                                                                              |
| **Error path** | *Ngày ngoài HK → client chặn · Trùng lịch GV/lớp cùng slot/ngày → cảnh báo trước lưu*                                                                                                                                                                                                  |


- [x] **Pass · TC-A05**



### TC-A06 · Phân lớp học sinh


|              |                                                                                          |
| ------------ | ---------------------------------------------------------------------------------------- |
| **Màn hình** | Phân lớp HS → `student_class_management_view.dart`                                       |
| **Bước**     | 1. Chọn năm / lớp 2. Thêm HS (search/dropdown) 3. Kiểm tra HS đã thuộc lớp khác cùng năm |
| **Kỳ vọng**  | Chỉ HS khả dụng; HS xuất hiện đúng lớp năm học                                           |


- [x] **Pass · TC-A06**



### TC-A07 · Phụ huynh – Học sinh


|              |                                                         |
| ------------ | ------------------------------------------------------- |
| **Màn hình** | Phụ huynh - HS → `parent_student_management_view.dart`  |
| **Bước**     | 1. Liên kết PH với HS 2. Thử liên kết HS đã có PH       |
| **Kỳ vọng**  | Dropdown lọc HS đã liên kết PH khác; lỗi server hiện rõ |


- [x] **Pass · TC-A07**



### TC-A08 · RBAC Admin toàn quyền


|             |                                                                             |
| ----------- | --------------------------------------------------------------------------- |
| **Bước**    | Vào Phân lớp HS, PH–HS, Tài khoản toàn trường                               |
| **Kỳ vọng** | Admin truy cập được tất cả; HeadOfDept không có các module này (xem TC-H01) |


- [x] **Pass · TC-A08**

---



## 3. TRƯỞNG BỘ MÔN (HeadOfDept)

Phạm vi: Batch 1 (RBAC scoped), Batch 2 (TKB/phân công trong tổ).

**Tài khoản gợi ý:** hodept01 — Tổ Văn (`departmentId = 2`)

### TC-H01 · Dashboard đúng phạm vi


|              |                                               |
| ------------ | --------------------------------------------- |
| **Màn hình** | `head_of_dept_home_view.dart`                 |
| **Bước**     | Dev login → Trưởng BM → xem menu              |
| **Kỳ vọng**  | Chỉ có: Lớp học, Phân công, TKB, Giáo viên tổ |
| **Không có** | Phân lớp HS, PH–HS, Quản lý user toàn trường  |


- [x] **Pass · TC-H01**



### TC-H02 · Lớp / Phân công / TKB scoped theo tổ


|             |                                                                                            |
| ----------- | ------------------------------------------------------------------------------------------ |
| **Bước**    | 1. Lớp học → so với Admin 2. Phân công → dropdown GV chỉ tổ mình 3. TKB → lớp/môn thuộc tổ |
| **Kỳ vọng** | Dữ liệu ít hơn Admin; không thấy phân công/TKB tổ khác                                     |


- [x] **Pass · TC-H02**



### TC-H03 · Giáo viên tổ


|              |                                               |
| ------------ | --------------------------------------------- |
| **Màn hình** | Giáo viên tổ → `head_dept_teachers_view.dart` |
| **API**      | `GET /api/departments/{id}/teachers`          |
| **Kỳ vọng**  | Chỉ GV thuộc tổ (vd. teacher02 — Tổ Văn)      |


- [x] **Pass · TC-H03**



### TC-H04 · Phân công tổ


|              |                                                  |
| ------------ | ------------------------------------------------ |
| **Màn hình** | Phân công tổ → `head_dept_assignments_view.dart` |
| **API**      | `GET /api/departments/{id}/assignments`          |
| **Kỳ vọng**  | Chỉ phân công GV tổ mình                         |


- [x] **Pass · TC-H04**



### TC-H06 · Write trong phạm vi tổ


|             |                                                                       |
| ----------- | --------------------------------------------------------------------- |
| **Bước**    | 1. Tạo/sửa phân công trong tổ 2. Sửa TKB lớp thuộc tổ                 |
| **Kỳ vọng** | Thao tác thành công trong phạm vi; lỗi ngoài phạm vi → message server |


- [x] **Pass · TC-H06**

---



## 4. GIÁO VIÊN

Phạm vi: Batch 2 (TKB `by-teacher`), Batch 3 (điểm danh, nhập điểm, tab Lớp).

**Tài khoản gợi ý:** teacher01 — GVCN 10A1, dạy Toán

### TC-T01 · Thời khóa biểu giáo viên


|              |                                                                                                          |
| ------------ | -------------------------------------------------------------------------------------------------------- |
| **Màn hình** | Trang chủ → Thời khóa biểu → `timetable_view.dart`                                                       |
| **API**      | `GET /api/timetable/weekly/by-teacher/{id}`                                                              |
| **Bước**     | 1. Xem TKB tuần 2. Chạm 1 tiết                                                                           |
| **Kỳ vọng**  | Hiện tiết được phân công; tên **lớp** (không phải tên GV); chạm tiết → mở Điểm danh pre-select ngày/tiết |


- [x] **Pass · TC-T01**



### TC-T02 · Điểm danh (flow đầy đủ)


|                |                                                                                                                                                              |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Màn hình**   | `teacher_attendance_view.dart`                                                                                                                               |
| **Bước**       | 1. Trang chủ → Điểm danh (hoặc từ TKB chạm tiết) 2. Chọn ngày 3. Chọn tiết 4. Đánh dấu P/A/L + ghi chú 5. **Tất cả có mặt** → Lưu 6. Thoát vào lại cùng tiết |
| **Kỳ vọng**    | Header: môn, lớp, ngày, slot, phòng; thống kê Có mặt/Vắng/Muộn; dữ liệu giữ sau reload                                                                       |
| **API**        | `GET /api/attendance/by-timetable/{id}`, `POST/PUT /api/attendance/bulk`                                                                                     |
| **Error path** | Ngày không có tiết → empty / thông báo phù hợp                                                                                                               |


- [x] **Pass · TC-T02**



### TC-T03 · Tab Lớp của tôi


|              |                                                                                  |
| ------------ | -------------------------------------------------------------------------------- |
| **Màn hình** | Hành động nhanh → `teacher_my_classes_view.dart`                                 |
| **Bước**     | 1. Lọc Năm học + Học kỳ 2. Kiểm tra danh sách lớp-môn 3. Thử 3 nút trên mỗi card |
| **Kỳ vọng**  | Không trùng lặp cùng lớp-môn; dedupe đúng                                        |



| Nút       | Hành vi kỳ vọng                                              |
| --------- | ------------------------------------------------------------ |
| Danh sách | Mở DS HS (STT, tên, mã) — `teacher_class_students_view.dart` |
| Điểm danh | Mở flow điểm danh                                            |
| Nhập điểm | Mở nhập điểm pre-select đúng lớp-môn-HK                      |


- [x] **Pass · TC-T03**



### TC-T04 · Nhập điểm


|                |                                                                                                                                                |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **Màn hình**   | `teacher_grade_entry_view.dart` (chỉ từ tab Lớp)                                                                                               |
| **Bước**       | 1. Tab Lớp → Nhập điểm 2. Kiểm tra dropdown đã chọn sẵn 3. Chọn loại điểm (KT miệng, 15 phút, 1 tiết…) 4. Nhập điểm + nhận xét 5. Lưu → reload |
| **Kỳ vọng**    | Lưu thành công; comment gửi API; max điểm theo loại                                                                                            |
| **Error path** | Điểm âm/vượt max → client chặn; nút Lưu disable khi `isSaving`                                                                                 |


- [x] **Pass · TC-T04**



### TC-T05 · Trang chủ GV — routing đúng


|                |                                             |
| -------------- | ------------------------------------------- |
| **Màn hình**   | `teacher_home_view.dart`                    |
| **Kỳ vọng**    | Có: TKB, Điểm danh, Lớp học của tôi         |
| **Không có**   | Bài tập                                     |
| **Ghi chú UI** | "Nhập điểm và quản lý lớp: vào tab Lớp học" |


- [x] **Pass · TC-T05**



### TC-T06 · Map trạng thái điểm danh (cross-role)


|             |                                                                |
| ----------- | -------------------------------------------------------------- |
| **Bước**    | Sau TC-T02 → login Student hoặc Parent → xem điểm danh         |
| **Kỳ vọng** | P/A/L hiển thị tiếng Việt nhất quán (`AttendanceStatusMapper`) |


- [x] **Pass · TC-T06**

---



## 5. HỌC SINH

Phạm vi: Batch 2 (TKB đúng năm học), Batch 3 (xem điểm, điểm danh).

**Tài khoản gợi ý:** student01 — Lớp 10A1

### TC-S01 · Thời khóa biểu


|              |                                                                        |
| ------------ | ---------------------------------------------------------------------- |
| **Màn hình** | Quick action Timetable → `timetable_view.dart`                         |
| **Kỳ vọng**  | TKB lớp đúng **năm học active** (lọc `StudentClasses`, không `[0]` mù) |


- [x] **Pass · TC-S01**



### TC-S02 · Xem điểm số


|              |                                                                                |
| ------------ | ------------------------------------------------------------------------------ |
| **Màn hình** | Grades → `student_grade_view.dart`, `student_grade_detail_view.dart`           |
| **Bước**     | 1. Xem GPA học kỳ 2. Vào chi tiết môn                                          |
| **Kỳ vọng**  | GK/CK lọc theo tên tiếng Việt; chi tiết có **comment** GV (nếu đã nhập TC-T04) |


- [x] **Pass · TC-S02**



### TC-S03 · Xem điểm danh


|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Màn hình** | Attendance → `attendance_view.dart`                             |
| **Kỳ vọng**  | `attendanceRate` = **Có mặt + Muộn**; trạng thái từng buổi đúng |


- [x] **Pass · TC-S03**



### TC-S04 · Ngoài phạm vi sprint (không đánh fail)


| Module       | Trạng thái hiện tại |
| ------------ | ------------------- |
| Đơn xin nghỉ | UI mock, chưa API   |
| Thông báo    | Dữ liệu giả         |


---



## 6. PHỤ HUYNH

Phạm vi: Batch 2 (TKB con), Batch 3 (điểm danh + bảng điểm con qua `targetStudentId`).

**Tài khoản gợi ý:** parent01 — PH của student01

### TC-P01 · Chọn con


|              |                                                              |
| ------------ | ------------------------------------------------------------ |
| **Màn hình** | `parent_home_view.dart`                                      |
| **Kỳ vọng**  | Hiện danh sách con từ `ParentStudents`; chọn con set context |


- [x] **Pass · TC-P01**



### TC-P02 · Xem TKB con


|             |                                                    |
| ----------- | -------------------------------------------------- |
| **Bước**    | Quick action Timetable                             |
| **Kỳ vọng** | TKB của **con đang chọn**, không phải tài khoản PH |


- [x] **Pass · TC-P02**



### TC-P03 · Xem điểm danh con


|              |                                                        |
| ------------ | ------------------------------------------------------ |
| **Màn hình** | Attendance                                             |
| **Kỳ vọng**  | `targetStudentId` = con; attendanceRate đúng công thức |


- [x] **Pass · TC-P03**



### TC-P04 · Xem bảng điểm con


|              |                                                        |
| ------------ | ------------------------------------------------------ |
| **Màn hình** | Quick action Xem bảng điểm → `student_grade_view.dart` |
| **Kỳ vọng**  | Điểm của con; GK/CK tiếng Việt; chi tiết có comment    |


- [x] **Pass · TC-P04**



### TC-P05 · Đổi con


|             |                                         |
| ----------- | --------------------------------------- |
| **Bước**    | Chọn con khác (nếu có nhiều con)        |
| **Kỳ vọng** | TKB / điểm / điểm danh đổi theo con mới |


- [x] **Pass · TC-P05**

---



## 7. Luồng test end-to-end (khuyến nghị)

Chạy **1 lần** theo thứ tự sau để verify dữ liệu xuyên suốt các role:

- [x] **E2E-1** Admin — phân công GV + sinh TKB + phân lớp HS + link PH–HS
- [x] **E2E-2** Teacher — TKB → điểm danh 1 tiết → nhập điểm từ tab Lớp
- [x] **E2E-3** Student — xem TKB + điểm + điểm danh (thấy dữ liệu vừa tạo)
- [x] **E2E-4** Parent — chọn con → xem TKB + điểm + điểm danh (cùng dữ liệu)
- [x] **E2E-5** HeadOfDept — xem phân công / TKB trong phạm vi tổ
- [x] **E2E-6** Admin — khóa 1 user test → xác nhận không login được

---



## 8. Error path chung (mọi role)

- [x] **E1** Tắt API → thao tác bất kỳ — "Không thể kết nối…" / nút Thử lại
- [x] **E2** Token hết hạn — refresh hoặc redirect về login
- [x] **E3** Server 400/409 — hiện `message` từ API, không crash
- [x] **E4** List rỗng — empty state + retry
- [x] **E5** Submit form 2 lần liên tiếp — không duplicate (loading/disable)

---



## 9. Checklist tổng hợp theo Batch



### Batch 2 — TKB, phân công, phân lớp

- [x] **B2-1** TKB trạng thái tiết, validate HK, cảnh báo trùng *(Admin)*
- [x] **B2-2** Sửa template (GV+phòng), sinh/xóa lịch dev *(Admin)*
- [x] **B2-3** Phân công PUT, lọc môn active, lỗi trùng *(Admin)*
- [x] **B2-4** Phân lớp HS, lọc HS khả dụng *(Admin)*
- [x] **B2-5** PH–HS, lọc HS đã liên kết *(Admin)*
- [x] **B2-6** Scope tổ: lớp, phân công, TKB *(HeadOfDept)*
- [x] **B2-7** TKB đúng năm học *(Student)*
- [x] **B2-8** TKB `by-teacher` *(Teacher)*



### Batch 3 — Điểm danh & điểm số

- [x] **B3-1** Điểm danh GV full flow *(Teacher)*
- [x] **B3-2** Tab Lớp + shortcut 3 nút *(Teacher)*
- [x] **B3-3** Nhập điểm từ tab Lớp *(Teacher)*
- [x] **B3-4** Xem điểm + GK/CK tiếng Việt *(Student)*
- [x] **B3-5** attendanceRate (có mặt + muộn) *(Student)*
- [x] **B3-6** Xem điểm/điểm danh con *(Parent)*



### Batch 4 — Admin polish

- [x] **B4-1** Khóa/mở user *(Admin)*
- [x] **B4-2** Dashboard thống kê *(Admin)*
- [x] **B4-3** Parse lỗi server thống nhất *(All)*



### Batch 5 — QA & docs

- [x] **B5-1** `flutter analyze` pass
- [x] **B5-2** Docs cập nhật (`MOBILE_PROGRESS`, `MOBILE_COMPLETION_PLAN`, `API_DESIGN`, `CHANGELOG`)

---



## 10. Ngoài phạm vi — không đánh fail sprint

Các module sau **chưa hoàn thiện** theo [MOBILE_PROGRESS.md](./MOBILE_PROGRESS.md) §6:

- Đơn xin nghỉ API thật / duyệt đơn GV
- Học bạ điện tử / GVCN chốt GPA & Hạnh kiểm
- Đổi mật khẩu / quên mật khẩu
- Push notification (FCM)
- Chat / tab Tin nhắn HS

Smoke check scope removal:

- [ ] Student home and quick actions do not show Bài tập.
- [ ] Teacher home does not show Bài tập; teacher can still open Lớp học của tôi → Nhập điểm.

---



## 11. Ghi nhận kết quả QA


| Người test | Ngày       | Build/commit | Pass | Fail | Ghi chú                                      |
| ---------- | ---------- | ------------ | ---- | ---- | -------------------------------------------- |
| Manual QA  | 13/07/2026 | local        | Tất cả | 0    | Toàn bộ TC + E2E + Batch checklist đã pass   |


**Bug template:**

```
TC-ID:
Role:
Bước tái hiện:
Kỳ vọng:
Thực tế:
Screenshot/log:
```

---



## 12. Lịch sử tài liệu


| Phiên bản | Ngày       | Nội dung                                                                 |
| --------- | ---------- | ------------------------------------------------------------------------ |
| v1.2      | 13/07/2026 | Đánh dấu toàn bộ đã test; thêm integration tests API; link CHANGELOG      |
| v1.1      | 12/07/2026 | Chuyển checkbox sang `- [ ]` tick được trong Markdown Preview             |
| v1.0      | 12/07/2026 | Khởi tạo ma trận test Batch 2–5 theo Mobile Completion Sprint             |



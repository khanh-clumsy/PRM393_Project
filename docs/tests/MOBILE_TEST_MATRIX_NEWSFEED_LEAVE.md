# Ma trận test thủ công Mobile — Bảng tin & Đơn xin nghỉ

Kịch bản QA cho sprint **Bảng tin & Thông báo** + **Đơn xin nghỉ** trên Flutter (`mobile/`).

**Tham chiếu:** [MOBILE_PROGRESS.md](../MOBILE_PROGRESS.md) · [Implementation Plan](../superpowers/plans/2026-07-13-mobile-newsfeed-leave-requests.md) · [API_DESIGN.md](../API_DESIGN.md) · [SRS.md](../SRS.md) §3.4–3.5

**Cập nhật lần cuối:** 14/07/2026

> **Phạm vi file này:** Chỉ module Bảng tin/Thông báo và Đơn xin nghỉ. **Không** thay thế [MOBILE_TEST_MATRIX.md](./MOBILE_TEST_MATRIX.md) (sprint Completion trước đó).

> **Cách tick:** Mở **Markdown Preview** (`Ctrl+Shift+V`) → click vào `- [ ]`. Thay đổi được lưu vào file khi tick trong Preview.

---

## 1. Chuẩn bị môi trường

- [ ] **0.1** API chạy (`dotnet run` trong `api/`) — Swagger phản hồi bình thường
- [ ] **0.2** DB đã migrate + seed — có lớp 10A1, student01 thuộc 10A1, teacher01 GVCN 10A1
- [ ] **0.3** Mobile `flutter run` (debug) — login có panel **Đăng nhập nhanh (dev)**
- [ ] **0.4** Emulator Android → API `10.0.2.2:5088` — không lỗi kết nối
- [ ] **0.5** `flutter test` pass — ít nhất `notification_log_model_test`, `student_request_model_test`

### Tài khoản test

| Role       | Username  | SĐT seed   | Ghi chú                          |
| ---------- | --------- | ---------- | -------------------------------- |
| Admin      | admin01   | 0901000001 | Đăng tin toàn trường             |
| Teacher    | teacher01 | 0901000003 | GVCN 10A1, duyệt đơn nghỉ        |
| Student    | student01 | 0901000006 | Lớp 10A1                         |
| Parent     | parent01  | 0912000001 | PH của student01                 |

**Mật khẩu seed:** `12345678`

### Dữ liệu nền trước khi test (setup một lần)

Thực hiện bằng **admin01** trên mobile hoặc Swagger:

- [ ] **0.6** Tạo ít nhất **1 tin toàn trường** (`announcementType = Global`, priority `Normal`)
- [ ] **0.7** Tạo ít nhất **1 tin khẩn** (`priority = Urgent`) để kiểm tra icon/badge
- [ ] **0.8** (Tuỳ chọn) Tạo `NotificationLog` cho student01 qua Swagger `POST /api/notificationlog` — nếu seed chưa có log hệ thống

---

## 2. ADMIN — Bảng tin (smoke regression)

Đảm bảo CRUD Admin vẫn hoạt động sau khi refactor phần đọc.

### TC-AN01 · CRUD bảng tin Admin

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Màn hình** | Admin → Bảng tin → `announcement_management_view.dart`          |
| **Bước**     | 1. Xem danh sách 2. Tạo tin Global 3. Sửa tiêu đề 4. Xóa tin   |
| **Kỳ vọng**  | CRUD thành công; snackbar xác nhận; list refresh sau mỗi thao tác |
| **API**      | GET/POST/PUT/DELETE `/api/announcement`                         |

- [ ] **Pass · TC-AN01**

### TC-AN02 · Tin Global hiển thị cho HS

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Tiền đề**  | TC-AN01 — có tin Global vừa tạo                                 |
| **Bước**     | Login **student01** → Trang chủ / Thông báo tab **Trường & Lớp** |
| **Kỳ vọng**  | Tin Global xuất hiện trên feed; không còn dữ liệu mock cứng    |

- [ ] **Pass · TC-AN02**

---

## 3. GIÁO VIÊN — Bảng tin lớp & Duyệt đơn

**Tài khoản:** teacher01

### TC-TN01 · Đăng thông báo lớp

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Màn hình** | Trang chủ GV → **Đăng thông báo lớp** → `teacher_class_announcement_view.dart` |
| **Bước**     | 1. Chọn lớp 10A1 2. Nhập tiêu đề + nội dung 3. Gửi              |
| **Kỳ vọng**  | Snackbar thành công; `POST /api/announcement` với `announcementType = Class`, `targetClassIds` chứa classId 10A1 |
| **Error path** | Bỏ trống tiêu đề → validation client chặn                    |

- [ ] **Pass · TC-TN01**

### TC-TN02 · HS cùng lớp thấy tin lớp

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Tiền đề**  | TC-TN01                                                         |
| **Bước**     | Login **student01** → Thông báo → tab **Trường & Lớp**          |
| **Kỳ vọng**  | Tin lớp vừa đăng hiển thị; HS lớp khác (nếu có) **không** thấy |

- [ ] **Pass · TC-TN02**

### TC-TL01 · Xem danh sách đơn chờ duyệt

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Tiền đề**  | student01 đã gửi ít nhất 1 đơn `Pending` (xem TC-SL01)        |
| **Màn hình** | Trang chủ GV → **Duyệt đơn nghỉ** → `teacher_leave_review_view.dart` |
| **Bước**     | Mở màn hình duyệt                                               |
| **Kỳ vọng**  | Hiển thị đơn Pending; thông tin ngày nghỉ, lý do, tên HS (hoặc studentId) |
| **API**      | `GET /api/studentrequest/pending`                               |

- [ ] **Pass · TC-TL01**

### TC-TL02 · Duyệt đơn (Approved)

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Bước**     | 1. Chọn đơn Pending 2. Nhấn **Duyệt**                         |
| **Kỳ vọng**  | Đơn biến mất khỏi list pending; API `PUT .../review` body `status: Approved` |
| **Cross-check** | Login student01 → tab Đơn nghỉ → status **Đã duyệt**        |

- [ ] **Pass · TC-TL02**

### TC-TL03 · Từ chối đơn (Rejected)

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Bước**     | 1. HS gửi đơn mới 2. GV nhấn **Từ chối** + nhập ghi chú        |
| **Kỳ vọng**  | HS thấy status **Từ chối**; hiển thị `reviewNote` nếu có       |
| **API**      | `PUT .../review` body `status: Rejected`, `reviewNote` không rỗng |

- [ ] **Pass · TC-TL03**

### TC-TL04 · Danh sách pending rỗng

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Tiền đề**  | Không còn đơn Pending                                           |
| **Kỳ vọng**  | Empty state rõ ràng (không crash, không spinner vô hạn)         |

- [ ] **Pass · TC-TL04**

---

## 4. HỌC SINH — Thông báo & Bảng tin

**Tài khoản:** student01

### TC-SN01 · Tab Trường & Lớp — feed từ API

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Màn hình** | Icon chuông / `notifications_view.dart` → tab **Trường & Lớp**  |
| **Kỳ vọng**  | Danh sách từ API; **không** còn mock "Thay đổi lịch học Toán" |
| **Loading**  | Có indicator khi tải; lỗi mạng → message qua `ApiErrorHelper`   |

- [ ] **Pass · TC-SN01**

### TC-SN02 · Tab Hệ thống — notification log

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Màn hình** | `notifications_view.dart` → tab **Hệ thống**                    |
| **Kỳ vọng**  | Danh sách từ `GET /api/notificationlog/by-user/{userId}`        |
| **Empty**    | Nếu chưa có log → empty state "Không có thông báo"              |

- [ ] **Pass · TC-SN02**

### TC-SN03 · Đánh dấu đã đọc (từng item)

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Tiền đề**  | Có ít nhất 1 thông báo hệ thống `isRead = false`               |
| **Bước**     | Tap vào item chưa đọc                                           |
| **Kỳ vọng**  | Item chuyển sang đã đọc; gọi `PUT /api/notificationlog/{id}/read` |
| **UI**       | Chấm đỏ / nền highlight biến mất                                |

- [ ] **Pass · TC-SN03**

### TC-SN04 · Đọc hết

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Bước**     | Tab Hệ thống → nhấn **Đọc hết**                                 |
| **Kỳ vọng**  | Tất cả item chưa đọc → đã đọc; snackbar xác nhận                |

- [ ] **Pass · TC-SN04**

### TC-SN05 · Badge chưa đọc trên AppBar

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Màn hình** | `student_home_view.dart` — `StudentWelcomeAppBar`               |
| **Tiền đề**  | Có notification chưa đọc                                        |
| **Kỳ vọng**  | Badge đỏ hiện khi `unreadCount > 0`; ẩn khi = 0               |
| **Bước**     | Đọc hết thông báo → quay lại trang chủ → badge biến mất         |

- [ ] **Pass · TC-SN05**

### TC-SN06 · Tin tức trang chủ

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Màn hình** | `student_home_view.dart` — section **Tin tức trường**         |
| **Kỳ vọng**  | Hiển thị tối đa ~3 tin mới nhất từ `AnnouncementFeedController` |
| **Thời gian** | `timeAgo` định dạng tiếng Việt (vd. "2 giờ trước")            |
| **Nút**      | "Xem tất cả" → mở `NotificationsPage`                         |

- [ ] **Pass · TC-SN06**

### TC-SN07 · Lọc bảng tin theo lớp

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Tiền đề**  | Có tin Global + tin lớp 10A1 + (nếu có) tin lớp khác           |
| **Kỳ vọng**  | student01 (10A1) thấy Global + tin 10A1; **không** thấy tin lớp khác |

- [ ] **Pass · TC-SN07**

---

## 5. HỌC SINH — Đơn xin nghỉ

**Tài khoản:** student01

### TC-SL01 · Tạo đơn mới

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Màn hình** | Tab Đơn nghỉ → **Tạo đơn mới** → `CreateLeaveRequestPage`       |
| **Bước**     | 1. Chọn ngày nghỉ (tương lai) 2. Nhập lý do 3. Gửi đơn         |
| **Kỳ vọng**  | Snackbar thành công; đơn mới đầu list với status **Chờ duyệt** |
| **API**      | `POST /api/studentrequest` — `studentId` = `requestedBy` = userId HS |
| **Validation** | Lý do trống → form báo lỗi                                  |

- [ ] **Pass · TC-SL01**

### TC-SL02 · Lịch sử đơn từ API

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Màn hình** | `leave_request_view.dart` — section **Lịch sử gần đây**        |
| **Kỳ vọng**  | List từ `GET /api/studentrequest/by-student/{studentId}`; không mock 2023 |
| **Sắp xếp** | Mới nhất trên cùng                                              |

- [ ] **Pass · TC-SL02**

### TC-SL03 · Hiển thị trạng thái đơn

| Status API  | Nhãn UI      | Màu badge (tham chiếu UI hiện tại) |
| ----------- | ------------ | ---------------------------------- |
| `Pending`   | Chờ duyệt    | Cam                                |
| `Approved`  | Đã duyệt     | Xanh                               |
| `Rejected`  | Từ chối      | Đỏ + hiện reviewNote nếu có        |

- [ ] **Pass · TC-SL03**

### TC-SL04 · Đính kèm URL minh chứng (tuỳ chọn)

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Bước**     | Tạo đơn kèm URL (vd. `https://example.com/giay-benh-vien.pdf`)   |
| **Kỳ vọng**  | `attachmentUrl` gửi lên API; hiển thị hoặc mở link được (nếu UI hỗ trợ) |
| **Ghi chú**  | Không test upload file — ngoài phạm vi sprint                    |

- [ ] **Pass · TC-SL04** · N/A nếu chưa có field URL trên form

### TC-SL05 · Error path — mất mạng khi gửi

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Bước**     | Tắt API / airplane mode → gửi đơn                               |
| **Kỳ vọng**  | Snackbar lỗi rõ; form không đóng; không thêm item giả vào list  |

- [ ] **Pass · TC-SL05**

---

## 6. PHỤ HUYNH

**Tài khoản:** parent01 (con: student01)

### TC-PN01 · Xem thông báo

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Màn hình** | `parent_home_view.dart` → icon chuông → `NotificationsPage`     |
| **Kỳ vọng**  | Feed hoạt động tương tự HS (tin Global + lớp con)               |

- [ ] **Pass · TC-PN01**

### TC-PL01 · Tạo đơn thay con

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Tiền đề**  | Đã chọn con student01 trên `parent_home_view`                   |
| **Bước**     | Mở **Đơn xin nghỉ** (quick action) → tạo đơn mới                |
| **Kỳ vọng**  | `studentId` = id con; `requestedBy` = id phụ huynh              |
| **UI**       | Subtitle/header ghi rõ đơn của con (tên HS)                     |

- [ ] **Pass · TC-PL01**

### TC-PL02 · Chưa chọn con

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Bước**     | Chưa chọn con → nhấn Đơn xin nghỉ                               |
| **Kỳ vọng**  | Snackbar "Vui lòng chọn con trước" — không crash                |

- [ ] **Pass · TC-PL02**

### TC-PL03 · Theo dõi trạng thái đơn con

|              |                                                                 |
| ------------ | --------------------------------------------------------------- |
| **Tiền đề**  | GV duyệt/từ chối đơn do PH tạo (TC-PL01 + TC-TL02/03)          |
| **Kỳ vọng**  | PH refresh list → thấy trạng thái cập nhật                      |

- [ ] **Pass · TC-PL03**

---

## 7. E2E — Luồng xuyên vai trò

### E2E-01 · Tin toàn trường: Admin → HS

| Bước | Vai trò   | Hành động                                      |
| ---- | --------- | ---------------------------------------------- |
| 1    | admin01   | Đăng tin Global "Kiểm tra học kỳ"              |
| 2    | student01 | Trang chủ + Thông báo → thấy tin vừa đăng      |

- [ ] **Pass · E2E-01**

### E2E-02 · Tin lớp: GV → HS

| Bước | Vai trò   | Hành động                                      |
| ---- | --------- | ---------------------------------------------- |
| 1    | teacher01 | Đăng tin lớp 10A1                              |
| 2    | student01 | Thấy tin trên feed                             |

- [ ] **Pass · E2E-02**

### E2E-03 · Đơn nghỉ: HS → GV duyệt → HS

| Bước | Vai trò   | Hành động                                      |
| ---- | --------- | ---------------------------------------------- |
| 1    | student01 | Gửi đơn nghỉ ngày mai                          |
| 2    | teacher01 | Duyệt đơn                                      |
| 3    | student01 | List đơn → **Đã duyệt**                        |

- [ ] **Pass · E2E-03**

### E2E-04 · Đơn nghỉ: PH → GV từ chối → PH

| Bước | Vai trò   | Hành động                                      |
| ---- | --------- | ---------------------------------------------- |
| 1    | parent01  | Gửi đơn cho con                                |
| 2    | teacher01 | Từ chối + ghi chú                              |
| 3    | parent01  | Thấy **Từ chối** + lý do GV                    |

- [ ] **Pass · E2E-04**

---

## 8. Unit test tự động (Flutter)

Chạy trước khi bàn giao QA thủ công:

```bash
cd mobile
flutter test
flutter analyze
```

| File test | Nội dung kiểm tra |
| --------- | ----------------- |
| `test/models/notification_log_model_test.dart` | Parse JSON notification log |
| `test/models/student_request_model_test.dart` | Parse JSON + `statusLabelVi` |
| `test/controllers/leave_request_controller_test.dart` | (nếu có) logic map status |

- [ ] **UT-01** `flutter test` — all pass
- [ ] **UT-02** `flutter analyze` — no error trên file đã sửa

---

## 9. Ngoài phạm vi (không đánh fail sprint)

| Hạng mục | Lý do |
| -------- | ----- |
| FCM push notification | Backlog MOBILE_PROGRESS §6 |
| Upload file minh chứng | Chỉ hỗ trợ URL text; không có API upload |
| Tab Tin nhắn HS | Out of scope SRS |
| Phân trang infinite scroll feed | Chưa yêu cầu SRS; list ngắn OK |

---

## 10. Ghi nhận kết quả QA

| Người test | Ngày | Build/commit | Pass | Fail | Ghi chú |
| ---------- | ---- | ------------ | ---- | ---- | ------- |
| Codex | 14/07/2026 | local main | 0 | 0 | Implement xong; Flutter test/analyze bị bỏ qua theo yêu cầu, QA thủ công/test tự động chạy sau. |

### Tổng hợp nhanh

| Nhóm | Số TC | Pass | Fail | N/A |
| ---- | ----- | ---- | ---- | --- |
| Admin (AN) | 2 | | | |
| GV Bảng tin (TN) | 2 | | | |
| GV Đơn nghỉ (TL) | 4 | | | |
| HS Thông báo (SN) | 7 | | | |
| HS Đơn nghỉ (SL) | 5 | | | |
| PH (PN/PL) | 4 | | | |
| E2E | 4 | | | |
| Unit test (UT) | 2 | | | |
| **Tổng** | **30** | | | |

---

## 11. Liên kết cập nhật docs sau khi pass

Khi toàn bộ TC pass:

1. Cập nhật [MOBILE_PROGRESS.md](../MOBILE_PROGRESS.md) — §3 % → 100%, chuyển §5 → §4
2. Ghi commit milestone vào §2 MOBILE_PROGRESS
3. **Không** gộp kết quả vào `MOBILE_TEST_MATRIX.md` — giữ file sprint riêng này

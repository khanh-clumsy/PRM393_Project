# AGENT.md — AI Agent Development Context & Rules

This document outlines the system architecture context, critical business logic rules, role constraints, and development guidelines for agentic codegen on the FSchool project.

---

## 💡 1. System Overview & Context

FSchool is an educational management portal designed to digitize academic communications between the school, teachers, students, and parents.
* **Backend:** ASP.NET Core 8 Web API.
* **Frontend:** Flutter Mobile Application.
* **Database:** SQL Server (using EF Core on the API side). The source of truth for the database schema is [001_init.sql](file:///c:/Code/PRM393_Project/api/sql/001_init.sql).

---

## 🔐 2. Strict Role-Based Access Control (RBAC) Rules

All API endpoints and business logic must enforce strict authorization checks based on user roles (`Roles` table):

### Quản trị viên (Admin - RoleId = 1)
* **Write/Modify Scope:** Full CRUD operations across all system configurations.
* **Academic setup:** Admin is the *only* role permitted to create classes, assign teachers to subjects/classes (`TeachingAssignments`), define semesters/academic years, and set up grading scales (`AcademicRanks`).
* **Announcements:** Admin manages global, school-wide news feed articles.

### Trưởng bộ môn (HeadOfDept - RoleId = 2)
* **Read-only Scope:** View-only access within their own department (`Users.DepartmentId`).
* **Quyền hạn:** Có thể xem danh sách giáo viên, thời khóa biểu, phân công giảng dạy, và báo cáo điểm số của các môn học thuộc tổ chuyên môn của mình.
* **Ràng buộc:** **Không được phép** tạo lớp học mới, sửa thời khóa biểu hoặc trực tiếp thực hiện phân công giảng dạy (không có POST/PUT endpoints cho các nghiệp vụ này được gán cho Trưởng bộ môn).
* **Kiêm nhiệm:** Nếu Trưởng bộ môn trực tiếp giảng dạy lớp nào đó, họ có các quyền của Giáo viên đối với lớp đó.

### Giáo viên (Teacher - RoleId = 3)
* **Nghiệp vụ cơ bản:** Lấy thời khóa biểu dạy học, thực hiện điểm danh (`AttendanceRecords`), nhập điểm môn học (`Grades`), giao và chấm bài tập (`Assignments`, `Submissions`), duyệt đơn xin nghỉ học của học sinh.
* **Giáo viên chủ nhiệm (GVCN):** Có độc quyền đối với lớp chủ nhiệm (được liên kết qua `Classes.HomeroomTeacherId`):
  * Đọc bảng tổng hợp điểm số lớp học.
  - Đánh giá xếp loại Hạnh kiểm học kỳ/cả năm.
  - Chốt điểm tổng kết GPA học kỳ/cả năm và ánh xạ xếp loại học lực (`AcademicRanks`) lưu trực tiếp xuống `StudentSemesterSummaries` và `StudentYearlySummaries`.

### Học sinh (Student - RoleId = 4) & Phụ huynh (Parent - RoleId = 5)
* **Read Scope:** Tra cứu thời khóa biểu, điểm số thành phần, điểm danh chuyên cần, thông báo bảng tin, và học bạ điện tử (semester/yearly summaries).
* **Write Scope:** Học sinh nộp bài tập (`Submissions`). Học sinh hoặc Phụ huynh có thể tạo đơn xin nghỉ học (`StudentRequests`).

---

## ⚠️ 3. Database Schema Design Constants

Agents must adhere strictly to these physical database rules defined in [001_init.sql](file:///c:/Code/PRM393_Project/api/sql/001_init.sql):

### 3.1. Lịch sử lớp học (StudentClasses)
* Bảng `Users` không lưu trực tiếp `ClassId` của học sinh.
* Mối quan hệ học sinh - lớp học được lưu trong bảng trung gian `StudentClasses (StudentClassId, StudentId, ClassId)`. Do `ClassId` đã gắn liền với `AcademicYearId`, cấu trúc này cho phép tra cứu chính xác học sinh đã học lớp nào trong bất kỳ năm học nào mà không lo bị ghi đè thông tin khi lên lớp mới.

### 3.2. Cột lọc bộ môn (DepartmentId)
* Cột `Users.DepartmentId` (chỉ áp dụng cho Giáo viên) đóng vai trò làm tag/filter phục vụ tìm kiếm trên UI hoặc kết xuất báo cáo tổ chuyên môn.
* Hệ thống **không ràng buộc cứng** (no hard foreign constraint validation blocking teaching assignments) để giữ cho nghiệp vụ phân công dạy học chéo bộ môn ở Backend được đơn giản.

### 3.3. Tránh tính toán on-the-fly (Summaries Tables)
* Các bảng `StudentSemesterSummaries` và `StudentYearlySummaries` lưu trữ cứng kết quả GPA, Hạnh kiểm và Xếp loại (`RankId`).
* Dữ liệu này được chốt sổ bởi Giáo viên chủ nhiệm. Khi hiển thị Học bạ điện tử, API lấy trực tiếp từ các bảng summaries này thay vì tính toán động từ bảng `Grades` nhằm tối ưu hóa hiệu năng hệ thống.

### 3.4. Token Indexes & Unique Constraints
* Bảng `RefreshTokens` bắt buộc phải được đánh `INDEX` trên hai cột `Token` và `UserId`. Khi truy vấn hoặc thu hồi token, luôn lọc theo các trường đã đánh index.
* Bảng `Semesters` áp dụng ràng buộc `UNIQUE (AcademicYearId, SemesterName)` để loại bỏ dữ liệu rác (tránh trùng lặp học kỳ trong cùng năm học).

---

## 🚫 4. Out of Scope Features
* **Chat module** (1-1 chat, group chat) đã được loại bỏ hoàn toàn. Tuyệt đối không sinh code, không thiết lập WebSocket hay tạo các bảng/endpoint liên quan đến nhắn tin.
* **HeadOfDept class updates:** Trưởng bộ môn tuyệt đối không có quyền write đối với cấu trúc lớp hay phân công giảng dạy.

---

## 🧪 5. Flutter Test Command Guidance
* Nếu `flutter test` bị treo, chạy quá lâu, hoặc không trả kết quả rõ ràng trong thời gian hợp lý, không tiếp tục lặp lại cùng một lệnh.
* Hãy tìm cách kiểm tra khác phù hợp hơn: chạy test file cụ thể, dùng `dart test` nếu áp dụng được, chạy `flutter analyze`, giới hạn test theo `--plain-name`, hoặc kiểm tra thủ công bằng `flutter run`/hot reload khi lỗi là UI layout.
* Khi phải bỏ qua một lệnh test vì bị treo, ghi rõ lệnh đã thử, hiện tượng gặp phải, và lệnh thay thế đã dùng để xác minh.

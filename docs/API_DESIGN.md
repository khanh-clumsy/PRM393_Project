# THIẾT KẾ HỆ THỐNG API (API DESIGN) - FSCHOOL

> [!NOTE]  
> Tài liệu này mô tả chi tiết danh sách các endpoint HTTP, phương thức (Method), cấu trúc dữ liệu yêu cầu (Request Body) và mô tả nghiệp vụ nhằm đồng bộ hoàn toàn với cơ sở dữ liệu và đặc tả yêu cầu SRS của hệ thống FSchool.

---

## 1. Module Xác thực & Tài khoản

Quản lý đăng nhập, cấp lại token và thông tin hồ sơ người dùng.

| Method | Endpoint | Quyền truy cập | Mô tả nghiệp vụ / Cấu trúc dữ liệu |
| :--- | :--- | :--- | :--- |
| **POST** | `/api/auth/login` | Public | Đăng nhập hệ thống.<br>- **Request Body:** `{ "username": "...", "password": "..." }`<br>- **Response:** Trả về JWT Access Token, Refresh Token và thông tin vai trò (`RoleId`, `RoleName`). |
| **POST** | `/api/auth/refresh` | Public | Cấp lại Access Token mới khi hết hạn sử dụng Refresh Token.<br>- **Request Body:** `{ "refreshToken": "..." }`<br>- **Response:** Trả về cặp Access Token và Refresh Token mới. |
| **POST** | `/api/auth/logout` | Đã đăng nhập | Đăng xuất hệ thống, hủy Refresh Token trên database. |
| **POST** | `/api/auth/forgot-password` | Public | Đệ trình yêu cầu quên mật khẩu.<br>- **Request Body:** `{ "email": "..." }` hoặc `{ "phoneNumber": "..." }` |
| **GET** | `/api/users/profile` | Đã đăng nhập | Lấy thông tin chi tiết hồ sơ cá nhân.<br>- **Response:** Trả về thông tin chi tiết: `UserId`, `Username`, `FullName`, `DateOfBirth`, `Gender`, `Address`, `Email`, `PhoneNumber`, `AvatarUrl`, `RoleId`, `DepartmentId`. |
| **PUT** | `/api/users/profile` | Đã đăng nhập | Cập nhật thông tin cá nhân.<br>- **Request Body:** `{ "fullName": "...", "dateOfBirth": "YYYY-MM-DD", "gender": "...", "address": "...", "email": "...", "phoneNumber": "...", "avatarUrl": "..." }` |
| **PUT** | `/api/users/password` | Đã đăng nhập | Đổi mật khẩu tài khoản.<br>- **Request Body:** `{ "oldPassword": "...", "newPassword": "..." }` |

---

## 2. Module Học tập & Tra cứu (Học sinh / Phụ huynh)

Xem thông tin lịch học, kết quả học tập và nộp bài.

| Method | Endpoint | Quyền truy cập | Mô tả nghiệp vụ / Cấu trúc dữ liệu |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/academic-context/at-date` | Đã đăng nhập | Xác định **năm học** và **học kỳ** tại một ngày tham chiếu.<br>- **Query:** `date` (YYYY-MM-DD, optional — mặc định hôm nay UTC).<br>- **Logic:** `StartDate <= date <= EndDate` (không dùng `IsActive`).<br>- **Response:** `{ referenceDate, academicYear: { id, name, startDate, endDate } \| null, semester: { ... } \| null }` |
| **GET** | `/api/studentclass/by-student/{studentId}/enrollment` | Đã đăng nhập | Phân lớp của học sinh tại ngày tham chiếu.<br>- **Query:** `date` (optional).<br>- **Logic:** (1) Suy năm học chứa `date` → (2) Tìm `StudentClasses` có `Class.AcademicYearId` khớp.<br>- **Response:** `{ referenceDate, academicYear, semester, enrollment: { studentClassId, studentId, studentName, studentCode, classId, className, academicYearId, academicYearName } \| null }` |
| **GET** | `/api/timetable/weekly/by-student/{studentId}` | Học sinh / Phụ huynh / Admin | **TKB tuần cho mobile** — BE tự resolve lớp + trả đủ dữ liệu hiển thị.<br>- **Query:** `date` (optional — ngày bất kỳ trong tuần cần xem).<br>- **Logic:** enrollment theo ngày → `weekly/by-class` → điểm danh HS trong tuần.<br>- **Response 200:** `{ studentId, referenceDate, weekStart, weekEnd, academicYear, semester, enrollment, slots: TimetableSlotDetailDto[], attendance: [{ attendanceId, timetableId, studentId, status, note, recordedBy, recordedAt }] }`<br>- **Response 404:** `{ message }` khi không có phân lớp tại ngày đó. |
| **GET** | `/api/parentstudent/dashboard/{parentId}` | Phụ huynh | Dashboard con — lớp resolve theo ngày (không còn `FirstOrDefault` mù).<br>- **Query:** `date` (optional).<br>- **Response:** `{ parentId, parentName, referenceDate, children: [{ parentStudentId, studentId, studentName, relationship, classId, className, academicYearId, academicYearName, enrollmentResolvedAt, attendanceToday }] }` |
| **GET** | `/api/students/{studentId}/timetable` | Học sinh / Phụ huynh | *(Legacy doc)* — **Thực tế mobile dùng** `/api/timetable/weekly/by-student/{studentId}`. |
| **GET** | `/api/students/{studentId}/grades` | Học sinh / Phụ huynh | Xem điểm trung bình các môn học trong học kỳ.<br>- **Query Parameters:** `semesterId` (bắt buộc). |
| **GET** | `/api/students/{studentId}/grades/{subjectId}` | Học sinh / Phụ huynh | Xem chi tiết toàn bộ điểm số thành phần (Miệng, 15 phút, 1 tiết, Giữa kỳ, Cuối kỳ) của một môn học cụ thể.<br>- **Query Parameters:** `semesterId` (bắt buộc). |
| **GET** | `/api/students/{studentId}/assignments` | Học sinh / Phụ huynh | Xem danh sách bài tập được giao.<br>- **Query Parameters:** `status` (Pending/Submitted/Graded), `semesterId`. |
| **POST** | `/api/students/{studentId}/assignments/{assignmentId}/submit` | Học sinh | Nộp bài làm cho bài tập đã giao.<br>- **Request Body:** `{ "contentText": "...", "fileUrl": "...", "linkUrl": "..." }` |
| **GET** | `/api/students/{studentId}/summaries/semester/{semesterId}` | Học sinh / Phụ huynh | Tra cứu điểm tổng kết học kỳ (GPA học kỳ, Hạnh kiểm, Học lực/Xếp loại dựa trên `RankId` và thông tin giáo viên đánh giá). |
| **GET** | `/api/students/{studentId}/summaries/yearly/{academicYearId}` | Học sinh / Phụ huynh | Tra cứu tổng kết học tập cả năm học (GPA cả năm, Hạnh kiểm cả năm, Xếp loại học lực cuối năm). |

---

## 3. Module Hành chính & Đơn từ

Quản lý đơn xin nghỉ học của học sinh.

| Method | Endpoint | Quyền truy cập | Mô tả nghiệp vụ / Cấu trúc dữ liệu |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/studentrequest/by-student/{studentId}` | Học sinh / Phụ huynh / Giáo viên | Xem lịch sử đơn xin nghỉ của học sinh.<br>- **Response:** `StudentRequestDto[]` có `studentName`, `requestedByName`, `leaveDate`, `reason`, `attachmentUrl`, `status`, `reviewNote`. |
| **POST** | `/api/studentrequest` | Học sinh / Phụ huynh | Tạo đơn xin nghỉ học. API lấy người gửi từ JWT, không tin `requestedBy` từ client.<br>- **Request Body:** `{ "studentId": 10, "requestedBy": 10, "leaveDate": "YYYY-MM-DD", "reason": "...", "attachmentUrl": "..." }`<br>- **Rule:** Student chỉ tạo cho chính mình; Parent chỉ tạo cho con đã liên kết. |
| **GET** | `/api/studentrequest/pending/for-teacher` | Giáo viên | Lấy đơn `Pending` của học sinh thuộc lớp giáo viên đang dạy. |
| **GET** | `/api/studentrequest/pending` | Admin / tương thích cũ | Lấy toàn bộ đơn `Pending`. Mobile giáo viên dùng endpoint scoped ở trên. |
| **PUT** | `/api/studentrequest/{requestId}/review` | Giáo viên | Phê duyệt hoặc từ chối đơn xin nghỉ học. API lấy `reviewedBy` từ JWT.<br>- **Request Body:** `{ "status": "Approved" / "Rejected", "reviewedBy": 3, "reviewNote": "..." }`<br>- **Rule:** Chỉ review đơn đang `Pending`; status chỉ `Approved` hoặc `Rejected`. |

---

## 4. Module Nghiệp vụ Giáo viên

Điểm danh, nhập điểm, giao bài tập, chấm điểm và đánh giá tổng kết cuối kỳ/năm.

| Method | Endpoint | Quyền truy cập | Mô tả nghiệp vụ / Cấu trúc dữ liệu |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/teachers/{teacherId}/classes` | Giáo viên | Lấy danh sách các lớp học được phân công giảng dạy hoặc chủ nhiệm trong học kỳ hiện tại. |
| **GET** | `/api/classes/{classId}/students` | Giáo viên | Xem danh sách học sinh của một lớp học cụ thể (bao gồm thông tin mã học sinh, họ tên, ngày sinh). |
| **GET** | `/api/classes/{classId}/students/{studentId}` | Giáo viên | Xem hồ sơ chi tiết của một học sinh trong lớp. |
| **POST** | `/api/classes/{classId}/attendance` | Giáo viên | Gửi điểm danh hàng loạt (Bulk entry) cho một buổi học cụ thể.<br>- **Request Body:** `{ "timetableId": 1, "attendanceDate": "YYYY-MM-DD", "records": [ { "studentId": 1, "status": "P"/"A"/"L", "note": "..." } ] }` |
| **GET** | `/api/classes/{classId}/attendance` | Giáo viên | Tra cứu lịch sử điểm danh của lớp.<br>- **Query Parameters:** `startDate`, `endDate`. |
| **POST** | `/api/classes/{classId}/grades` | Giáo viên | Nhập hoặc cập nhật điểm số hàng loạt cho học sinh theo cột đánh giá (`AssessmentId`).<br>- **Request Body:** `{ "assessmentId": 1, "grades": [ { "studentId": 1, "score": 8.5, "comment": "..." } ] }` |
| **POST** | `/api/classes/{classId}/assignments` | Giáo viên | Giao bài tập mới cho lớp học.<br>- **Request Body:** `{ "teachingAssignmentId": 1, "title": "...", "description": "...", "attachmentUrl": "...", "dueDate": "YYYY-MM-DD HH:mm:ss" }` |
| **PUT** | `/api/assignments/{assignmentId}` | Giáo viên | Cập nhật thông tin bài tập đã giao. |
| **DELETE** | `/api/assignments/{assignmentId}` | Giáo viên | Xóa bài tập đã giao (Soft delete, cập nhật cột `IsDeleted = 1`). |
| **GET** | `/api/assignments/{assignmentId}/submissions` | Giáo viên | Lấy danh sách bài làm học sinh đã nộp cho bài tập này. |
| **PUT** | `/api/submissions/{submissionId}/grade` | Giáo viên | Chấm điểm bài nộp và đưa ra nhận xét.<br>- **Request Body:** `{ "score": 9.0, "feedback": "..." }` |
| **POST** | `/api/classes/{classId}/newsfeed` | Giáo viên | Đăng thông báo/bài viết lên bảng tin lớp học. |
| **GET** | `/api/classes/{classId}/summaries/semester/{semesterId}` | Giáo viên (GVCN) | Lấy bảng tổng hợp kết quả học kỳ của học sinh lớp chủ nhiệm (GPA, Hạnh kiểm, Xếp loại). |
| **PUT** | `/api/classes/{classId}/students/{studentId}/summaries/semester/{semesterId}` | Giáo viên (GVCN) | GVCN đánh giá Hạnh kiểm và chốt xếp loại Học tập Học kỳ cho học sinh.<br>- **Request Body:** `{ "conduct": "Tốt" / "Khá" / "Trung Bình" / "Yếu", "rankId": 1 }` |
| **GET** | `/api/classes/{classId}/summaries/yearly/{academicYearId}` | Giáo viên (GVCN) | Lấy bảng tổng hợp kết quả cả năm học của học sinh lớp chủ nhiệm. |
| **PUT** | `/api/classes/{classId}/students/{studentId}/summaries/yearly/{academicYearId}` | Giáo viên (GVCN) | GVCN đánh giá Hạnh kiểm và chốt xếp loại Học tập Cả năm cho học sinh.<br>- **Request Body:** `{ "yearlyConduct": "...", "rankId": 1 }` |

---

## 5. Module Bảng tin & Thông báo

| Method | Endpoint | Quyền truy cập | Mô tả nghiệp vụ / Cấu trúc dữ liệu |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/announcement` | Admin / tương thích cũ | Danh sách bảng tin không scoped, dùng cho CRUD Admin. |
| **GET** | `/api/announcement/my-feed` | Đã đăng nhập | Feed mobile theo JWT: Student thấy Global + lớp đang học; Parent thấy Global + lớp của các con; Teacher thấy Global + lớp đang dạy; Admin thấy toàn bộ. Sort mới nhất trước. |
| **GET** | `/api/announcement/by-class/{classId}` | Đã đăng nhập | Bảng tin theo lớp, gồm cả tin Global. |
| **POST** | `/api/announcement` | Admin / Giáo viên | Đăng tin Global hoặc Class. Khi `targetClassIds` có lớp cụ thể, API fan-out `NotificationLog` cho học sinh và phụ huynh thuộc lớp đó. |
| **GET** | `/api/notificationlog/me` | Đã đăng nhập | Log thông báo của user hiện tại, lấy `userId` từ JWT. |
| **GET** | `/api/notificationlog/me/unread-count` | Đã đăng nhập | Badge unread cho mobile.<br>- **Response:** `{ "count": 3 }` |
| **PUT** | `/api/notificationlog/{notificationId}/read` | Đã đăng nhập | Đánh dấu một thông báo là đã đọc; chỉ update log thuộc user hiện tại. |
| **PUT** | `/api/notificationlog/me/read-all` | Đã đăng nhập | Đánh dấu toàn bộ log chưa đọc của user hiện tại. |

---

## 6. Module Quản trị Hệ thống (Admin)

Tài khoản Admin quản trị toàn bộ hệ thống, danh mục và cấu hình phân công học vụ.

| Method | Endpoint | Quyền truy cập | Mô tả nghiệp vụ / Cấu trúc dữ liệu |
| :--- | :--- | :--- | :--- |
| **POST** | `/api/admin/users` | Admin | Tạo mới tài khoản người dùng.<br>- **Request Body:** `{ "username": "...", "password": "...", "fullName": "...", "roleId": 1, "departmentId": 1, "dateOfBirth": "...", "gender": "...", "address": "...", "email": "...", "phoneNumber": "..." }` |
| **PUT** | `/api/admin/users/{userId}` | Admin | Cập nhật thông tin người dùng do Admin quản lý. |
| **PUT** | `/api/admin/users/{userId}/status` | Admin | Khóa hoặc kích hoạt lại tài khoản người dùng (`IsActive = 0/1`). |
| **POST** | `/api/admin/classes` | Admin | Tạo lớp học mới gắn với niên khóa và gán Giáo viên chủ nhiệm.<br>- **Request Body:** `{ "className": "...", "academicYearId": 1, "homeroomTeacherId": 3 }` |
| **POST** | `/api/admin/teaching-assignments` | Admin | Tạo phân công giảng dạy cho giáo viên.<br>- **Request Body:** `{ "teacherId": 3, "classId": 1, "subjectId": 1, "semesterId": 1 }` |
| **POST** | `/api/admin/timetables` | Admin | Xếp thời khóa biểu cho lớp học từ phân công giảng dạy.<br>- **Request Body:** `{ "teachingAssignmentId": 1, "dayOfWeek": 2, "slotId": 1, "roomName": "...", "effectiveFrom": "YYYY-MM-DD" }` |
| **POST** | `/api/admin/announcements/global` | Admin | Đăng tin tức/thông báo khẩn toàn trường. |
| **POST** | `/api/admin/departments` | Admin | Tạo tổ chuyên môn mới. |
| **PUT** | `/api/admin/departments/{id}` | Admin | Cập nhật tổ chuyên môn. |
| **DELETE** | `/api/admin/departments/{id}` | Admin | Xóa tổ chuyên môn. |
| **GET** | `/api/admin/academic-ranks` | Admin | Lấy danh sách mức xếp loại học lực. |
| **POST** | `/api/admin/academic-ranks` | Admin | Thiết lập/Cập nhật các thang điểm xếp loại học lực (Giỏi, Khá, Trung Bình, Yếu, Kém). |

---

## 7. Module Tổ chuyên môn (Dành cho Trưởng bộ môn - View-only)

Tài khoản Trưởng bộ môn theo dõi kết quả, lịch trình giảng dạy của các giáo viên thuộc tổ của mình.

| Method | Endpoint | Quyền truy cập | Mô tả nghiệp vụ / Cấu trúc dữ liệu |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/departments/{departmentId}/teachers` | Trưởng bộ môn | Xem danh sách các giáo viên thuộc tổ chuyên môn quản lý (Đồng bộ theo `DepartmentId`). |
| **GET** | `/api/departments/{departmentId}/assignments` | Trưởng bộ môn | Xem thông tin phân công giảng dạy của toàn bộ giáo viên trong tổ chuyên môn. |
| **PUT** | `/api/teachingassignment/{id}` | Admin, Trưởng bộ môn | Cập nhật phân công giảng dạy (teacherId, classId, subjectId, semesterId). Body: `UpdateTeachingAssignmentDto`. |

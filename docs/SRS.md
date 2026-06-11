# TÀI LIỆU ĐẶC TẢ YÊU CẦU PHẦN MỀM (SRS) - FSCHOOL

> [!NOTE]  
> Tài liệu này được biên soạn nhằm định nghĩa rõ ràng các yêu cầu chức năng, phi chức năng và kiến trúc nghiệp vụ của hệ thống Quản lý Học tập FSchool, đồng thời đồng bộ hoàn toàn với thiết kế cơ sở dữ liệu hiện tại.

---

## 1. Giới thiệu chung

- **Tên dự án:** Ứng dụng Quản lý & Giao tiếp Giáo dục FSchool (Mobile App & Web API Backend).
- **Nền tảng ứng dụng:** Android / iOS (Flutter mobile app) & .NET 8 Web API.
- **Mục đích:** Số hóa toàn bộ quy trình quản lý học tập, kết nối thông tin giữa Nhà trường, Giáo viên, Học sinh và Phụ huynh nhằm thay thế cho sổ liên lạc truyền thống.
- **Phạm vi hệ thống:** Quản lý thông tin hồ sơ, tổ chuyên môn, điểm danh chuyên cần, lịch học/lịch giảng dạy, phân công công tác, giao nhận bài tập, bảng tin thông báo và tổng kết kết quả học tập định kỳ (Học bạ điện tử).

---

## 2. Vai trò Người dùng & Phân quyền (RBAC)

Hệ thống phân quyền chặt chẽ dựa trên các vai trò cốt lõi. Trong đó, quyền hạn cụ thể bao gồm:

| Vai trò | Mô tả phạm vi & Quyền hạn chính |
| :--- | :--- |
| **Quản trị viên (Admin)** | Quyền hạn cao nhất. CRUD tài khoản người dùng, thiết lập năm học, kỳ học, lớp học, môn học. Thực hiện phân công giáo viên giảng dạy (`TeachingAssignments`), lập thời khóa biểu (`Timetables`), cấu hình bộ tiêu chuẩn xếp loại học lực (`AcademicRanks`), và đăng thông báo toàn trường. |
| **Trưởng bộ môn (HeadOfDept)** | Đại diện tổ chuyên môn (ví dụ: Tổ Toán-Tin, Tổ Văn). Có quyền **View-only** đối với công tác phân công giảng dạy, thời khóa biểu và kết quả học tập thuộc tổ chuyên môn của mình. Không trực tiếp tạo lớp, thời khóa biểu hay phân công giáo viên (chức năng này hoàn toàn thuộc về Admin). Ngoài ra, Trưởng bộ môn vẫn có các quyền của Giáo viên nếu trực tiếp giảng dạy. |
| **Giáo viên (Teacher)** | Xem lịch giảng dạy cá nhân. Tiến hành điểm danh chuyên cần (`AttendanceRecords`) và nhập điểm số các cột đánh giá (`Grades`) cho các lớp được phân công. Giáo viên Chủ nhiệm (GVCN) thực hiện đánh giá hạnh kiểm, tổng kết điểm trung bình (GPA) học kỳ và cả năm (`StudentSemesterSummaries`, `StudentYearlySummaries`) cho học sinh lớp mình chủ nhiệm. Đăng bài lên bảng tin lớp chủ nhiệm/lớp giảng dạy. |
| **Học sinh (Student)** | Xem thời khóa biểu cá nhân, tra cứu bảng điểm chi tiết môn học, xem danh sách bài tập và nộp bài trực tuyến. Xem thông tin tổng kết học kỳ và cả năm (Học bạ điện tử). Gửi đơn xin phép nghỉ học. |
| **Phụ huynh (Parent)** | Liên kết với tài khoản của một hoặc nhiều con em để theo dõi. Quyền lợi tra cứu tương tự Học sinh (Xem thời khóa biểu, điểm danh, bảng điểm, bài tập và học bạ điện tử). Có thể trực tiếp gửi đơn xin nghỉ học thay cho con em. |

> [!IMPORTANT]  
> - **Cột `DepartmentId` trên bảng `Users`** chỉ áp dụng cho vai trò Giáo viên, đóng vai trò như một thẻ lọc (Soft constraint) phục vụ tìm kiếm/lọc danh sách trên UI và báo cáo. Hệ thống không thiết lập các ràng buộc cứng (Hard constraints) gây phức tạp khi phân công giảng dạy chéo bộ môn.
> - **Mối quan hệ Học sinh - Lớp học** được quản lý lịch sử thông qua bảng trung gian `StudentClasses` thay vì lưu trực tiếp trong bảng `Users`. Điều này đảm bảo khi học sinh lên lớp qua các năm học mới, dữ liệu lịch sử các năm học cũ không bị ghi đè.

---

## 3. Yêu cầu Chức năng (Functional Requirements)

### 3.1. Xác thực & Quản lý Tài khoản
- **Đăng nhập hệ thống:** Xác thực tài khoản qua Username và Mật khẩu. Hỗ trợ cơ chế JWT Bearer Token & Refresh Token để duy trì trạng thái đăng nhập an toàn.
- **Quản lý hồ sơ cá nhân:** Xem và cập nhật các thông tin nhân khẩu học cơ bản bao gồm: Họ tên, Ngày sinh (`DateOfBirth`), Giới tính (`Gender`), Địa chỉ (`Address`), Số điện thoại, Email, Ảnh đại diện (`AvatarUrl`).
- **Bảo mật tài khoản:** Đổi mật khẩu cá nhân; khôi phục mật khẩu qua Email/Số điện thoại đã xác thực.

### 3.2. Quản lý Đào tạo & Phân công (Dành cho Admin)
- **Quản lý danh mục cốt lõi:** CRUD các danh mục Năm học, Học kỳ, Tổ chuyên môn (`Departments`), Lớp học, Môn học, Thang điểm xếp loại (`AcademicRanks`).
- **Phân công giảng dạy:** Admin ghép nối Giáo viên - Lớp học - Môn học - Học kỳ tạo thành bản ghi Phân công giảng dạy (`TeachingAssignments`).
- **Lập thời khóa biểu:** Phân bổ các tiết học (`TimetableSlots` từ tiết 1 đến tiết 10) cho các bản ghi Phân công giảng dạy theo các ngày trong tuần (Thứ 2 đến Chủ nhật) và phòng học cụ thể.

### 3.3. Nghiệp vụ Giảng dạy & Đánh giá (Dành cho Giáo viên)
- **Quản lý chuyên cần:** Điểm danh học sinh trong tiết học được phân công (Các trạng thái: `P` - Có mặt, `A` - Vắng mặt, `L` - Đi muộn). Cho phép ghi chú lý do.
- **Quản lý điểm số:** Nhập và cập nhật điểm số cho học sinh theo các đầu điểm được cấu hình sẵn (`AssessmentTypes`: Kiểm tra miệng, 15 phút, 1 tiết, Giữa kỳ, Cuối kỳ). Hỗ trợ nhập điểm hàng loạt (Bulk entry) theo lớp học.
- **Giao và chấm bài tập:** Tạo bài tập mới (tiêu đề, nội dung, hạn nộp, file đính kèm). Xem danh sách bài nộp và chấm điểm, phản hồi ý kiến cho từng bài làm của học sinh.
- **Tổng kết học kỳ & năm học (Chỉ dành cho GVCN):**
  - Tiến hành đánh giá xếp loại Hạnh kiểm (Tốt, Khá, Trung Bình, Yếu) vào cuối học kỳ và cuối năm học.
  - Chốt điểm trung bình học kỳ (GPA) và cả năm học, hệ thống tự động ánh xạ xếp loại học lực (`RankId`) dựa trên thang điểm thiết lập trong `AcademicRanks`. Dữ liệu được lưu trữ trực tiếp vào `StudentSemesterSummaries` và `StudentYearlySummaries` để phục vụ kết xuất học bạ điện tử (không tính toán on-the-fly để tối ưu hiệu năng).

### 3.4. Tra cứu Học tập & Đơn từ (Dành cho Học sinh & Phụ huynh)
- **Theo dõi học tập:** Xem thời khóa biểu hàng tuần, theo dõi chi tiết điểm số của từng môn học (bao gồm điểm thành phần và điểm trung bình môn).
- **Học bạ điện tử:** Xem bảng tổng kết học tập cuối kỳ và cả năm học (GPA, Hạnh kiểm, Xếp loại học lực).
- **Quản lý bài tập:** Xem danh sách bài tập cần hoàn thành, xem hạn nộp và nộp bài làm trực tuyến dưới dạng text, liên kết hoặc tải lên file đính kèm.
- **Xin nghỉ học:** Tạo đơn xin phép nghỉ học (chọn ngày nghỉ, lý do nghỉ, tải kèm minh chứng y tế/gia đình nếu có). Theo dõi trạng thái phê duyệt của giáo viên. Giáo viên có quyền duyệt (`Approved`) hoặc từ chối (`Rejected`) đơn xin nghỉ.

### 3.5. Bảng tin & Thông báo (Dành cho toàn bộ người dùng)
- **Thông báo toàn trường (Admin thực hiện):** Đăng tải các tin tức quan trọng có phạm vi toàn trường (Global announcements).
- **Thông báo nội bộ lớp học (Giáo viên thực hiện):** Đăng bài viết lên bảng tin lớp học phụ trách.
- **Quản lý thông báo cá nhân:** Hệ thống ghi nhận log thông báo cho từng người dùng, hỗ trợ đánh dấu đã đọc (`IsRead`) và gửi thông báo đẩy (Push Notifications) trên điện thoại.

> [!WARNING]  
> **Lưu ý quan trọng về phạm vi:** Module chat trực tuyến (bao gồm chat 1-1 giữa Phụ huynh - Giáo viên và chat nhóm lớp) đã hoàn toàn được loại bỏ khỏi phạm vi phát triển của hệ thống để tập trung tối ưu hóa các nghiệp vụ cốt lõi của nhà trường.

---

## 4. Yêu cầu Phi chức năng (Non-Functional Requirements)

- **Giao diện & Mỹ thuật (UI/UX):** 
  - Giao diện thiết kế theo phong cách hiện đại, tinh tế và nhất quán.
  - Tông màu chủ đạo là màu Cam FSchool (`#FF6B00`) kết hợp màu Trắng (`#FFFFFF`) và các sắc độ xám sang trọng. 
  - Hệ thống menu điều hướng rõ ràng, hỗ trợ trải nghiệm mượt mà trên cả hệ điều hành Android và iOS.
- **Hiệu năng & Tối ưu hóa:**
  - Tốc độ phản hồi các API nghiệp vụ thông thường (điểm danh, nhập điểm, tra cứu lịch học) phải dưới 2 giây dưới điều kiện mạng ổn định.
  - Sử dụng cơ chế Lazy Loading / Phân trang đối với các danh sách dữ liệu lớn như danh sách học sinh, bài tập hoặc log thông báo.
  - Đánh Index đầy đủ cho các trường tra cứu tần suất cao trong cơ sở dữ liệu (ví dụ: `RefreshTokens.Token`, `StudentClasses.StudentId`, `StudentClasses.ClassId`, v.v.) nhằm triệt tiêu hiện tượng Full Table Scan.
- **Bảo mật hệ thống:**
  - Mã hóa toàn bộ dữ liệu truyền tải qua HTTPS.
  - Mật khẩu tài khoản bắt buộc phải được mã hóa một chiều bằng thuật toán băm bảo mật (ví dụ: BCrypt/PBKDF2) kèm theo Salt trước khi lưu xuống database.
  - Quản lý phiên làm việc thông qua JWT ngắn hạn và Refresh Token dài hạn lưu trữ an toàn dưới Client.

---

## 5. Lịch sử Thay đổi Tài liệu & Thiết kế DB

Dưới đây là ghi nhận các điều chỉnh thiết kế so với bản đặc tả gốc nhằm khớp với schema database hiện hành:

| Phiên bản | Ngày cập nhật | Nội dung điều chỉnh | Lý do điều chỉnh |
| :--- | :--- | :--- | :--- |
| **v1.0** | Bản gốc | Thiết kế cơ bản ban đầu | Khởi tạo dự án |
| **v1.1** | 11/06/2026 | - Bỏ cột `ClassId` khỏi bảng `Users`, thêm bảng `StudentClasses`. | Tránh ghi đè và làm mất lịch sử lớp học khi học sinh lên lớp mới. |
| **v1.2** | 11/06/2026 | - Thêm bảng `StudentSemesterSummaries` và `StudentYearlySummaries`. <br>- Thêm bảng `AcademicRanks`. | Số hóa kết quả học tập định kỳ (Học bạ điện tử), tránh tính toán on-the-fly gây tải hệ thống. |
| **v1.3** | 11/06/2026 | - Bổ sung `DateOfBirth`, `Gender`, `Address` vào bảng `Users`. | Hoàn thiện hồ sơ học sinh/giáo viên phục vụ in ấn danh sách và thẻ học sinh. |
| **v1.4** | 11/06/2026 | - Thêm bảng `Departments`, bổ sung khóa ngoại `DepartmentId` cho Giáo viên. | Quản lý tổ chuyên môn; dùng làm bộ lọc tìm kiếm trên giao diện. |
| **v1.5** | 11/06/2026 | - Thêm Index cho `RefreshTokens.Token`. <br>- Thêm UNIQUE constraint `UQ_Semesters_Year_Name`. | Tối ưu hóa hiệu năng truy vấn token và ngăn ngừa rác dữ liệu học kỳ. |
| **v2.0** | Hiện tại | - **Loại bỏ hoàn toàn Module Chat** khỏi tài liệu SRS. <br>- Làm rõ phân quyền **View-only** của Trưởng bộ môn (`HeadOfDept`). | Đơn giản hóa kiến trúc giao tiếp, định hình rõ vai trò và tập trung vào các chức năng quản lý cốt lõi. |

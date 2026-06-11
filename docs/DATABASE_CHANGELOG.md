# DATABASE DESIGN UPDATES
*(Tài liệu ghi nhận các thay đổi về thiết kế Database so với bản SRS/Thiết kế ban đầu)*

Nhằm đáp ứng đúng nghiệp vụ quản lý trường THPT thực tế và tối ưu hiệu năng cho dự án, cấu trúc Database (SQL) đã được điều chỉnh và bổ sung các tính năng sau:

## 1. Cải tiến Quản lý Lịch sử Lớp học
- **Vấn đề ban đầu:** Bảng `Users` lưu trực tiếp `ClassId`. Khi học sinh lên lớp vào năm học mới, dữ liệu lớp cũ sẽ bị ghi đè, làm mất lịch sử học tập.
- **Giải pháp áp dụng:** 
  - Bỏ cột `ClassId` khỏi bảng `Users`.
  - Tạo bảng mới `StudentClasses (StudentClassId, StudentId, ClassId)`. Do `ClassId` đã gắn liền với `AcademicYearId`, bảng này cho phép tra cứu chính xác học sinh đã học lớp nào trong bất kỳ năm học nào.

## 2. Số hóa Tổng kết Điểm số & Hạnh kiểm
- **Vấn đề ban đầu:** Hệ thống không có nơi lưu Điểm trung bình (GPA) và Hạnh kiểm. Việc tính điểm trung bình (on-the-fly) từ bảng `Grades` mỗi khi xem học bạ sẽ gây quá tải hệ thống và không lưu lại được hạnh kiểm do GVCN đánh giá.
- **Giải pháp áp dụng:**
  - Thêm bảng **`AcademicRanks`** để quy định các mốc xếp loại học lực (Giỏi, Khá, Trung Bình, Yếu, Kém).
  - Thêm bảng **`StudentSemesterSummaries`**: Lưu GPA, Hạnh kiểm, Xếp loại của từng Học kỳ.
  - Thêm bảng **`StudentYearlySummaries`**: Lưu GPA, Hạnh kiểm, Xếp loại chốt sổ của Cả năm học.

## 3. Hoàn thiện Hồ sơ Người dùng (Nghiệp vụ Cốt lõi)
- **Vấn đề ban đầu:** Bảng `Users` thiếu các trường thông tin nhân khẩu học cơ bản.
- **Giải pháp áp dụng:** Bổ sung `DateOfBirth` (Ngày sinh), `Gender` (Giới tính) và `Address` (Địa chỉ thường trú). Đây là điều kiện bắt buộc để có thể in Thẻ học sinh, Danh sách lớp hoặc Học bạ hợp lệ.

## 4. Quản lý Tổ chuyên môn (Departments)
- **Vấn đề ban đầu:** Có role `HeadOfDept` (Tổ trưởng) nhưng không có dữ liệu quản lý các Tổ chuyên môn.
- **Giải pháp áp dụng:** 
  - Thêm bảng `Departments (DepartmentId, DepartmentName)`.
  - Thêm cột `DepartmentId` vào bảng `Users` (chỉ áp dụng cho Giáo viên). Mục đích chính là để phục vụ bộ lọc tìm kiếm trên giao diện UI/Báo cáo, không ràng buộc cứng (Hard constraint) khi phân công xếp thời khóa biểu để giữ cho logic Backend đơn giản.

## 5. Tối ưu Hiệu năng (Performance) & Ràng buộc (Constraints)
- **Tối ưu Token:** Đánh `INDEX` cho cột `Token` và `UserId` trong bảng `RefreshTokens`. Tránh tình trạng Full Table Scan khi lượng học sinh dùng App đồng thời lớn.
- **Chặt chẽ Cặp định danh:** Thêm ràng buộc `UNIQUE (AcademicYearId, SemesterName)` vào bảng `Semesters`. Đảm bảo hệ thống không bao giờ bị rác dữ liệu do tồn tại hai "Học kỳ 1" trong cùng một "Năm học".

using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PRM393API.Migrations
{
    /// <inheritdoc />
    public partial class SeedData : Migration
    {
        // BCrypt hash of "12345678" (cost=11) — for testing only
        private const string Hash = "$2a$11$Dd578wcc0Mrz0sr4XQ95b.J31xJvd2C55lUqbLTAMnpEVLjGMVA1.";

        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Roles
            migrationBuilder.InsertData("Roles", new[] { "RoleName" }, new object[] { "Admin" });
            migrationBuilder.InsertData("Roles", new[] { "RoleName" }, new object[] { "HeadOfDept" });
            migrationBuilder.InsertData("Roles", new[] { "RoleName" }, new object[] { "Teacher" });
            migrationBuilder.InsertData("Roles", new[] { "RoleName" }, new object[] { "Student" });
            migrationBuilder.InsertData("Roles", new[] { "RoleName" }, new object[] { "Parent" });

            // AssessmentTypes
            migrationBuilder.InsertData("AssessmentTypes", new[] { "TypeName", "Weight" },
                new object[] { "Kiểm tra miệng", 1.0m });
            migrationBuilder.InsertData("AssessmentTypes", new[] { "TypeName", "Weight" },
                new object[] { "Kiểm tra 15 phút", 1.0m });
            migrationBuilder.InsertData("AssessmentTypes", new[] { "TypeName", "Weight" },
                new object[] { "Kiểm tra 1 tiết", 2.0m });
            migrationBuilder.InsertData("AssessmentTypes", new[] { "TypeName", "Weight" },
                new object[] { "Kiểm tra giữa kỳ", 2.0m });
            migrationBuilder.InsertData("AssessmentTypes", new[] { "TypeName", "Weight" },
                new object[] { "Kiểm tra cuối kỳ", 3.0m });

            // TimetableSlots
            migrationBuilder.InsertData("TimetableSlots", new[] { "SlotName", "StartTime", "EndTime" },
                new object[] { "Tiết 1", new TimeOnly(7, 0, 0), new TimeOnly(7, 45, 0) });
            migrationBuilder.InsertData("TimetableSlots", new[] { "SlotName", "StartTime", "EndTime" },
                new object[] { "Tiết 2", new TimeOnly(7, 50, 0), new TimeOnly(8, 35, 0) });
            migrationBuilder.InsertData("TimetableSlots", new[] { "SlotName", "StartTime", "EndTime" },
                new object[] { "Tiết 3", new TimeOnly(8, 40, 0), new TimeOnly(9, 25, 0) });
            migrationBuilder.InsertData("TimetableSlots", new[] { "SlotName", "StartTime", "EndTime" },
                new object[] { "Tiết 4", new TimeOnly(9, 45, 0), new TimeOnly(10, 30, 0) });
            migrationBuilder.InsertData("TimetableSlots", new[] { "SlotName", "StartTime", "EndTime" },
                new object[] { "Tiết 5", new TimeOnly(10, 35, 0), new TimeOnly(11, 20, 0) });
            migrationBuilder.InsertData("TimetableSlots", new[] { "SlotName", "StartTime", "EndTime" },
                new object[] { "Tiết 6", new TimeOnly(13, 0, 0), new TimeOnly(13, 45, 0) });
            migrationBuilder.InsertData("TimetableSlots", new[] { "SlotName", "StartTime", "EndTime" },
                new object[] { "Tiết 7", new TimeOnly(13, 50, 0), new TimeOnly(14, 35, 0) });
            migrationBuilder.InsertData("TimetableSlots", new[] { "SlotName", "StartTime", "EndTime" },
                new object[] { "Tiết 8", new TimeOnly(14, 40, 0), new TimeOnly(15, 25, 0) });
            migrationBuilder.InsertData("TimetableSlots", new[] { "SlotName", "StartTime", "EndTime" },
                new object[] { "Tiết 9", new TimeOnly(15, 45, 0), new TimeOnly(16, 30, 0) });
            migrationBuilder.InsertData("TimetableSlots", new[] { "SlotName", "StartTime", "EndTime" },
                new object[] { "Tiết 10", new TimeOnly(16, 35, 0), new TimeOnly(17, 20, 0) });

            // AcademicYears
            migrationBuilder.InsertData("AcademicYears",
                new[] { "YearName", "StartDate", "EndDate", "IsActive" },
                new object[] { "2025-2026", new DateOnly(2025, 9, 1), new DateOnly(2026, 5, 31), true });

            // Semesters
            migrationBuilder.InsertData("Semesters",
                new[] { "AcademicYearId", "SemesterName", "StartDate", "EndDate" },
                new object[] { 1, "Học kỳ 1", new DateOnly(2025, 9, 1), new DateOnly(2026, 1, 15) });
            migrationBuilder.InsertData("Semesters",
                new[] { "AcademicYearId", "SemesterName", "StartDate", "EndDate" },
                new object[] { 1, "Học kỳ 2", new DateOnly(2026, 1, 20), new DateOnly(2026, 5, 31) });

            // Subjects
            migrationBuilder.InsertData("Subjects", new[] { "SubjectCode", "SubjectName", "IsActive" },
                new object[] { "MATH", "Toán", true });
            migrationBuilder.InsertData("Subjects", new[] { "SubjectCode", "SubjectName", "IsActive" },
                new object[] { "LIT", "Ngữ Văn", true });
            migrationBuilder.InsertData("Subjects", new[] { "SubjectCode", "SubjectName", "IsActive" },
                new object[] { "ENG", "Tiếng Anh", true });
            migrationBuilder.InsertData("Subjects", new[] { "SubjectCode", "SubjectName", "IsActive" },
                new object[] { "PHY", "Vật Lý", true });
            migrationBuilder.InsertData("Subjects", new[] { "SubjectCode", "SubjectName", "IsActive" },
                new object[] { "CHEM", "Hóa Học", true });
            migrationBuilder.InsertData("Subjects", new[] { "SubjectCode", "SubjectName", "IsActive" },
                new object[] { "BIO", "Sinh Học", true });
            migrationBuilder.InsertData("Subjects", new[] { "SubjectCode", "SubjectName", "IsActive" },
                new object[] { "HIST", "Lịch Sử", true });
            migrationBuilder.InsertData("Subjects", new[] { "SubjectCode", "SubjectName", "IsActive" },
                new object[] { "GEO", "Địa Lý", true });
            migrationBuilder.InsertData("Subjects", new[] { "SubjectCode", "SubjectName", "IsActive" },
                new object[] { "IT", "Tin Học", true });
            migrationBuilder.InsertData("Subjects", new[] { "SubjectCode", "SubjectName", "IsActive" },
                new object[] { "PE", "Thể Dục", true });

            // Departments
            migrationBuilder.InsertData("Departments", new[] { "DepartmentName" },
                new object[] { "Tổ Toán - Tin" });
            migrationBuilder.InsertData("Departments", new[] { "DepartmentName" },
                new object[] { "Tổ Ngữ Văn" });
            migrationBuilder.InsertData("Departments", new[] { "DepartmentName" },
                new object[] { "Tổ Ngoại Ngữ" });
            migrationBuilder.InsertData("Departments", new[] { "DepartmentName" },
                new object[] { "Tổ Khoa học Tự nhiên" });

            // AcademicRanks
            migrationBuilder.InsertData("AcademicRanks", new[] { "RankName", "MinScore", "MaxScore" },
                new object[] { "Giỏi", 8.0m, 10.0m });
            migrationBuilder.InsertData("AcademicRanks", new[] { "RankName", "MinScore", "MaxScore" },
                new object[] { "Khá", 6.5m, 7.99m });
            migrationBuilder.InsertData("AcademicRanks", new[] { "RankName", "MinScore", "MaxScore" },
                new object[] { "Trung Bình", 5.0m, 6.49m });
            migrationBuilder.InsertData("AcademicRanks", new[] { "RankName", "MinScore", "MaxScore" },
                new object[] { "Yếu", 3.5m, 4.99m });
            migrationBuilder.InsertData("AcademicRanks", new[] { "RankName", "MinScore", "MaxScore" },
                new object[] { "Kém", 0.0m, 3.49m });

            // Users: Admin, HeadOfDept, Teachers (RoleId: 1=Admin, 2=HeadOfDept, 3=Teacher)
            var userCols = new[] { "Username", "PasswordHash", "FullName", "DateOfBirth", "Gender", "Address", "Email", "PhoneNumber", "RoleId", "DepartmentId", "IsActive" };
            migrationBuilder.InsertData("Users", userCols, new object[] { "admin01",   Hash, "Nguyễn Văn Admin",  new DateOnly(1980, 5, 15),  "Nam", "Hà Nội", "admin@fschool.edu.vn",    "0901000001", 1, null, true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "hodept01",  Hash, "Trần Thị Lan Anh",  new DateOnly(1985, 8, 20),  "Nữ",  "Hà Nội", "lananh@fschool.edu.vn",   "0901000002", 2, 2,    true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "teacher01", Hash, "Phạm Minh Tuấn",   new DateOnly(1990, 2, 10),  "Nam", "Hà Nội", "tuan.pm@fschool.edu.vn",  "0901000003", 3, 1,    true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "teacher02", Hash, "Lê Thị Hương",     new DateOnly(1992, 11, 5),  "Nữ",  "Hà Nội", "huong.lt@fschool.edu.vn", "0901000004", 3, 2,    true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "teacher03", Hash, "Võ Thanh Bình",    new DateOnly(1988, 9, 25),  "Nam", "Hà Nội", "binh.vt@fschool.edu.vn",  "0901000005", 3, 3,    true });

            // Classes (HomeroomTeacherId: teacher01=3, teacher02=4)
            migrationBuilder.InsertData("Classes",
                new[] { "ClassName", "AcademicYearId", "HomeroomTeacherId" },
                new object[] { "10A1", 1, 3 });
            migrationBuilder.InsertData("Classes",
                new[] { "ClassName", "AcademicYearId", "HomeroomTeacherId" },
                new object[] { "10A2", 1, 4 });

            // Users: Students (RoleId=4) and Parents (RoleId=5)
            migrationBuilder.InsertData("Users", userCols, new object[] { "student01", Hash, "Nguyễn Thành Đạt",  new DateOnly(2010, 1, 10),  "Nam", "Hà Nội", "dat.nt@fschool.edu.vn",  "0901000006", 4, null, true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "student02", Hash, "Trần Ngọc Mai",     new DateOnly(2010, 3, 22),  "Nữ",  "Hà Nội", "mai.tn@fschool.edu.vn",  "0901000007", 4, null, true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "student03", Hash, "Lê Hoàng Phúc",     new DateOnly(2010, 7, 5),   "Nam", "Hà Nội", "phuc.lh@fschool.edu.vn", "0901000008", 4, null, true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "student04", Hash, "Phan Thị Thu Hà",   new DateOnly(2010, 9, 12),  "Nữ",  "Hà Nội", "ha.pt@fschool.edu.vn",   "0901000009", 4, null, true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "student05", Hash, "Đỗ Quang Huy",      new DateOnly(2010, 12, 1),  "Nam", "Hà Nội", "huy.dq@fschool.edu.vn",  "0901000010", 4, null, true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "student06", Hash, "Bùi Thị Cẩm Ly",   new DateOnly(2010, 5, 18),  "Nữ",  "Hà Nội", "ly.bt@fschool.edu.vn",   "0901000011", 4, null, true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "parent01",  Hash, "Nguyễn Văn Tâm",   new DateOnly(1975, 4, 12),  "Nam", "Hà Nội", "tam.nv@gmail.com",       "0912000001", 5, null, true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "parent02",  Hash, "Trần Thị Bích Nga", new DateOnly(1980, 8, 30),  "Nữ",  "Hà Nội", "nga.tt@gmail.com",       "0912000002", 5, null, true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "parent03",  Hash, "Lê Văn Mạnh",      new DateOnly(1978, 1, 15),  "Nam", "Hà Nội", "manh.lv@gmail.com",      "0912000003", 5, null, true });
            migrationBuilder.InsertData("Users", userCols, new object[] { "parent04",  Hash, "Phan Văn Dũng",    new DateOnly(1972, 10, 20), "Nam", "Hà Nội", "dung.pv@gmail.com",      "0912000004", 5, null, true });

            // StudentClasses (StudentId: 6-11, ClassId: 1=10A1, 2=10A2)
            migrationBuilder.InsertData("StudentClasses", new[] { "StudentId", "ClassId" }, new object[] { 6,  1 });
            migrationBuilder.InsertData("StudentClasses", new[] { "StudentId", "ClassId" }, new object[] { 7,  1 });
            migrationBuilder.InsertData("StudentClasses", new[] { "StudentId", "ClassId" }, new object[] { 8,  1 });
            migrationBuilder.InsertData("StudentClasses", new[] { "StudentId", "ClassId" }, new object[] { 9,  2 });
            migrationBuilder.InsertData("StudentClasses", new[] { "StudentId", "ClassId" }, new object[] { 10, 2 });
            migrationBuilder.InsertData("StudentClasses", new[] { "StudentId", "ClassId" }, new object[] { 11, 2 });

            // ParentStudents
            migrationBuilder.InsertData("ParentStudents", new[] { "ParentId", "StudentId", "Relationship" },
                new object[] { 12, 6,  "Cha" });
            migrationBuilder.InsertData("ParentStudents", new[] { "ParentId", "StudentId", "Relationship" },
                new object[] { 13, 7,  "Mẹ" });
            migrationBuilder.InsertData("ParentStudents", new[] { "ParentId", "StudentId", "Relationship" },
                new object[] { 14, 8,  "Cha" });
            migrationBuilder.InsertData("ParentStudents", new[] { "ParentId", "StudentId", "Relationship" },
                new object[] { 15, 9,  "Cha" });

            // TeachingAssignments
            migrationBuilder.InsertData("TeachingAssignments",
                new[] { "TeacherId", "ClassId", "SubjectId", "SemesterId" },
                new object[] { 3, 1, 1, 1 }); // teacher01 - Toán - 10A1 - HK1
            migrationBuilder.InsertData("TeachingAssignments",
                new[] { "TeacherId", "ClassId", "SubjectId", "SemesterId" },
                new object[] { 3, 2, 1, 1 }); // teacher01 - Toán - 10A2 - HK1
            migrationBuilder.InsertData("TeachingAssignments",
                new[] { "TeacherId", "ClassId", "SubjectId", "SemesterId" },
                new object[] { 4, 1, 2, 1 }); // teacher02 - Văn  - 10A1 - HK1
            migrationBuilder.InsertData("TeachingAssignments",
                new[] { "TeacherId", "ClassId", "SubjectId", "SemesterId" },
                new object[] { 4, 2, 2, 1 }); // teacher02 - Văn  - 10A2 - HK1
            migrationBuilder.InsertData("TeachingAssignments",
                new[] { "TeacherId", "ClassId", "SubjectId", "SemesterId" },
                new object[] { 5, 1, 3, 1 }); // teacher03 - Anh  - 10A1 - HK1
            migrationBuilder.InsertData("TeachingAssignments",
                new[] { "TeacherId", "ClassId", "SubjectId", "SemesterId" },
                new object[] { 5, 2, 3, 1 }); // teacher03 - Anh  - 10A2 - HK1

            // Timetables (lớp 10A1)
            migrationBuilder.InsertData("Timetables",
                new[] { "TeachingAssignmentId", "DayOfWeek", "SlotId", "RoomName", "EffectiveFrom" },
                new object[] { 1, (byte)2, 1, "Phòng 101", new DateOnly(2025, 9, 1) });
            migrationBuilder.InsertData("Timetables",
                new[] { "TeachingAssignmentId", "DayOfWeek", "SlotId", "RoomName", "EffectiveFrom" },
                new object[] { 1, (byte)4, 2, "Phòng 101", new DateOnly(2025, 9, 1) });
            migrationBuilder.InsertData("Timetables",
                new[] { "TeachingAssignmentId", "DayOfWeek", "SlotId", "RoomName", "EffectiveFrom" },
                new object[] { 3, (byte)3, 1, "Phòng 202", new DateOnly(2025, 9, 1) });
            migrationBuilder.InsertData("Timetables",
                new[] { "TeachingAssignmentId", "DayOfWeek", "SlotId", "RoomName", "EffectiveFrom" },
                new object[] { 3, (byte)5, 3, "Phòng 202", new DateOnly(2025, 9, 1) });
            migrationBuilder.InsertData("Timetables",
                new[] { "TeachingAssignmentId", "DayOfWeek", "SlotId", "RoomName", "EffectiveFrom" },
                new object[] { 5, (byte)3, 3, "Phòng 305", new DateOnly(2025, 9, 1) });
            migrationBuilder.InsertData("Timetables",
                new[] { "TeachingAssignmentId", "DayOfWeek", "SlotId", "RoomName", "EffectiveFrom" },
                new object[] { 5, (byte)6, 4, "Phòng 305", new DateOnly(2025, 9, 1) });

            // AttendanceRecords
            migrationBuilder.InsertData("AttendanceRecords",
                new[] { "TimetableId", "StudentId", "AttendanceDate", "Status", "RecordedBy" },
                new object[] { 1, 6, new DateOnly(2025, 9, 8), "P", 3 });
            migrationBuilder.InsertData("AttendanceRecords",
                new[] { "TimetableId", "StudentId", "AttendanceDate", "Status", "RecordedBy" },
                new object[] { 1, 7, new DateOnly(2025, 9, 8), "P", 3 });
            migrationBuilder.InsertData("AttendanceRecords",
                new[] { "TimetableId", "StudentId", "AttendanceDate", "Status", "RecordedBy" },
                new object[] { 1, 8, new DateOnly(2025, 9, 8), "A", 3 });

            // Assessments
            migrationBuilder.InsertData("Assessments",
                new[] { "TeachingAssignmentId", "AssessmentTypeId", "AssessmentName", "AssessmentDate", "MaxScore" },
                new object[] { 1, 2, "Kiểm tra 15 phút - Chương 1", new DateOnly(2025, 9, 20),  10.0m });
            migrationBuilder.InsertData("Assessments",
                new[] { "TeachingAssignmentId", "AssessmentTypeId", "AssessmentName", "AssessmentDate", "MaxScore" },
                new object[] { 1, 3, "Kiểm tra 1 tiết - Chương 1",  new DateOnly(2025, 10, 15), 10.0m });
            migrationBuilder.InsertData("Assessments",
                new[] { "TeachingAssignmentId", "AssessmentTypeId", "AssessmentName", "AssessmentDate", "MaxScore" },
                new object[] { 1, 4, "Kiểm tra giữa kỳ 1",          new DateOnly(2025, 11, 10), 10.0m });

            // Grades
            migrationBuilder.InsertData("Grades",
                new[] { "AssessmentId", "StudentId", "Score", "EnteredBy" },
                new object[] { 1, 6, 8.5m, 3 });
            migrationBuilder.InsertData("Grades",
                new[] { "AssessmentId", "StudentId", "Score", "EnteredBy" },
                new object[] { 1, 7, 7.0m, 3 });
            migrationBuilder.InsertData("Grades",
                new[] { "AssessmentId", "StudentId", "Score", "EnteredBy" },
                new object[] { 1, 8, 9.0m, 3 });

            // Assignments
            migrationBuilder.InsertData("Assignments",
                new[] { "TeachingAssignmentId", "Title", "Description", "DueDate", "CreatedBy", "IsDeleted" },
                new object[] { 1, "Bài tập chương 1: Mệnh đề và tập hợp",
                    "Làm bài tập từ trang 15 đến trang 20 - SGK Toán 10",
                    new DateTime(2025, 9, 25, 23, 59, 0), 3, false });
            migrationBuilder.InsertData("Assignments",
                new[] { "TeachingAssignmentId", "Title", "Description", "DueDate", "CreatedBy", "IsDeleted" },
                new object[] { 1, "Ôn tập kiểm tra 1 tiết chương 1",
                    "Giải đề cương ôn tập giáo viên phát, nộp trước ngày kiểm tra",
                    new DateTime(2025, 10, 14, 23, 59, 0), 3, false });

            // Submissions
            migrationBuilder.InsertData("Submissions",
                new[] { "AssignmentId", "StudentId", "LinkUrl", "SubmittedAt" },
                new object[] { 1, 6, "https://drive.google.com/file/student01-bt1", new DateTime(2025, 9, 24, 20, 30, 0) });
            migrationBuilder.InsertData("Submissions",
                new[] { "AssignmentId", "StudentId", "LinkUrl", "SubmittedAt" },
                new object[] { 1, 7, "https://drive.google.com/file/student02-bt1", new DateTime(2025, 9, 25, 18, 0, 0) });

            // StudentRequests
            migrationBuilder.InsertData("StudentRequests",
                new[] { "StudentId", "RequestedBy", "LeaveDate", "Reason", "Status", "ReviewedBy", "ReviewedAt" },
                new object[] { 8, 14, new DateOnly(2025, 9, 8), "Bị sốt, có giấy xác nhận của bác sĩ",
                    "Approved", 3, new DateTime(2025, 9, 7, 19, 0, 0) });
            migrationBuilder.InsertData("StudentRequests",
                new[] { "StudentId", "RequestedBy", "LeaveDate", "Reason", "Status" },
                new object[] { 7, 13, new DateOnly(2025, 9, 15), "Gia đình có việc đột xuất", "Pending" });

            // Announcements
            migrationBuilder.InsertData("Announcements",
                new[] { "AuthorId", "Title", "Content", "AnnouncementType", "Priority", "IsDeleted" },
                new object[] { 1,
                    "Thông báo nghỉ lễ Quốc khánh 2/9",
                    "Nhà trường thông báo học sinh, giáo viên được nghỉ lễ Quốc khánh từ ngày 01/09 đến 03/09/2025. Học sinh đi học trở lại vào ngày 04/09/2025.",
                    "global", "high", false });
            migrationBuilder.InsertData("Announcements",
                new[] { "AuthorId", "Title", "Content", "AnnouncementType", "Priority", "IsDeleted" },
                new object[] { 3,
                    "Lịch kiểm tra 1 tiết Toán chương 1",
                    "Các em học sinh lớp 10A1 chú ý: Kiểm tra 1 tiết chương 1 vào ngày 15/10/2025, tiết 1 buổi sáng. Nội dung: Mệnh đề, Tập hợp, Hàm số.",
                    "class", "normal", false });

            // AnnouncementTargets
            migrationBuilder.InsertData("AnnouncementTargets", new[] { "AnnouncementId", "ClassId" },
                new object[] { 1, null });
            migrationBuilder.InsertData("AnnouncementTargets", new[] { "AnnouncementId", "ClassId" },
                new object[] { 2, 1 });

            // NotificationLogs
            migrationBuilder.InsertData("NotificationLogs",
                new[] { "UserId", "AnnouncementId", "Title", "Body", "IsRead" },
                new object[] { 6,  2, "Lịch kiểm tra 1 tiết Toán", "Kiểm tra 1 tiết Toán chương 1 vào ngày 15/10/2025.", false });
            migrationBuilder.InsertData("NotificationLogs",
                new[] { "UserId", "AnnouncementId", "Title", "Body", "IsRead" },
                new object[] { 7,  2, "Lịch kiểm tra 1 tiết Toán", "Kiểm tra 1 tiết Toán chương 1 vào ngày 15/10/2025.", true });
            migrationBuilder.InsertData("NotificationLogs",
                new[] { "UserId", "AnnouncementId", "Title", "Body", "IsRead" },
                new object[] { 8,  2, "Lịch kiểm tra 1 tiết Toán", "Kiểm tra 1 tiết Toán chương 1 vào ngày 15/10/2025.", false });
            migrationBuilder.InsertData("NotificationLogs",
                new[] { "UserId", "AnnouncementId", "Title", "Body", "IsRead" },
                new object[] { 12, 2, "Lịch kiểm tra 1 tiết Toán", "Con bạn có lịch kiểm tra Toán ngày 15/10/2025.", false });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DELETE FROM NotificationLogs");
            migrationBuilder.Sql("DELETE FROM AnnouncementTargets");
            migrationBuilder.Sql("DELETE FROM Announcements");
            migrationBuilder.Sql("DELETE FROM StudentRequests");
            migrationBuilder.Sql("DELETE FROM Submissions");
            migrationBuilder.Sql("DELETE FROM Assignments");
            migrationBuilder.Sql("DELETE FROM Grades");
            migrationBuilder.Sql("DELETE FROM Assessments");
            migrationBuilder.Sql("DELETE FROM AttendanceRecords");
            migrationBuilder.Sql("DELETE FROM Timetables");
            migrationBuilder.Sql("DELETE FROM TeachingAssignments");
            migrationBuilder.Sql("DELETE FROM ParentStudents");
            migrationBuilder.Sql("DELETE FROM StudentClasses");
            migrationBuilder.Sql("DELETE FROM Classes");
            migrationBuilder.Sql("DELETE FROM Users");
            migrationBuilder.Sql("DELETE FROM AcademicRanks");
            migrationBuilder.Sql("DELETE FROM Departments");
            migrationBuilder.Sql("DELETE FROM Subjects");
            migrationBuilder.Sql("DELETE FROM Semesters");
            migrationBuilder.Sql("DELETE FROM AcademicYears");
            migrationBuilder.Sql("DELETE FROM TimetableSlots");
            migrationBuilder.Sql("DELETE FROM AssessmentTypes");
            migrationBuilder.Sql("DELETE FROM Roles");
        }
    }
}

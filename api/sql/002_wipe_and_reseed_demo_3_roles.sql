/*
================================================================================
  002_wipe_and_reseed_demo_3_roles.sql
  Wipe toàn bộ data nghiệp vụ + seed lại cho demo mobile 3 role.

  Khớp Dev Quick Login:
    mobile/lib/vn/edu/fpt/core/dev/dev_login_accounts.dart

  Tài khoản nhanh (MK chung: 12345678):
    | Role      | Username   | SĐT          | Ghi chú              |
    |-----------|------------|--------------|----------------------|
    | Giáo viên | teacher01  | 01234567890  | GVCN 10A1, dạy Toán  |
    | Phụ huynh | parent01   | 0786414311   | Cha của student01    |
    | Học sinh  | student01  | 0364828685   | Lớp 10A1             |

  PasswordHash = BCrypt cost=11 của "12345678"
    (cùng hash migration SeedData)

  Cách chạy (SSMS / Azure Data Studio / sqlcmd):
    1. Chọn đúng database FSchool / PRM393
    2. Execute toàn bộ script
    3. Hot-restart app → Dev Quick Login

  CẢNH BÁO: XÓA HẾT DATA trong các bảng bên dưới. Chỉ dùng môi trường DEV.
================================================================================
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

------------------------------------------------------------
-- 1) WIPE (con → cha) — bỏ qua bảng không tồn tại
------------------------------------------------------------
DECLARE @sql NVARCHAR(MAX) = N'';

DECLARE @tables TABLE (Ord INT, Name SYSNAME);
INSERT INTO @tables (Ord, Name) VALUES
    ( 1, N'RefreshTokens'),
    ( 2, N'Grades'),
    ( 3, N'Assessments'),
    ( 4, N'AttendanceRecords'),
    ( 5, N'Timetables'),
    ( 6, N'TimetableTemplates'),
    ( 7, N'TeachingAssignments'),
    ( 8, N'StudentRequests'),
    ( 9, N'AnnouncementTargets'),
    (10, N'Announcements'),
    (11, N'StudentSemesterSummaries'),
    (12, N'StudentYearlySummaries'),
    (13, N'ParentStudents'),
    (14, N'StudentClasses'),
    (15, N'Classes'),
    (16, N'Users'),
    (17, N'AcademicRanks'),
    (18, N'Departments'),
    (19, N'Subjects'),
    (20, N'Semesters'),
    (21, N'AcademicYears'),
    (22, N'TimetableSlots'),
    (23, N'AssessmentTypes'),
    (24, N'Roles');

DECLARE @ord INT = 1, @max INT = 24, @name SYSNAME;
WHILE @ord <= @max
BEGIN
    SELECT @name = Name FROM @tables WHERE Ord = @ord;
    IF OBJECT_ID(N'dbo.' + @name, N'U') IS NOT NULL
    BEGIN
        SET @sql = N'DELETE FROM dbo.' + QUOTENAME(@name) + N';';
        EXEC sp_executesql @sql;
        -- Reseed identity về 0 nếu có
        IF EXISTS (
            SELECT 1 FROM sys.identity_columns
            WHERE object_id = OBJECT_ID(N'dbo.' + @name)
        )
        BEGIN
            SET @sql = N'DBCC CHECKIDENT (N''dbo.' + @name + N''', RESEED, 0) WITH NO_INFOMSGS;';
            EXEC sp_executesql @sql;
        END
    END
    SET @ord += 1;
END;

------------------------------------------------------------
-- 2) SEED — danh mục
------------------------------------------------------------
DECLARE @Hash NVARCHAR(256) = N'$2a$11$Dd578wcc0Mrz0sr4XQ95b.J31xJvd2C55lUqbLTAMnpEVLjGMVA1.'; -- 12345678

INSERT INTO dbo.Roles (RoleName) VALUES
    (N'Admin'),
    (N'HeadOfDept'),
    (N'Teacher'),
    (N'Student'),
    (N'Parent');

INSERT INTO dbo.AssessmentTypes (TypeName, Weight) VALUES
    (N'Kiểm tra miệng', 1.0),
    (N'Kiểm tra 15 phút', 1.0),
    (N'Kiểm tra 1 tiết', 2.0),
    (N'Kiểm tra giữa kỳ', 2.0),
    (N'Kiểm tra cuối kỳ', 3.0);

INSERT INTO dbo.TimetableSlots (SlotName, StartTime, EndTime) VALUES
    (N'Tiết 1',  '07:00', '07:45'),
    (N'Tiết 2',  '07:50', '08:35'),
    (N'Tiết 3',  '08:40', '09:25'),
    (N'Tiết 4',  '09:45', '10:30'),
    (N'Tiết 5',  '10:35', '11:20'),
    (N'Tiết 6',  '13:00', '13:45'),
    (N'Tiết 7',  '13:50', '14:35'),
    (N'Tiết 8',  '14:40', '15:25'),
    (N'Tiết 9',  '15:45', '16:30'),
    (N'Tiết 10', '16:35', '17:20');

INSERT INTO dbo.AcademicYears (YearName, StartDate, EndDate, IsActive) VALUES
    (N'2025-2026', '2025-09-01', '2026-05-31', 1),
    (N'2026-2027', '2026-09-01', '2027-05-31', 0);

INSERT INTO dbo.Semesters (AcademicYearId, SemesterName, StartDate, EndDate) VALUES
    (1, N'Học kỳ 1', '2025-09-01', '2026-01-15'),
    (1, N'Học kỳ 2', '2026-01-20', '2026-05-31'),
    (2, N'Học kỳ 1', '2026-09-01', '2027-01-15'),
    (2, N'Học kỳ 2', '2027-01-20', '2027-05-31');

INSERT INTO dbo.Subjects (SubjectCode, SubjectName, IsActive) VALUES
    (N'MATH', N'Toán', 1),
    (N'LIT',  N'Ngữ Văn', 1),
    (N'ENG',  N'Tiếng Anh', 1),
    (N'PHY',  N'Vật Lý', 1),
    (N'CHEM', N'Hóa Học', 1),
    (N'BIO',  N'Sinh Học', 1),
    (N'HIST', N'Lịch Sử', 1),
    (N'GEO',  N'Địa Lý', 1),
    (N'IT',   N'Tin Học', 1),
    (N'PE',   N'Thể Dục', 1);

INSERT INTO dbo.Departments (DepartmentName) VALUES
    (N'Tổ Toán - Tin'),
    (N'Tổ Ngữ Văn'),
    (N'Tổ Ngoại Ngữ'),
    (N'Tổ Khoa học Tự nhiên');

INSERT INTO dbo.AcademicRanks (RankName, MinScore, MaxScore) VALUES
    (N'Giỏi', 8.00, 10.00),
    (N'Khá', 6.50, 7.99),
    (N'Trung Bình', 5.00, 6.49),
    (N'Yếu', 3.50, 4.99),
    (N'Kém', 0.00, 3.49);

------------------------------------------------------------
-- 3) USERS — SĐT quick-login khớp app
-- RoleId: 1 Admin · 2 HeadOfDept · 3 Teacher · 4 Student · 5 Parent
-- Sau insert: teacher01=3, student01=6, parent01=12 (nếu DB trống + reseed)
------------------------------------------------------------
INSERT INTO dbo.Users
    (Username, PasswordHash, FullName, DateOfBirth, Gender, Address, Email, PhoneNumber, RoleId, DepartmentId, IsActive)
VALUES
    -- staff
    (N'admin01',   @Hash, N'Nguyễn Văn Admin',  '1980-05-15', N'Nam', N'Hà Nội', N'admin@fschool.edu.vn',    N'0901000001', 1, NULL, 1),
    (N'hodept01',  @Hash, N'Trần Thị Lan Anh',  '1985-08-20', N'Nữ',  N'Hà Nội', N'lananh@fschool.edu.vn',   N'0901000002', 2, 2,    1),
    -- ★ Dev Quick Login · Giáo viên
    (N'teacher01', @Hash, N'Phạm Minh Tuấn',    '1990-02-10', N'Nam', N'Hà Nội', N'tuan.pm@fschool.edu.vn',  N'01234567890', 3, 1,   1),
    (N'teacher02', @Hash, N'Lê Thị Hương',      '1992-11-05', N'Nữ',  N'Hà Nội', N'huong.lt@fschool.edu.vn', N'0901000004', 3, 2,    1),
    (N'teacher03', @Hash, N'Võ Thanh Bình',     '1988-09-25', N'Nam', N'Hà Nội', N'binh.vt@fschool.edu.vn',  N'0901000005', 3, 3,    1);

DECLARE @Teacher01 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'teacher01');
DECLARE @Teacher02 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'teacher02');
DECLARE @Teacher03 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'teacher03');
DECLARE @Admin01   INT = (SELECT UserId FROM dbo.Users WHERE Username = N'admin01');

INSERT INTO dbo.Classes (ClassName, AcademicYearId, HomeroomTeacherId) VALUES
    (N'10A1', 1, @Teacher01),
    (N'10A2', 1, @Teacher02);

DECLARE @Class10A1 INT = (SELECT ClassId FROM dbo.Classes WHERE ClassName = N'10A1' AND AcademicYearId = 1);
DECLARE @Class10A2 INT = (SELECT ClassId FROM dbo.Classes WHERE ClassName = N'10A2' AND AcademicYearId = 1);

INSERT INTO dbo.Users
    (Username, PasswordHash, FullName, DateOfBirth, Gender, Address, Email, PhoneNumber, RoleId, DepartmentId, IsActive)
VALUES
    -- ★ Dev Quick Login · Học sinh
    (N'student01', @Hash, N'Nguyễn Thành Đạt',  '2010-01-10', N'Nam', N'Hà Nội', N'dat.nt@fschool.edu.vn',  N'0364828685', 4, NULL, 1),
    (N'student02', @Hash, N'Trần Ngọc Mai',     '2010-03-22', N'Nữ',  N'Hà Nội', N'mai.tn@fschool.edu.vn',  N'0901000007', 4, NULL, 1),
    (N'student03', @Hash, N'Lê Hoàng Phúc',     '2010-07-05', N'Nam', N'Hà Nội', N'phuc.lh@fschool.edu.vn', N'0901000008', 4, NULL, 1),
    (N'student04', @Hash, N'Phan Thị Thu Hà',   '2010-09-12', N'Nữ',  N'Hà Nội', N'ha.pt@fschool.edu.vn',   N'0901000009', 4, NULL, 1),
    (N'student05', @Hash, N'Đỗ Quang Huy',      '2010-12-01', N'Nam', N'Hà Nội', N'huy.dq@fschool.edu.vn',  N'0901000010', 4, NULL, 1),
    (N'student06', @Hash, N'Bùi Thị Cẩm Ly',    '2010-05-18', N'Nữ',  N'Hà Nội', N'ly.bt@fschool.edu.vn',   N'0901000011', 4, NULL, 1),
    -- ★ Dev Quick Login · Phụ huynh
    (N'parent01',  @Hash, N'Nguyễn Văn Tâm',    '1975-04-12', N'Nam', N'Hà Nội', N'tam.nv@gmail.com',       N'0786414311', 5, NULL, 1),
    (N'parent02',  @Hash, N'Trần Thị Bích Nga', '1980-08-30', N'Nữ',  N'Hà Nội', N'nga.tt@gmail.com',       N'0912000002', 5, NULL, 1),
    (N'parent03',  @Hash, N'Lê Văn Mạnh',       '1978-01-15', N'Nam', N'Hà Nội', N'manh.lv@gmail.com',      N'0912000003', 5, NULL, 1),
    (N'parent04',  @Hash, N'Phan Văn Dũng',     '1972-10-20', N'Nam', N'Hà Nội', N'dung.pv@gmail.com',      N'0912000004', 5, NULL, 1);

DECLARE @Student01 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'student01');
DECLARE @Student02 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'student02');
DECLARE @Student03 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'student03');
DECLARE @Student04 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'student04');
DECLARE @Student05 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'student05');
DECLARE @Student06 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'student06');
DECLARE @Parent01  INT = (SELECT UserId FROM dbo.Users WHERE Username = N'parent01');
DECLARE @Parent02  INT = (SELECT UserId FROM dbo.Users WHERE Username = N'parent02');
DECLARE @Parent03  INT = (SELECT UserId FROM dbo.Users WHERE Username = N'parent03');
DECLARE @Parent04  INT = (SELECT UserId FROM dbo.Users WHERE Username = N'parent04');

INSERT INTO dbo.StudentClasses (StudentId, ClassId) VALUES
    (@Student01, @Class10A1),
    (@Student02, @Class10A1),
    (@Student03, @Class10A1),
    (@Student04, @Class10A2),
    (@Student05, @Class10A2),
    (@Student06, @Class10A2);

INSERT INTO dbo.ParentStudents (ParentId, StudentId, Relationship) VALUES
    (@Parent01, @Student01, N'Cha'),
    (@Parent02, @Student02, N'Mẹ'),
    (@Parent03, @Student03, N'Cha'),
    (@Parent04, @Student04, N'Cha');

------------------------------------------------------------
-- 4) Phân công + TKB + điểm danh + điểm
------------------------------------------------------------
DECLARE @SemHk1 INT = (SELECT TOP 1 SemesterId FROM dbo.Semesters WHERE AcademicYearId = 1 AND SemesterName = N'Học kỳ 1');
DECLARE @SemHk2 INT = (SELECT TOP 1 SemesterId FROM dbo.Semesters WHERE AcademicYearId = 1 AND SemesterName = N'Học kỳ 2');
DECLARE @SubMath INT = (SELECT SubjectId FROM dbo.Subjects WHERE SubjectCode = N'MATH');
DECLARE @SubLit  INT = (SELECT SubjectId FROM dbo.Subjects WHERE SubjectCode = N'LIT');
DECLARE @SubEng  INT = (SELECT SubjectId FROM dbo.Subjects WHERE SubjectCode = N'ENG');

INSERT INTO dbo.TeachingAssignments (TeacherId, ClassId, SubjectId, SemesterId) VALUES
    (@Teacher01, @Class10A1, @SubMath, @SemHk1), -- TA1
    (@Teacher01, @Class10A2, @SubMath, @SemHk1), -- TA2
    (@Teacher02, @Class10A1, @SubLit,  @SemHk1), -- TA3
    (@Teacher02, @Class10A2, @SubLit,  @SemHk1), -- TA4
    (@Teacher03, @Class10A1, @SubEng,  @SemHk1), -- TA5
    (@Teacher03, @Class10A2, @SubEng,  @SemHk1); -- TA6

DECLARE @TA_Math_10A1 INT = (
    SELECT TeachingAssignmentId FROM dbo.TeachingAssignments
    WHERE TeacherId = @Teacher01 AND ClassId = @Class10A1 AND SubjectId = @SubMath AND SemesterId = @SemHk1
);
DECLARE @TA_Lit_10A1 INT = (
    SELECT TeachingAssignmentId FROM dbo.TeachingAssignments
    WHERE TeacherId = @Teacher02 AND ClassId = @Class10A1 AND SubjectId = @SubLit AND SemesterId = @SemHk1
);
DECLARE @TA_Eng_10A1 INT = (
    SELECT TeachingAssignmentId FROM dbo.TeachingAssignments
    WHERE TeacherId = @Teacher03 AND ClassId = @Class10A1 AND SubjectId = @SubEng AND SemesterId = @SemHk1
);

-- Timetables: schema hiện tại dùng Date + Status (0=Scheduled)
INSERT INTO dbo.Timetables (TeachingAssignmentId, [Date], SlotId, RoomName, Status, Note) VALUES
    (@TA_Math_10A1, '2025-09-08', 1, N'Phòng 101', 0, NULL),
    (@TA_Math_10A1, '2025-09-10', 2, N'Phòng 101', 0, NULL),
    (@TA_Lit_10A1,  '2025-09-09', 1, N'Phòng 202', 0, NULL),
    (@TA_Lit_10A1,  '2025-09-11', 3, N'Phòng 202', 0, NULL),
    (@TA_Eng_10A1,  '2025-09-09', 3, N'Phòng 305', 0, NULL),
    (@TA_Eng_10A1,  '2025-09-12', 4, N'Phòng 305', 0, NULL);

DECLARE @TtMath1 INT = (
    SELECT TOP 1 TimetableId FROM dbo.Timetables
    WHERE TeachingAssignmentId = @TA_Math_10A1 AND [Date] = '2025-09-08'
);

INSERT INTO dbo.AttendanceRecords (TimetableId, StudentId, Status, Note, RecordedBy, RecordedAt) VALUES
    (@TtMath1, @Student01, 'P', NULL, @Teacher01, SYSUTCDATETIME()),
    (@TtMath1, @Student02, 'P', NULL, @Teacher01, SYSUTCDATETIME()),
    (@TtMath1, @Student03, 'A', N'Nghỉ có phép', @Teacher01, SYSUTCDATETIME());

INSERT INTO dbo.Assessments (TeachingAssignmentId, AssessmentTypeId, AssessmentName, AssessmentDate, MaxScore) VALUES
    (@TA_Math_10A1, 2, N'Kiểm tra 15 phút - Chương 1', '2025-09-20', 10.0),
    (@TA_Math_10A1, 3, N'Kiểm tra 1 tiết - Chương 1',  '2025-10-15', 10.0),
    (@TA_Math_10A1, 4, N'Kiểm tra giữa kỳ 1',          '2025-11-10', 10.0);

DECLARE @Asm15p INT = (
    SELECT TOP 1 AssessmentId FROM dbo.Assessments
    WHERE TeachingAssignmentId = @TA_Math_10A1 AND AssessmentTypeId = 2
);

INSERT INTO dbo.Grades (AssessmentId, StudentId, Score, Comment, EnteredBy, EnteredAt) VALUES
    (@Asm15p, @Student01, 8.5, N'Tốt', @Teacher01, SYSUTCDATETIME()),
    (@Asm15p, @Student02, 7.0, NULL,   @Teacher01, SYSUTCDATETIME()),
    (@Asm15p, @Student03, 9.0, NULL,   @Teacher01, SYSUTCDATETIME());

------------------------------------------------------------
-- 5) Đơn nghỉ + bảng tin
------------------------------------------------------------
INSERT INTO dbo.StudentRequests
    (StudentId, RequestedBy, LeaveDate, Reason, Status, ReviewedBy, ReviewedAt, ReviewNote)
VALUES
    (@Student03, @Parent03, '2025-09-08',
        N'Bị sốt, có giấy xác nhận của bác sĩ', N'Approved', @Teacher01,
        '2025-09-07T19:00:00', N'Đồng ý nghỉ'),
    (@Student02, @Parent02, '2025-09-15',
        N'Gia đình có việc đột xuất', N'Pending', NULL, NULL, NULL),
    (@Student01, @Student01, CAST(DATEADD(DAY, 2, CAST(SYSUTCDATETIME() AS date)) AS date),
        N'Demo: xin nghỉ khám sức khỏe', N'Pending', NULL, NULL, NULL);

INSERT INTO dbo.Announcements
    (AuthorId, Title, Content, AnnouncementType, Priority, IsDeleted, CreatedAt, UpdatedAt)
VALUES
    (@Admin01,
        N'Thông báo nghỉ lễ Quốc khánh 2/9',
        N'Nhà trường thông báo học sinh, giáo viên được nghỉ lễ Quốc khánh từ ngày 01/09 đến 03/09/2025. Học sinh đi học trở lại vào ngày 04/09/2025.',
        N'global', N'high', 0, SYSUTCDATETIME(), SYSUTCDATETIME()),
    (@Teacher01,
        N'Lịch kiểm tra 1 tiết Toán chương 1',
        N'Các em học sinh lớp 10A1 chú ý: Kiểm tra 1 tiết chương 1 vào ngày 15/10/2025, tiết 1 buổi sáng. Nội dung: Mệnh đề, Tập hợp, Hàm số.',
        N'class', N'normal', 0, SYSUTCDATETIME(), SYSUTCDATETIME());

DECLARE @AnnGlobal INT = (
    SELECT TOP 1 AnnouncementId FROM dbo.Announcements WHERE AnnouncementType = N'global' ORDER BY AnnouncementId
);
DECLARE @AnnClass INT = (
    SELECT TOP 1 AnnouncementId FROM dbo.Announcements WHERE AnnouncementType = N'class' ORDER BY AnnouncementId DESC
);

INSERT INTO dbo.AnnouncementTargets (AnnouncementId, ClassId) VALUES
    (@AnnGlobal, NULL),
    (@AnnClass,  @Class10A1);

------------------------------------------------------------
-- 6) Học bạ mẫu (để màn Học bạ / Tổng kết lớp có số)
------------------------------------------------------------
DECLARE @RankGioi INT = (SELECT RankId FROM dbo.AcademicRanks WHERE RankName = N'Giỏi');
DECLARE @RankKha  INT = (SELECT RankId FROM dbo.AcademicRanks WHERE RankName = N'Khá');
DECLARE @YearId   INT = 1;

INSERT INTO dbo.StudentSemesterSummaries
    (StudentId, SemesterId, GPA, Conduct, RankId, EvaluatedBy, EvaluatedAt)
VALUES
    (@Student01, @SemHk1, 8.50, N'Tốt',        @RankGioi, @Teacher01, SYSUTCDATETIME()),
    (@Student02, @SemHk1, 7.20, N'Khá',        @RankKha,  @Teacher01, SYSUTCDATETIME()),
    (@Student03, @SemHk1, 8.10, N'Tốt',        @RankGioi, @Teacher01, SYSUTCDATETIME());

INSERT INTO dbo.StudentYearlySummaries
    (StudentId, AcademicYearId, YearlyGPA, YearlyConduct, RankId, EvaluatedBy, EvaluatedAt)
VALUES
    (@Student01, @YearId, 8.40, N'Tốt', @RankGioi, @Teacher01, SYSUTCDATETIME()),
    (@Student02, @YearId, 7.10, N'Khá', @RankKha,  @Teacher01, SYSUTCDATETIME()),
    (@Student03, @YearId, 8.00, N'Tốt', @RankGioi, @Teacher01, SYSUTCDATETIME());

COMMIT TRANSACTION;

------------------------------------------------------------
-- 7) Verify nhanh
------------------------------------------------------------
SELECT
    u.UserId, u.Username, u.FullName, u.PhoneNumber, r.RoleName
FROM dbo.Users u
JOIN dbo.Roles r ON r.RoleId = u.RoleId
WHERE u.Username IN (N'teacher01', N'parent01', N'student01')
ORDER BY r.RoleId;

SELECT N'OK — wipe + reseed demo 3 role xong. MK = 12345678' AS Message;
GO

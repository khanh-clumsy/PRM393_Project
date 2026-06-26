-- ============================================================
-- FSCHOOL DATABASE SCHEMA - SQL SERVER
-- Version: 4.4
-- Changes: Thêm bảng Departments, DepartmentId cho Users
--          Thêm DateOfBirth, Gender, Address cho Users
--          Thêm Index cho RefreshTokens
-- ============================================================

CREATE DATABASE PRM393DB;
GO

USE PRM393DB;
GO

-- ============================================================
-- PHẦN 1: CORE / AUTHENTICATION
-- ============================================================

CREATE TABLE Roles (
    RoleId      INT             NOT NULL IDENTITY(1,1),
    RoleName    NVARCHAR(50)    NOT NULL,
    CONSTRAINT PK_Roles PRIMARY KEY (RoleId),
    CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName)
);
GO

CREATE TABLE Departments (
    DepartmentId    INT             NOT NULL IDENTITY(1,1),
    DepartmentName  NVARCHAR(100)   NOT NULL,
    Description     NVARCHAR(200)   NULL,
    CONSTRAINT PK_Departments PRIMARY KEY (DepartmentId),
    CONSTRAINT UQ_Departments_Name UNIQUE (DepartmentName)
);
GO

CREATE TABLE Users (
    UserId          INT             NOT NULL IDENTITY(1,1),
    Username        NVARCHAR(50)    NOT NULL,
    PasswordHash    NVARCHAR(256)   NOT NULL,
    FullName        NVARCHAR(150)   NOT NULL,
    DateOfBirth     DATE            NULL,   -- Thêm mới
    Gender          NVARCHAR(10)    NULL,   -- Thêm mới (Nam/Nữ)
    Address         NVARCHAR(300)   NULL,   -- Thêm mới
    Email           NVARCHAR(150)   NULL,
    PhoneNumber     NVARCHAR(20)    NULL,
    AvatarUrl       NVARCHAR(500)   NULL,
    RoleId          INT             NOT NULL,
    DepartmentId    INT             NULL,   -- Thêm mới (Chỉ dành cho Giáo viên)
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_Users PRIMARY KEY (UserId),
    CONSTRAINT UQ_Users_Username UNIQUE (Username),
    CONSTRAINT UQ_Users_PhoneNumber UNIQUE (PhoneNumber),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId),
    CONSTRAINT FK_Users_Departments FOREIGN KEY (DepartmentId) REFERENCES Departments(DepartmentId)
);
GO

CREATE TABLE RefreshTokens (
    TokenId     INT             NOT NULL IDENTITY(1,1),
    UserId      INT             NOT NULL,
    Token       NVARCHAR(512)   NOT NULL,
    ExpiresAt   DATETIME2       NOT NULL,
    IsRevoked   BIT             NOT NULL DEFAULT 0,
    CreatedAt   DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_RefreshTokens PRIMARY KEY (TokenId),
    CONSTRAINT FK_RefreshTokens_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
GO

-- ============================================================
-- PHẦN 2: ACADEMIC STRUCTURE
-- ============================================================

CREATE TABLE AcademicYears (
    AcademicYearId  INT             NOT NULL IDENTITY(1,1),
    YearName        NVARCHAR(20)    NOT NULL,
    StartDate       DATE            NOT NULL,
    EndDate         DATE            NOT NULL,
    IsActive        BIT             NOT NULL DEFAULT 0,
    CONSTRAINT PK_AcademicYears PRIMARY KEY (AcademicYearId),
    CONSTRAINT UQ_AcademicYears_YearName UNIQUE (YearName)
);
GO

CREATE TABLE Semesters (
    SemesterId      INT             NOT NULL IDENTITY(1,1),
    AcademicYearId  INT             NOT NULL,
    SemesterName    NVARCHAR(50)    NOT NULL,
    StartDate       DATE            NOT NULL,
    EndDate         DATE            NOT NULL,
    CONSTRAINT PK_Semesters PRIMARY KEY (SemesterId),
    CONSTRAINT FK_Semesters_AcademicYears FOREIGN KEY (AcademicYearId) REFERENCES AcademicYears(AcademicYearId),
    CONSTRAINT UQ_Semesters_Year_Name UNIQUE (AcademicYearId, SemesterName)
);
GO

CREATE TABLE Subjects (
    SubjectId       INT             NOT NULL IDENTITY(1,1),
    SubjectCode     NVARCHAR(20)    NOT NULL,
    SubjectName     NVARCHAR(100)   NOT NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CONSTRAINT PK_Subjects PRIMARY KEY (SubjectId),
    CONSTRAINT UQ_Subjects_SubjectCode UNIQUE (SubjectCode)
);
GO

CREATE TABLE Classes (
    ClassId             INT             NOT NULL IDENTITY(1,1),
    ClassName           NVARCHAR(20)    NOT NULL,
    AcademicYearId      INT             NOT NULL,
    HomeroomTeacherId   INT             NULL,
    CONSTRAINT PK_Classes PRIMARY KEY (ClassId),
    CONSTRAINT FK_Classes_AcademicYears   FOREIGN KEY (AcademicYearId)    REFERENCES AcademicYears(AcademicYearId),
    CONSTRAINT FK_Classes_HomeroomTeacher FOREIGN KEY (HomeroomTeacherId) REFERENCES Users(UserId),
    CONSTRAINT UQ_Classes_NameYear        UNIQUE (ClassName, AcademicYearId)
);
GO

CREATE TABLE StudentClasses (
    StudentClassId  INT             NOT NULL IDENTITY(1,1),
    StudentId       INT             NOT NULL,
    ClassId         INT             NOT NULL,
    CONSTRAINT PK_StudentClasses PRIMARY KEY (StudentClassId),
    CONSTRAINT FK_SC_Students FOREIGN KEY (StudentId) REFERENCES Users(UserId),
    CONSTRAINT FK_SC_Classes FOREIGN KEY (ClassId) REFERENCES Classes(ClassId),
    CONSTRAINT UQ_StudentClasses UNIQUE (StudentId, ClassId)
);
GO

CREATE TABLE AcademicRanks (
    RankId          INT             NOT NULL IDENTITY(1,1),
    RankName        NVARCHAR(50)    NOT NULL,
    MinScore        DECIMAL(5,2)    NOT NULL,
    MaxScore        DECIMAL(5,2)    NOT NULL,
    CONSTRAINT PK_AcademicRanks PRIMARY KEY (RankId)
);
GO

CREATE TABLE ParentStudents (
    ParentStudentId INT             NOT NULL IDENTITY(1,1),
    ParentId        INT             NOT NULL,
    StudentId       INT             NOT NULL,
    Relationship    NVARCHAR(50)    NOT NULL DEFAULT N'Phụ huynh',
    CONSTRAINT PK_ParentStudents PRIMARY KEY (ParentStudentId),
    CONSTRAINT FK_PS_Parents  FOREIGN KEY (ParentId)  REFERENCES Users(UserId),
    CONSTRAINT FK_PS_Students FOREIGN KEY (StudentId) REFERENCES Users(UserId),
    CONSTRAINT UQ_ParentStudents UNIQUE (ParentId, StudentId)
);
GO

-- ============================================================
-- PHẦN 3: TEACHING ASSIGNMENTS
-- ============================================================

CREATE TABLE TeachingAssignments (
    TeachingAssignmentId    INT     NOT NULL IDENTITY(1,1),
    TeacherId               INT     NOT NULL,
    ClassId                 INT     NOT NULL,
    SubjectId               INT     NOT NULL,
    SemesterId              INT     NOT NULL,
    CONSTRAINT PK_TeachingAssignments PRIMARY KEY (TeachingAssignmentId),
    CONSTRAINT FK_TA_Teachers  FOREIGN KEY (TeacherId)  REFERENCES Users(UserId),
    CONSTRAINT FK_TA_Classes   FOREIGN KEY (ClassId)    REFERENCES Classes(ClassId),
    CONSTRAINT FK_TA_Subjects  FOREIGN KEY (SubjectId)  REFERENCES Subjects(SubjectId),
    CONSTRAINT FK_TA_Semesters FOREIGN KEY (SemesterId) REFERENCES Semesters(SemesterId),
    CONSTRAINT UQ_TeachingAssignments UNIQUE (TeacherId, ClassId, SubjectId, SemesterId)
);
GO

-- ============================================================
-- PHẦN 4: TIMETABLE
-- ============================================================

CREATE TABLE TimetableSlots (
    SlotId      INT             NOT NULL IDENTITY(1,1),
    SlotName    NVARCHAR(20)    NOT NULL,
    StartTime   TIME            NOT NULL,
    EndTime     TIME            NOT NULL,
    CONSTRAINT PK_TimetableSlots PRIMARY KEY (SlotId)
);
GO

CREATE TABLE Timetables (
    TimetableId             INT             NOT NULL IDENTITY(1,1),
    TeachingAssignmentId    INT             NOT NULL,
    DayOfWeek               TINYINT         NOT NULL,   -- 2=Thứ Hai ... 8=Chủ Nhật
    SlotId                  INT             NOT NULL,
    RoomName                NVARCHAR(50)    NULL,
    EffectiveFrom           DATE            NOT NULL,
    EffectiveTo             DATE            NULL,
    CONSTRAINT PK_Timetables PRIMARY KEY (TimetableId),
    CONSTRAINT FK_Timetables_TA    FOREIGN KEY (TeachingAssignmentId) REFERENCES TeachingAssignments(TeachingAssignmentId),
    CONSTRAINT FK_Timetables_Slots FOREIGN KEY (SlotId) REFERENCES TimetableSlots(SlotId),
    CONSTRAINT CHK_Timetables_Day  CHECK (DayOfWeek BETWEEN 2 AND 8)
);
GO

-- ============================================================
-- PHẦN 5: ATTENDANCE
-- ============================================================

CREATE TABLE AttendanceRecords (
    AttendanceId    INT             NOT NULL IDENTITY(1,1),
    TimetableId     INT             NOT NULL,
    StudentId       INT             NOT NULL,
    AttendanceDate  DATE            NOT NULL,
    Status          CHAR(1)         NOT NULL,   -- 'P'=Present, 'A'=Absent, 'L'=Late
    Note            NVARCHAR(200)   NULL,
    RecordedBy      INT             NOT NULL,
    RecordedAt      DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_AttendanceRecords PRIMARY KEY (AttendanceId),
    CONSTRAINT FK_Att_Timetable  FOREIGN KEY (TimetableId)  REFERENCES Timetables(TimetableId),
    CONSTRAINT FK_Att_Students   FOREIGN KEY (StudentId)    REFERENCES Users(UserId),
    CONSTRAINT FK_Att_RecordedBy FOREIGN KEY (RecordedBy)   REFERENCES Users(UserId),
    CONSTRAINT CHK_Att_Status    CHECK (Status IN ('P', 'A', 'L')),
    CONSTRAINT UQ_AttendanceRecords UNIQUE (TimetableId, StudentId, AttendanceDate)
);
GO

-- ============================================================
-- PHẦN 6: GRADES
-- ============================================================

CREATE TABLE AssessmentTypes (
    AssessmentTypeId    INT             NOT NULL IDENTITY(1,1),
    TypeName            NVARCHAR(100)   NOT NULL,
    Weight              DECIMAL(5,2)    NOT NULL,
    CONSTRAINT PK_AssessmentTypes PRIMARY KEY (AssessmentTypeId)
);
GO

CREATE TABLE Assessments (
    AssessmentId            INT             NOT NULL IDENTITY(1,1),
    TeachingAssignmentId    INT             NOT NULL,
    AssessmentTypeId        INT             NOT NULL,
    AssessmentName          NVARCHAR(150)   NOT NULL,
    AssessmentDate          DATE            NOT NULL,
    MaxScore                DECIMAL(5,2)    NOT NULL DEFAULT 10.0,
    CONSTRAINT PK_Assessments PRIMARY KEY (AssessmentId),
    CONSTRAINT FK_Assess_TA   FOREIGN KEY (TeachingAssignmentId) REFERENCES TeachingAssignments(TeachingAssignmentId),
    CONSTRAINT FK_Assess_Type FOREIGN KEY (AssessmentTypeId)     REFERENCES AssessmentTypes(AssessmentTypeId)
);
GO

CREATE TABLE Grades (
    GradeId         INT             NOT NULL IDENTITY(1,1),
    AssessmentId    INT             NOT NULL,
    StudentId       INT             NOT NULL,
    Score           DECIMAL(5,2)    NULL,
    Comment         NVARCHAR(200)   NULL,
    EnteredBy       INT             NOT NULL,
    EnteredAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_Grades PRIMARY KEY (GradeId),
    CONSTRAINT FK_Grades_Assessments FOREIGN KEY (AssessmentId) REFERENCES Assessments(AssessmentId),
    CONSTRAINT FK_Grades_Students    FOREIGN KEY (StudentId)    REFERENCES Users(UserId),
    CONSTRAINT FK_Grades_EnteredBy   FOREIGN KEY (EnteredBy)    REFERENCES Users(UserId),
    CONSTRAINT CHK_Grades_Score      CHECK (Score IS NULL OR (Score >= 0 AND Score <= 10)),
    CONSTRAINT UQ_Grades             UNIQUE (AssessmentId, StudentId)
);
GO

CREATE TABLE StudentSemesterSummaries (
    SummaryId       INT             NOT NULL IDENTITY(1,1),
    StudentId       INT             NOT NULL,
    SemesterId      INT             NOT NULL,
    GPA             DECIMAL(5,2)    NULL,
    Conduct         NVARCHAR(50)    NULL, -- Tốt, Khá, Trung Bình, Yếu
    RankId          INT             NULL,
    EvaluatedBy     INT             NULL,
    EvaluatedAt     DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_StudentSemesterSummaries PRIMARY KEY (SummaryId),
    CONSTRAINT FK_SSS_Students FOREIGN KEY (StudentId) REFERENCES Users(UserId),
    CONSTRAINT FK_SSS_Semesters FOREIGN KEY (SemesterId) REFERENCES Semesters(SemesterId),
    CONSTRAINT FK_SSS_Ranks FOREIGN KEY (RankId) REFERENCES AcademicRanks(RankId),
    CONSTRAINT FK_SSS_EvaluatedBy FOREIGN KEY (EvaluatedBy) REFERENCES Users(UserId),
    CONSTRAINT UQ_StudentSemesterSummaries UNIQUE (StudentId, SemesterId)
);
GO

CREATE TABLE StudentYearlySummaries (
    YearlySummaryId INT             NOT NULL IDENTITY(1,1),
    StudentId       INT             NOT NULL,
    AcademicYearId  INT             NOT NULL,
    YearlyGPA       DECIMAL(5,2)    NULL,
    YearlyConduct   NVARCHAR(50)    NULL,
    RankId          INT             NULL,
    EvaluatedBy     INT             NULL,
    EvaluatedAt     DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_StudentYearlySummaries PRIMARY KEY (YearlySummaryId),
    CONSTRAINT FK_SYS_Students FOREIGN KEY (StudentId) REFERENCES Users(UserId),
    CONSTRAINT FK_SYS_AcademicYears FOREIGN KEY (AcademicYearId) REFERENCES AcademicYears(AcademicYearId),
    CONSTRAINT FK_SYS_Ranks FOREIGN KEY (RankId) REFERENCES AcademicRanks(RankId),
    CONSTRAINT FK_SYS_EvaluatedBy FOREIGN KEY (EvaluatedBy) REFERENCES Users(UserId),
    CONSTRAINT UQ_StudentYearlySummaries UNIQUE (StudentId, AcademicYearId)
);
GO

-- ============================================================
-- PHẦN 7: ASSIGNMENTS & SUBMISSIONS
-- ============================================================

CREATE TABLE Assignments (
    AssignmentId            INT             NOT NULL IDENTITY(1,1),
    TeachingAssignmentId    INT             NOT NULL,
    Title                   NVARCHAR(200)   NOT NULL,
    Description             NVARCHAR(MAX)   NULL,
    AttachmentUrl           NVARCHAR(500)   NULL,
    DueDate                 DATETIME2       NOT NULL,
    CreatedBy               INT             NOT NULL,
    CreatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt               DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    IsDeleted               BIT             NOT NULL DEFAULT 0,
    CONSTRAINT PK_Assignments PRIMARY KEY (AssignmentId),
    CONSTRAINT FK_Assign_TA        FOREIGN KEY (TeachingAssignmentId) REFERENCES TeachingAssignments(TeachingAssignmentId),
    CONSTRAINT FK_Assign_CreatedBy FOREIGN KEY (CreatedBy)            REFERENCES Users(UserId)
);
GO

CREATE TABLE Submissions (
    SubmissionId    INT             NOT NULL IDENTITY(1,1),
    AssignmentId    INT             NOT NULL,
    StudentId       INT             NOT NULL,
    ContentText     NVARCHAR(MAX)   NULL,
    FileUrl         NVARCHAR(500)   NULL,
    LinkUrl         NVARCHAR(500)   NULL,
    SubmittedAt     DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    Score           DECIMAL(5,2)    NULL,
    Feedback        NVARCHAR(500)   NULL,
    GradedBy        INT             NULL,
    GradedAt        DATETIME2       NULL,
    CONSTRAINT PK_Submissions PRIMARY KEY (SubmissionId),
    CONSTRAINT FK_Sub_Assignments FOREIGN KEY (AssignmentId) REFERENCES Assignments(AssignmentId),
    CONSTRAINT FK_Sub_Students    FOREIGN KEY (StudentId)    REFERENCES Users(UserId),
    CONSTRAINT FK_Sub_GradedBy    FOREIGN KEY (GradedBy)     REFERENCES Users(UserId),
    CONSTRAINT UQ_Submissions     UNIQUE (AssignmentId, StudentId)
);
GO

-- ============================================================
-- PHẦN 8: STUDENT REQUESTS
-- ============================================================

CREATE TABLE StudentRequests (
    StudentRequestId    INT             NOT NULL IDENTITY(1,1),
    StudentId           INT             NOT NULL,
    RequestedBy         INT             NOT NULL,
    LeaveDate           DATE            NOT NULL,
    Reason              NVARCHAR(500)   NOT NULL,
    AttachmentUrl       NVARCHAR(500)   NULL,
    Status              NVARCHAR(20)    NOT NULL DEFAULT 'Pending',
    ReviewedBy          INT             NULL,
    ReviewedAt          DATETIME2       NULL,
    ReviewNote          NVARCHAR(300)   NULL,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_StudentRequests PRIMARY KEY (StudentRequestId),
    CONSTRAINT FK_SR_Students    FOREIGN KEY (StudentId)   REFERENCES Users(UserId),
    CONSTRAINT FK_SR_RequestedBy FOREIGN KEY (RequestedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_SR_ReviewedBy  FOREIGN KEY (ReviewedBy)  REFERENCES Users(UserId),
    CONSTRAINT CHK_SR_Status     CHECK (Status IN ('Pending', 'Approved', 'Rejected'))
);
GO

-- ============================================================
-- PHẦN 9: ANNOUNCEMENTS & NOTIFICATIONS
-- ============================================================

CREATE TABLE Announcements (
    AnnouncementId      INT             NOT NULL IDENTITY(1,1),
    AuthorId            INT             NOT NULL,
    Title               NVARCHAR(200)   NOT NULL,
    Content             NVARCHAR(MAX)   NOT NULL,
    AnnouncementType    NVARCHAR(20)    NOT NULL,   -- 'global', 'class', 'internal'
    Priority            NVARCHAR(20)    NOT NULL DEFAULT 'normal',
    IsDeleted           BIT             NOT NULL DEFAULT 0,
    CreatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_Announcements PRIMARY KEY (AnnouncementId),
    CONSTRAINT FK_Ann_Author  FOREIGN KEY (AuthorId) REFERENCES Users(UserId),
    CONSTRAINT CHK_Ann_Type   CHECK (AnnouncementType IN ('global', 'class', 'internal')),
    CONSTRAINT CHK_Ann_Prio   CHECK (Priority IN ('normal', 'high', 'urgent'))
);
GO

CREATE TABLE AnnouncementTargets (
    TargetId        INT     NOT NULL IDENTITY(1,1),
    AnnouncementId  INT     NOT NULL,
    ClassId         INT     NULL,   -- NULL = toàn trường
    CONSTRAINT PK_AnnouncementTargets PRIMARY KEY (TargetId),
    CONSTRAINT FK_AT_Announcements FOREIGN KEY (AnnouncementId) REFERENCES Announcements(AnnouncementId),
    CONSTRAINT FK_AT_Classes       FOREIGN KEY (ClassId)        REFERENCES Classes(ClassId)
);
GO

CREATE TABLE NotificationLogs (
    NotificationId  INT             NOT NULL IDENTITY(1,1),
    UserId          INT             NOT NULL,
    AnnouncementId  INT             NULL,
    Title           NVARCHAR(200)   NOT NULL,
    Body            NVARCHAR(500)   NOT NULL,
    IsRead          BIT             NOT NULL DEFAULT 0,
    ReadAt          DATETIME2       NULL,
    CreatedAt       DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_NotificationLogs PRIMARY KEY (NotificationId),
    CONSTRAINT FK_NL_Users         FOREIGN KEY (UserId)         REFERENCES Users(UserId),
    CONSTRAINT FK_NL_Announcements FOREIGN KEY (AnnouncementId) REFERENCES Announcements(AnnouncementId)
);
GO

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IX_Users_Username ON Users(Username);
CREATE INDEX IX_Users_RoleId   ON Users(RoleId);
CREATE INDEX IX_SC_ClassId    ON StudentClasses(ClassId);
CREATE INDEX IX_SC_StudentId  ON StudentClasses(StudentId);

CREATE INDEX IX_TA_TeacherId  ON TeachingAssignments(TeacherId);
CREATE INDEX IX_TA_ClassId    ON TeachingAssignments(ClassId);
CREATE INDEX IX_TA_SemesterId ON TeachingAssignments(SemesterId);

CREATE INDEX IX_Att_Date      ON AttendanceRecords(AttendanceDate);
CREATE INDEX IX_Att_StudentId ON AttendanceRecords(StudentId);

CREATE INDEX IX_Grades_StudentId    ON Grades(StudentId);
CREATE INDEX IX_Grades_AssessmentId ON Grades(AssessmentId);

CREATE INDEX IX_SSS_StudentId  ON StudentSemesterSummaries(StudentId);
CREATE INDEX IX_SSS_SemesterId ON StudentSemesterSummaries(SemesterId);

CREATE INDEX IX_SYS_StudentId       ON StudentYearlySummaries(StudentId);
CREATE INDEX IX_SYS_AcademicYearId  ON StudentYearlySummaries(AcademicYearId);

CREATE INDEX IX_Assign_DueDate   ON Assignments(DueDate);
CREATE INDEX IX_Assign_IsDeleted ON Assignments(IsDeleted);

CREATE INDEX IX_Sub_AssignmentId ON Submissions(AssignmentId);
CREATE INDEX IX_Sub_StudentId    ON Submissions(StudentId);

CREATE INDEX IX_SR_StudentId ON StudentRequests(StudentId);
CREATE INDEX IX_SR_Status    ON StudentRequests(Status);

CREATE INDEX IX_Ann_Type      ON Announcements(AnnouncementType);
CREATE INDEX IX_Ann_CreatedAt ON Announcements(CreatedAt DESC);

CREATE INDEX IX_NL_UserId_IsRead ON NotificationLogs(UserId, IsRead);

CREATE INDEX IX_RefreshTokens_Token  ON RefreshTokens(Token);
CREATE INDEX IX_RefreshTokens_UserId ON RefreshTokens(UserId);
GO

-- ============================================================
-- SEED DATA
-- ============================================================

-- Roles
INSERT INTO Roles (RoleName) VALUES
    ('Admin'),
    ('HeadOfDept'),
    ('Teacher'),
    ('Student'),
    ('Parent');
GO

-- AssessmentTypes
INSERT INTO AssessmentTypes (TypeName, Weight) VALUES
    (N'Kiểm tra miệng',     1.0),
    (N'Kiểm tra 15 phút',   1.0),
    (N'Kiểm tra 1 tiết',    2.0),
    (N'Kiểm tra giữa kỳ',   2.0),
    (N'Kiểm tra cuối kỳ',   3.0);
GO

-- TimetableSlots
INSERT INTO TimetableSlots (SlotName, StartTime, EndTime) VALUES
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
GO

-- AcademicYears
INSERT INTO AcademicYears (YearName, StartDate, EndDate, IsActive) VALUES
    (N'2025-2026', '2025-09-01', '2026-05-31', 1);
GO

-- Semesters
INSERT INTO Semesters (AcademicYearId, SemesterName, StartDate, EndDate) VALUES
    (1, N'Học kỳ 1', '2025-09-01', '2026-01-15'),
    (1, N'Học kỳ 2', '2026-01-20', '2026-05-31');
GO

-- Subjects
INSERT INTO Subjects (SubjectCode, SubjectName) VALUES
    ('MATH',  N'Toán'),
    ('LIT',   N'Ngữ Văn'),
    ('ENG',   N'Tiếng Anh'),
    ('PHY',   N'Vật Lý'),
    ('CHEM',  N'Hóa Học'),
    ('BIO',   N'Sinh Học'),
    ('HIST',  N'Lịch Sử'),
    ('GEO',   N'Địa Lý'),
    ('IT',    N'Tin Học'),
    ('PE',    N'Thể Dục');
GO

-- Departments
INSERT INTO Departments (DepartmentName) VALUES
    (N'Tổ Toán - Tin'),
    (N'Tổ Ngữ Văn'),
    (N'Tổ Ngoại Ngữ'),
    (N'Tổ Khoa học Tự nhiên');
GO

-- Users: Admin, HeadOfDept, Teachers trước (ClassId = NULL)
DECLARE @demoHash NVARCHAR(256) = '$2a$12$demo.hash.for.seed.data.only.not.real.bcrypt';

INSERT INTO Users (Username, PasswordHash, FullName, DateOfBirth, Gender, Address, Email, PhoneNumber, RoleId, DepartmentId) VALUES
    ('admin01',   @demoHash, N'Nguyễn Văn Admin',  '1980-05-15', N'Nam', N'Hà Nội', 'admin@fschool.edu.vn',    '0901000001', 1, NULL),
    ('hodept01',  @demoHash, N'Trần Thị Lan Anh',  '1985-08-20', N'Nữ',  N'Hà Nội', 'lananh@fschool.edu.vn',   '0901000002', 2, 2), -- Tổ Văn
    ('teacher01', @demoHash, N'Phạm Minh Tuấn',    '1990-02-10', N'Nam', N'Hà Nội', 'tuan.pm@fschool.edu.vn',  '0901000003', 3, 1), -- Tổ Toán - Tin
    ('teacher02', @demoHash, N'Lê Thị Hương',      '1992-11-05', N'Nữ',  N'Hà Nội', 'huong.lt@fschool.edu.vn', '0901000004', 3, 2), -- Tổ Văn
    ('teacher03', @demoHash, N'Võ Thanh Bình',     '1988-09-25', N'Nam', N'Hà Nội', 'binh.vt@fschool.edu.vn',  '0901000005', 3, 3); -- Tổ Ngoại Ngữ
GO

-- Classes (cần UserId GV đã có trước)
INSERT INTO Classes (ClassName, AcademicYearId, HomeroomTeacherId) VALUES
    (N'10A1', 1, 3),   -- teacher01 chủ nhiệm
    (N'10A2', 1, 4);   -- teacher02 chủ nhiệm
GO

-- Users: Students (ClassId trỏ vào lớp) và Parents
DECLARE @demoHash NVARCHAR(256) = '$2a$12$demo.hash.for.seed.data.only.not.real.bcrypt';

INSERT INTO Users (Username, PasswordHash, FullName, DateOfBirth, Gender, Address, Email, PhoneNumber, RoleId, DepartmentId) VALUES
    -- Học sinh lớp 10A1
    ('student01', @demoHash, N'Nguyễn Thành Đạt',  '2010-01-10', N'Nam', N'Hà Nội', 'dat.nt@fschool.edu.vn',  '0901000006', 4, NULL),
    ('student02', @demoHash, N'Trần Ngọc Mai',     '2010-03-22', N'Nữ',  N'Hà Nội', 'mai.tn@fschool.edu.vn',  '0901000007', 4, NULL),
    ('student03', @demoHash, N'Lê Hoàng Phúc',     '2010-07-05', N'Nam', N'Hà Nội', 'phuc.lh@fschool.edu.vn', '0901000008', 4, NULL),
    -- Học sinh lớp 10A2
    ('student04', @demoHash, N'Phan Thị Thu Hà',   '2010-09-12', N'Nữ',  N'Hà Nội', 'ha.pt@fschool.edu.vn',   '0901000009', 4, NULL),
    ('student05', @demoHash, N'Đỗ Quang Huy',      '2010-12-01', N'Nam', N'Hà Nội', 'huy.dq@fschool.edu.vn',  '0901000010', 4, NULL),
    ('student06', @demoHash, N'Bùi Thị Cẩm Ly',    '2010-05-18', N'Nữ',  N'Hà Nội', 'ly.bt@fschool.edu.vn',   '0901000011', 4, NULL),
    -- Phụ huynh
    ('parent01',  @demoHash, N'Nguyễn Văn Tâm',    '1975-04-12', N'Nam', N'Hà Nội', 'tam.nv@gmail.com',       '0912000001', 5, NULL),
    ('parent02',  @demoHash, N'Trần Thị Bích Nga', '1980-08-30', N'Nữ',  N'Hà Nội', 'nga.tt@gmail.com',       '0912000002', 5, NULL),
    ('parent03',  @demoHash, N'Lê Văn Mạnh',       '1978-01-15', N'Nam', N'Hà Nội', 'manh.lv@gmail.com',      '0912000003', 5, NULL),
    ('parent04',  @demoHash, N'Phan Văn Dũng',     '1972-10-20', N'Nam', N'Hà Nội', 'dung.pv@gmail.com',      '0912000004', 5, NULL);
GO

-- StudentClasses
INSERT INTO StudentClasses (StudentId, ClassId) VALUES
    (6, 1), (7, 1), (8, 1), -- Lớp 10A1
    (9, 2), (10, 2), (11, 2); -- Lớp 10A2
GO

-- AcademicRanks
INSERT INTO AcademicRanks (RankName, MinScore, MaxScore) VALUES
    (N'Giỏi', 8.0, 10.0),
    (N'Khá', 6.5, 7.99),
    (N'Trung Bình', 5.0, 6.49),
    (N'Yếu', 3.5, 4.99),
    (N'Kém', 0.0, 3.49);
GO

-- ParentStudents
INSERT INTO ParentStudents (ParentId, StudentId, Relationship) VALUES
    (12, 6,  N'Cha'),
    (13, 7,  N'Mẹ'),
    (14, 8,  N'Cha'),
    (15, 9,  N'Cha');
GO

-- TeachingAssignments
INSERT INTO TeachingAssignments (TeacherId, ClassId, SubjectId, SemesterId) VALUES
    (3, 1, 1, 1),   -- teacher01 - Toán - 10A1 - HK1
    (3, 2, 1, 1),   -- teacher01 - Toán - 10A2 - HK1
    (4, 1, 2, 1),   -- teacher02 - Văn  - 10A1 - HK1
    (4, 2, 2, 1),   -- teacher02 - Văn  - 10A2 - HK1
    (5, 1, 3, 1),   -- teacher03 - Anh  - 10A1 - HK1
    (5, 2, 3, 1);   -- teacher03 - Anh  - 10A2 - HK1
GO

-- Timetables (lớp 10A1)
INSERT INTO Timetables (TeachingAssignmentId, DayOfWeek, SlotId, RoomName, EffectiveFrom) VALUES
    (1, 2, 1, N'Phòng 101', '2025-09-01'),   -- Toán - Thứ 2 - Tiết 1
    (1, 4, 2, N'Phòng 101', '2025-09-01'),   -- Toán - Thứ 4 - Tiết 2
    (3, 3, 1, N'Phòng 202', '2025-09-01'),   -- Văn  - Thứ 3 - Tiết 1
    (3, 5, 3, N'Phòng 202', '2025-09-01'),   -- Văn  - Thứ 6 - Tiết 3
    (5, 3, 3, N'Phòng 305', '2025-09-01'),   -- Anh  - Thứ 3 - Tiết 3
    (5, 6, 4, N'Phòng 305', '2025-09-01');   -- Anh  - Thứ 6 - Tiết 4
GO

-- AttendanceRecords
INSERT INTO AttendanceRecords (TimetableId, StudentId, AttendanceDate, Status, RecordedBy) VALUES
    (1, 6, '2025-09-08', 'P', 3),
    (1, 7, '2025-09-08', 'P', 3),
    (1, 8, '2025-09-08', 'A', 3);
GO

-- Assessments
INSERT INTO Assessments (TeachingAssignmentId, AssessmentTypeId, AssessmentName, AssessmentDate) VALUES
    (1, 2, N'Kiểm tra 15 phút - Chương 1', '2025-09-20'),
    (1, 3, N'Kiểm tra 1 tiết - Chương 1',  '2025-10-15'),
    (1, 4, N'Kiểm tra giữa kỳ 1',          '2025-11-10');
GO

-- Grades
INSERT INTO Grades (AssessmentId, StudentId, Score, EnteredBy) VALUES
    (1, 6, 8.5, 3),
    (1, 7, 7.0, 3),
    (1, 8, 9.0, 3);
GO

-- Assignments
INSERT INTO Assignments (TeachingAssignmentId, Title, Description, DueDate, CreatedBy) VALUES
    (1, N'Bài tập chương 1: Mệnh đề và tập hợp',
       N'Làm bài tập từ trang 15 đến trang 20 - SGK Toán 10',
       '2025-09-25 23:59:00', 3),
    (1, N'Ôn tập kiểm tra 1 tiết chương 1',
       N'Giải đề cương ôn tập giáo viên phát, nộp trước ngày kiểm tra',
       '2025-10-14 23:59:00', 3);
GO

-- Submissions
INSERT INTO Submissions (AssignmentId, StudentId, LinkUrl, SubmittedAt) VALUES
    (1, 6, 'https://drive.google.com/file/student01-bt1', '2025-09-24 20:30:00'),
    (1, 7, 'https://drive.google.com/file/student02-bt1', '2025-09-25 18:00:00');
GO

-- StudentRequests
INSERT INTO StudentRequests (StudentId, RequestedBy, LeaveDate, Reason, Status, ReviewedBy, ReviewedAt) VALUES
    (8, 14, '2025-09-08', N'Bị sốt, có giấy xác nhận của bác sĩ',
        'Approved', 3, '2025-09-07 19:00:00'),
    (7, 13, '2025-09-15', N'Gia đình có việc đột xuất',
        'Pending', NULL, NULL);
GO

-- Announcements
INSERT INTO Announcements (AuthorId, Title, Content, AnnouncementType, Priority) VALUES
    (1, N'Thông báo nghỉ lễ Quốc khánh 2/9',
       N'Nhà trường thông báo học sinh, giáo viên được nghỉ lễ Quốc khánh từ ngày 01/09 đến 03/09/2025. Học sinh đi học trở lại vào ngày 04/09/2025.',
       'global', 'high'),
    (3, N'Lịch kiểm tra 1 tiết Toán chương 1',
       N'Các em học sinh lớp 10A1 chú ý: Kiểm tra 1 tiết chương 1 vào ngày 15/10/2025, tiết 1 buổi sáng. Nội dung: Mệnh đề, Tập hợp, Hàm số.',
       'class', 'normal');
GO

-- AnnouncementTargets
INSERT INTO AnnouncementTargets (AnnouncementId, ClassId) VALUES
    (1, NULL),  -- global -> toàn trường
    (2, 1);     -- class  -> 10A1
GO

-- NotificationLogs
INSERT INTO NotificationLogs (UserId, AnnouncementId, Title, Body, IsRead) VALUES
    (6,  2, N'Lịch kiểm tra 1 tiết Toán', N'Kiểm tra 1 tiết Toán chương 1 vào ngày 15/10/2025.', 0),
    (7,  2, N'Lịch kiểm tra 1 tiết Toán', N'Kiểm tra 1 tiết Toán chương 1 vào ngày 15/10/2025.', 1),
    (8,  2, N'Lịch kiểm tra 1 tiết Toán', N'Kiểm tra 1 tiết Toán chương 1 vào ngày 15/10/2025.', 0),
    (12, 2, N'Lịch kiểm tra 1 tiết Toán', N'Con bạn có lịch kiểm tra Toán ngày 15/10/2025.',     0);
GO
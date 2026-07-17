/*
================================================================================
  003_seed_summaries_student01_02.sql  (cập nhật)

  1) WIPE điểm: Grades + Assessments  (KHÔNG đụng Timetables / Attendance)
  2) Seed lại cột điểm (Assessments) + Grades cho student01/02
  3) Seed lại StudentSemesterSummaries + StudentYearlySummaries

  Năm học: IsActive = 1
  Môn: Toán / Ngữ Văn / Tiếng Anh của lớp student01 (qua StudentClasses + TeachingAssignments)

  An toàn với lịch học demo:
    - Timetables, TimetableSlots, AttendanceRecords: GIỮ NGUYÊN
    - Chỉ xóa điểm thi (Grades) và cột điểm (Assessments)
================================================================================
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

DECLARE @Student01 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'student01');
DECLARE @Student02 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'student02');
DECLARE @Teacher01 INT = (SELECT UserId FROM dbo.Users WHERE Username = N'teacher01');

IF @Student01 IS NULL OR @Student02 IS NULL
BEGIN
    RAISERROR(N'Không tìm thấy student01 hoặc student02.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN;
END;

DECLARE @YearId INT = (
    SELECT TOP 1 AcademicYearId
    FROM dbo.AcademicYears
    ORDER BY CASE WHEN IsActive = 1 THEN 0 ELSE 1 END, AcademicYearId
);

DECLARE @SemHk1 INT = (
    SELECT TOP 1 SemesterId FROM dbo.Semesters
    WHERE AcademicYearId = @YearId ORDER BY StartDate, SemesterId
);
DECLARE @SemHk2 INT = (
    SELECT TOP 1 SemesterId FROM dbo.Semesters
    WHERE AcademicYearId = @YearId AND SemesterId <> @SemHk1
    ORDER BY StartDate, SemesterId
);

DECLARE @RankGioi INT = (SELECT TOP 1 RankId FROM dbo.AcademicRanks WHERE RankName = N'Giỏi');
DECLARE @RankKha  INT = (SELECT TOP 1 RankId FROM dbo.AcademicRanks WHERE RankName = N'Khá');

DECLARE @Type15p INT = (SELECT TOP 1 AssessmentTypeId FROM dbo.AssessmentTypes WHERE TypeName LIKE N'%15%');
DECLARE @Type1Tiet INT = (SELECT TOP 1 AssessmentTypeId FROM dbo.AssessmentTypes WHERE TypeName LIKE N'%1 tiết%');
DECLARE @TypeGk INT = (SELECT TOP 1 AssessmentTypeId FROM dbo.AssessmentTypes WHERE TypeName LIKE N'%giữa kỳ%');

IF @YearId IS NULL OR @SemHk1 IS NULL OR @Type15p IS NULL OR @Type1Tiet IS NULL OR @TypeGk IS NULL
BEGIN
    RAISERROR(N'Thiếu AcademicYears / Semesters / AssessmentTypes.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN;
END;

------------------------------------------------------------
-- 1) WIPE điểm (không đụng lịch học)
------------------------------------------------------------
DELETE FROM dbo.Grades;
DELETE FROM dbo.Assessments;

-- Xóa summary cũ của 2 HS trên năm active (để seed lại sạch)
DELETE s FROM dbo.StudentSemesterSummaries s
WHERE s.StudentId IN (@Student01, @Student02)
  AND s.SemesterId IN (SELECT SemesterId FROM dbo.Semesters WHERE AcademicYearId = @YearId);

DELETE y FROM dbo.StudentYearlySummaries y
WHERE y.StudentId IN (@Student01, @Student02)
  AND y.AcademicYearId = @YearId;

------------------------------------------------------------
-- 2) TeachingAssignments của lớp student01 trong HK1 (và HK2 nếu có)
------------------------------------------------------------
DECLARE @ClassId INT = (
    SELECT TOP 1 sc.ClassId
    FROM dbo.StudentClasses sc
    WHERE sc.StudentId = @Student01
    ORDER BY sc.StudentClassId
);

IF @ClassId IS NULL
BEGIN
    RAISERROR(N'student01 chưa được xếp lớp (StudentClasses).', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN;
END;

-- Đảm bảo student02 cùng lớp (nếu chưa có thì gắn vào lớp student01 để demo)
IF NOT EXISTS (SELECT 1 FROM dbo.StudentClasses WHERE StudentId = @Student02 AND ClassId = @ClassId)
BEGIN
    INSERT INTO dbo.StudentClasses (StudentId, ClassId) VALUES (@Student02, @ClassId);
END;

DECLARE @TA TABLE (TeachingAssignmentId INT, SubjectName NVARCHAR(100), SemesterId INT);

INSERT INTO @TA (TeachingAssignmentId, SubjectName, SemesterId)
SELECT ta.TeachingAssignmentId, sub.SubjectName, ta.SemesterId
FROM dbo.TeachingAssignments ta
JOIN dbo.Subjects sub ON sub.SubjectId = ta.SubjectId
WHERE ta.ClassId = @ClassId
  AND ta.SemesterId IN (@SemHk1, ISNULL(@SemHk2, -1));

IF NOT EXISTS (SELECT 1 FROM @TA)
BEGIN
    RAISERROR(N'Không có TeachingAssignment cho lớp của student01 trong năm active. Cần phân công môn trước.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN;
END;

DECLARE @EnteredBy INT = ISNULL(@Teacher01, @Student01);

------------------------------------------------------------
-- 3) Tạo Assessments + Grades cho mỗi TA
------------------------------------------------------------
DECLARE @TaId INT, @SubName NVARCHAR(100), @SemId INT;
DECLARE @Asm15 INT, @Asm1T INT, @AsmGk INT;

DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT TeachingAssignmentId, SubjectName, SemesterId FROM @TA;
OPEN cur;
FETCH NEXT FROM cur INTO @TaId, @SubName, @SemId;
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO dbo.Assessments (TeachingAssignmentId, AssessmentTypeId, AssessmentName, AssessmentDate, MaxScore)
    VALUES (@TaId, @Type15p, N'KT 15p - ' + @SubName, '2025-10-01', 10.0);
    SET @Asm15 = SCOPE_IDENTITY();

    INSERT INTO dbo.Assessments (TeachingAssignmentId, AssessmentTypeId, AssessmentName, AssessmentDate, MaxScore)
    VALUES (@TaId, @Type1Tiet, N'KT 1 tiết - ' + @SubName, '2025-11-01', 10.0);
    SET @Asm1T = SCOPE_IDENTITY();

    INSERT INTO dbo.Assessments (TeachingAssignmentId, AssessmentTypeId, AssessmentName, AssessmentDate, MaxScore)
    VALUES (@TaId, @TypeGk, N'Giữa kỳ - ' + @SubName, '2025-12-01', 10.0);
    SET @AsmGk = SCOPE_IDENTITY();

    -- student01 — điểm khá/giỏi
    INSERT INTO dbo.Grades (AssessmentId, StudentId, Score, Comment, EnteredBy, EnteredAt) VALUES
        (@Asm15, @Student01, 8.5, NULL, @EnteredBy, SYSUTCDATETIME()),
        (@Asm1T, @Student01, 8.0, NULL, @EnteredBy, SYSUTCDATETIME()),
        (@AsmGk, @Student01, 9.0, NULL, @EnteredBy, SYSUTCDATETIME());

    -- student02 — điểm khá
    INSERT INTO dbo.Grades (AssessmentId, StudentId, Score, Comment, EnteredBy, EnteredAt) VALUES
        (@Asm15, @Student02, 7.0, NULL, @EnteredBy, SYSUTCDATETIME()),
        (@Asm1T, @Student02, 7.5, NULL, @EnteredBy, SYSUTCDATETIME()),
        (@AsmGk, @Student02, 7.0, NULL, @EnteredBy, SYSUTCDATETIME());

    FETCH NEXT FROM cur INTO @TaId, @SubName, @SemId;
END
CLOSE cur;
DEALLOCATE cur;

------------------------------------------------------------
-- 4) Summaries HK + năm
------------------------------------------------------------
MERGE dbo.StudentSemesterSummaries AS t
USING (VALUES
    (@Student01, @SemHk1, CAST(8.50 AS decimal(5,2)), N'Tốt', @RankGioi),
    (@Student02, @SemHk1, CAST(7.20 AS decimal(5,2)), N'Khá',  @RankKha)
) AS s (StudentId, SemesterId, GPA, Conduct, RankId)
ON t.StudentId = s.StudentId AND t.SemesterId = s.SemesterId
WHEN MATCHED THEN UPDATE SET
    GPA = s.GPA, Conduct = s.Conduct, RankId = s.RankId,
    EvaluatedBy = @EnteredBy, EvaluatedAt = SYSUTCDATETIME()
WHEN NOT MATCHED THEN INSERT
    (StudentId, SemesterId, GPA, Conduct, RankId, EvaluatedBy, EvaluatedAt)
VALUES
    (s.StudentId, s.SemesterId, s.GPA, s.Conduct, s.RankId, @EnteredBy, SYSUTCDATETIME());

IF @SemHk2 IS NOT NULL
BEGIN
    MERGE dbo.StudentSemesterSummaries AS t
    USING (VALUES
        (@Student01, @SemHk2, CAST(8.30 AS decimal(5,2)), N'Tốt', @RankGioi),
        (@Student02, @SemHk2, CAST(7.00 AS decimal(5,2)), N'Khá',  @RankKha)
    ) AS s (StudentId, SemesterId, GPA, Conduct, RankId)
    ON t.StudentId = s.StudentId AND t.SemesterId = s.SemesterId
    WHEN MATCHED THEN UPDATE SET
        GPA = s.GPA, Conduct = s.Conduct, RankId = s.RankId,
        EvaluatedBy = @EnteredBy, EvaluatedAt = SYSUTCDATETIME()
    WHEN NOT MATCHED THEN INSERT
        (StudentId, SemesterId, GPA, Conduct, RankId, EvaluatedBy, EvaluatedAt)
    VALUES
        (s.StudentId, s.SemesterId, s.GPA, s.Conduct, s.RankId, @EnteredBy, SYSUTCDATETIME());
END;

MERGE dbo.StudentYearlySummaries AS t
USING (VALUES
    (@Student01, @YearId, CAST(8.40 AS decimal(5,2)), N'Tốt', @RankGioi),
    (@Student02, @YearId, CAST(7.10 AS decimal(5,2)), N'Khá',  @RankKha)
) AS s (StudentId, AcademicYearId, YearlyGPA, YearlyConduct, RankId)
ON t.StudentId = s.StudentId AND t.AcademicYearId = s.AcademicYearId
WHEN MATCHED THEN UPDATE SET
    YearlyGPA = s.YearlyGPA, YearlyConduct = s.YearlyConduct, RankId = s.RankId,
    EvaluatedBy = @EnteredBy, EvaluatedAt = SYSUTCDATETIME()
WHEN NOT MATCHED THEN INSERT
    (StudentId, AcademicYearId, YearlyGPA, YearlyConduct, RankId, EvaluatedBy, EvaluatedAt)
VALUES
    (s.StudentId, s.AcademicYearId, s.YearlyGPA, s.YearlyConduct, s.RankId, @EnteredBy, SYSUTCDATETIME());

COMMIT TRANSACTION;

-- Verify
SELECT N'YearActive' AS Info, @YearId AS YearId, @SemHk1 AS Hk1, @SemHk2 AS Hk2, @ClassId AS ClassId;

SELECT u.Username, sub.SubjectName, a.AssessmentName, g.Score
FROM dbo.Grades g
JOIN dbo.Users u ON u.UserId = g.StudentId
JOIN dbo.Assessments a ON a.AssessmentId = g.AssessmentId
JOIN dbo.TeachingAssignments ta ON ta.TeachingAssignmentId = a.TeachingAssignmentId
JOIN dbo.Subjects sub ON sub.SubjectId = ta.SubjectId
WHERE u.Username IN (N'student01', N'student02')
ORDER BY u.Username, sub.SubjectName, a.AssessmentId;

SELECT u.Username, s.SemesterId, s.GPA, s.Conduct
FROM dbo.StudentSemesterSummaries s
JOIN dbo.Users u ON u.UserId = s.StudentId
WHERE u.Username IN (N'student01', N'student02');

SELECT N'OK — wipe Grades/Assessments + seed điểm & summary. Timetables không bị xóa.' AS Message;
GO

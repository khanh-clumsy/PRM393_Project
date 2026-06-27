namespace PRM393API.DTOs;

public record StudentClassDto(int StudentClassId, int StudentId, int ClassId);

public record StudentClassResponseDto(int StudentClassId, int StudentId, int ClassId, string? StudentName, string? StudentCode);

public record CreateStudentClassDto(int StudentId, int ClassId);

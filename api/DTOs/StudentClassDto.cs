namespace PRM393API.DTOs;

public record StudentClassDto(int StudentClassId, int StudentId, int ClassId);

public record CreateStudentClassDto(int StudentId, int ClassId);

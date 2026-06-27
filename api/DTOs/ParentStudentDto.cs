namespace PRM393API.DTOs;

public record ParentStudentDto(
    int ParentStudentId, 
    int ParentId, 
    int StudentId, 
    string Relationship, 
    string? StudentName = null, 
    string? ParentName = null,
    string? StudentCode = null,
    string? ParentCode = null);

public record CreateParentStudentDto(int ParentId, int StudentId, string Relationship);

public record UpdateParentStudentDto(string? Relationship);

using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PRM393API.Migrations
{
    /// <inheritdoc />
    public partial class UpdateTimetableAndAttendanceSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Att_Date",
                table: "AttendanceRecords");

            migrationBuilder.DropIndex(
                name: "UQ_AttendanceRecords",
                table: "AttendanceRecords");

            migrationBuilder.DropColumn(
                name: "EffectiveTo",
                table: "Timetables");

            migrationBuilder.DropColumn(
                name: "AttendanceDate",
                table: "AttendanceRecords");

            migrationBuilder.RenameColumn(
                name: "EffectiveFrom",
                table: "Timetables",
                newName: "Date");

            migrationBuilder.RenameColumn(
                name: "DayOfWeek",
                table: "Timetables",
                newName: "Status");

            migrationBuilder.AddColumn<string>(
                name: "Note",
                table: "Timetables",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "UQ_AttendanceRecords",
                table: "AttendanceRecords",
                columns: new[] { "TimetableId", "StudentId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "UQ_AttendanceRecords",
                table: "AttendanceRecords");

            migrationBuilder.DropColumn(
                name: "Note",
                table: "Timetables");

            migrationBuilder.RenameColumn(
                name: "Status",
                table: "Timetables",
                newName: "DayOfWeek");

            migrationBuilder.RenameColumn(
                name: "Date",
                table: "Timetables",
                newName: "EffectiveFrom");

            migrationBuilder.AddColumn<DateOnly>(
                name: "EffectiveTo",
                table: "Timetables",
                type: "date",
                nullable: true);

            migrationBuilder.AddColumn<DateOnly>(
                name: "AttendanceDate",
                table: "AttendanceRecords",
                type: "date",
                nullable: false,
                defaultValue: new DateOnly(1, 1, 1));

            migrationBuilder.CreateIndex(
                name: "IX_Att_Date",
                table: "AttendanceRecords",
                column: "AttendanceDate");

            migrationBuilder.CreateIndex(
                name: "UQ_AttendanceRecords",
                table: "AttendanceRecords",
                columns: new[] { "TimetableId", "StudentId", "AttendanceDate" },
                unique: true);
        }
    }
}

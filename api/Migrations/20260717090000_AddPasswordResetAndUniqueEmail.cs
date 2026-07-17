using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PRM393API.Migrations
{
    /// <inheritdoc />
    public partial class AddPasswordResetAndUniqueEmail : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PasswordResetCode",
                table: "Users",
                type: "nvarchar(6)",
                maxLength: 6,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PasswordResetCodeExpiresAt",
                table: "Users",
                type: "datetime2",
                nullable: true);

            migrationBuilder.Sql(
                "UPDATE Users SET Email = LOWER(LTRIM(RTRIM(Email))) WHERE Email IS NOT NULL;");

            migrationBuilder.Sql(
                "UPDATE Users SET Email = CONCAT('missing+', UserId, '@invalid.local') " +
                "WHERE Email IS NULL OR Email = '';");

            migrationBuilder.Sql(
                "WITH dup AS (SELECT UserId, ROW_NUMBER() OVER " +
                "(PARTITION BY Email ORDER BY UserId) AS rn FROM Users) " +
                "UPDATE u SET u.Email = CONCAT('missing+', u.UserId, '@invalid.local') " +
                "FROM Users u JOIN dup ON u.UserId = dup.UserId WHERE dup.rn > 1;");

            migrationBuilder.AlterColumn<string>(
                name: "Email",
                table: "Users",
                type: "nvarchar(150)",
                maxLength: 150,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(150)",
                oldMaxLength: 150,
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "UQ_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "UQ_Users_Email",
                table: "Users");

            migrationBuilder.AlterColumn<string>(
                name: "Email",
                table: "Users",
                type: "nvarchar(150)",
                maxLength: 150,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(150)",
                oldMaxLength: 150);

            migrationBuilder.DropColumn(
                name: "PasswordResetCode",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "PasswordResetCodeExpiresAt",
                table: "Users");
        }
    }
}

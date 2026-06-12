using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PRM393API.Migrations
{
    /// <inheritdoc />
    public partial class AddPhoneNumberUniqueIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "UQ_Users_PhoneNumber",
                table: "Users",
                column: "PhoneNumber",
                unique: true,
                filter: "[PhoneNumber] IS NOT NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "UQ_Users_PhoneNumber",
                table: "Users");
        }
    }
}

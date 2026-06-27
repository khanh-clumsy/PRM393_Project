using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PRM393API.Migrations
{
    /// <inheritdoc />
    public partial class AddTimetableTemplatesTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "TimetableTemplates",
                columns: table => new
                {
                    TemplateId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TeachingAssignmentId = table.Column<int>(type: "int", nullable: false),
                    DayOfWeek = table.Column<byte>(type: "tinyint", nullable: false),
                    SlotId = table.Column<int>(type: "int", nullable: false),
                    RoomName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TimetableTemplates", x => x.TemplateId);
                    table.ForeignKey(
                        name: "FK_Templates_Slots",
                        column: x => x.SlotId,
                        principalTable: "TimetableSlots",
                        principalColumn: "SlotId");
                    table.ForeignKey(
                        name: "FK_Templates_TA",
                        column: x => x.TeachingAssignmentId,
                        principalTable: "TeachingAssignments",
                        principalColumn: "TeachingAssignmentId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_TimetableTemplates_SlotId",
                table: "TimetableTemplates",
                column: "SlotId");

            migrationBuilder.CreateIndex(
                name: "IX_TimetableTemplates_TeachingAssignmentId",
                table: "TimetableTemplates",
                column: "TeachingAssignmentId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TimetableTemplates");
        }
    }
}

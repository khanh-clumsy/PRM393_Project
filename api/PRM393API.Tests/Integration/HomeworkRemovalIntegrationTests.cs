using PRM393API.Controllers;

namespace PRM393API.Tests.Integration;

public class HomeworkRemovalIntegrationTests
{
    [Fact]
    public void ApiSurface_DoesNotExposeHomeworkControllers()
    {
        var controllerTypes = typeof(GradeController).Assembly.GetTypes()
            .Where(t => t.Namespace == "PRM393API.Controllers")
            .Select(t => t.Name)
            .ToArray();

        Assert.DoesNotContain("AssignmentController", controllerTypes);
        Assert.DoesNotContain("SubmissionController", controllerTypes);
    }
}

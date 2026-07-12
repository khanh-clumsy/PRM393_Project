using Microsoft.EntityFrameworkCore;
using PRM393API.Models;

namespace PRM393API.Tests.Helpers;

internal static class DbContextTestHelper
{
    internal static Prm393dbContext CreateInMemoryContext(string dbName)
    {
        var options = new DbContextOptionsBuilder<Prm393dbContext>()
            .UseInMemoryDatabase(dbName)
            .Options;
        return new Prm393dbContext(options);
    }
}

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PRM393API.Models;

[Index("Token", Name = "IX_RefreshTokens_Token")]
[Index("UserId", Name = "IX_RefreshTokens_UserId")]
public partial class RefreshToken
{
    [Key]
    public int TokenId { get; set; }

    public int UserId { get; set; }

    [StringLength(512)]
    public string Token { get; set; } = null!;

    public DateTime ExpiresAt { get; set; }

    public bool IsRevoked { get; set; }

    public DateTime CreatedAt { get; set; }

    [ForeignKey("UserId")]
    [InverseProperty("RefreshTokens")]
    public virtual User User { get; set; } = null!;
}

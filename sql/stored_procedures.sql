USE ASEAuthDb;
GO


IF OBJECT_ID('dbo.sp_RegisterUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RegisterUser;
GO
CREATE PROCEDURE dbo.sp_RegisterUser
  @FullName NVARCHAR(200),
  @Email NVARCHAR(200),
  @PasswordHash NVARCHAR(MAX),
  @PhoneNumber NVARCHAR(50) = NULL,
  @DateOfBirth DATE = NULL,
  @Role NVARCHAR(50) = 'User'
AS
BEGIN
  SET NOCOUNT ON;

  IF EXISTS(SELECT 1 FROM dbo.Users WHERE Email = @Email)
  BEGIN
    ;THROW 50001, 'Email already exists.', 1;
  END

  INSERT INTO dbo.Users (FullName, Email, PasswordHash, PhoneNumber, DateOfBirth, Role)
  VALUES (@FullName, @Email, @PasswordHash, @PhoneNumber, @DateOfBirth, @Role);

  DECLARE @NewId INT = SCOPE_IDENTITY();
  SELECT @NewId AS NewUserId;
END
GO


IF OBJECT_ID('dbo.sp_LoginUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_LoginUser;
GO
CREATE PROCEDURE dbo.sp_LoginUser
  @Email NVARCHAR(200)
AS
BEGIN
  SET NOCOUNT ON;

  SELECT TOP 1 Id, FullName, Email, PasswordHash, PhoneNumber, DateOfBirth, Role, IsActive, CreatedAt, UpdatedAt
  FROM dbo.Users
  WHERE Email = @Email AND IsActive = 1;
END
GO


IF OBJECT_ID('dbo.sp_GetUserById', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetUserById;
GO
CREATE PROCEDURE dbo.sp_GetUserById
  @Id INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT TOP 1 Id, FullName, Email, PhoneNumber, DateOfBirth, Role, IsActive, CreatedAt, UpdatedAt
  FROM dbo.Users
  WHERE Id = @Id;
END
GO


IF OBJECT_ID('dbo.sp_UpdateUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateUser;
GO
CREATE PROCEDURE dbo.sp_UpdateUser
  @Id INT,
  @PhoneNumber NVARCHAR(50) = NULL,
  @DateOfBirth DATE = NULL,
  @Role NVARCHAR(50) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE dbo.Users
    SET PhoneNumber = COALESCE(@PhoneNumber, PhoneNumber),
        DateOfBirth = COALESCE(@DateOfBirth, DateOfBirth),
        Role = COALESCE(@Role, Role),
        UpdatedAt = GETDATE()
  WHERE Id = @Id AND IsActive = 1;

  SELECT @@ROWCOUNT AS RowsAffected;
END
GO


IF OBJECT_ID('dbo.sp_DeleteUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_DeleteUser;
GO
CREATE PROCEDURE dbo.sp_DeleteUser
  @Id INT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE dbo.Users
    SET IsActive = 0,
        UpdatedAt = GETDATE()
  WHERE Id = @Id;

  SELECT @@ROWCOUNT AS RowsAffected;
END
GO


IF OBJECT_ID('dbo.sp_ResetPassword', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ResetPassword;
GO
CREATE PROCEDURE dbo.sp_ResetPassword
  @Email NVARCHAR(200),
  @NewPasswordHash NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE dbo.Users
    SET PasswordHash = @NewPasswordHash,
        UpdatedAt = GETDATE()
  WHERE Email = @Email AND IsActive = 1;

  SELECT @@ROWCOUNT AS RowsAffected;
END
GO


IF OBJECT_ID('dbo.sp_InsertAuditLog', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_InsertAuditLog;
GO
CREATE PROCEDURE dbo.sp_InsertAuditLog
  @UserId INT = NULL,
  @Action NVARCHAR(100),
  @Details NVARCHAR(1000) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO dbo.AuditLogs (UserId, Action, Details)
  VALUES (@UserId, @Action, @Details);

  SELECT SCOPE_IDENTITY() AS AuditId;
END
GO

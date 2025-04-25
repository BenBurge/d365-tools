USE [AxDB];
GO

UPDATE userinfo
SET enable = 1
WHERE name <> 'guest';
GO
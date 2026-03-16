USE hr;
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Lando Norris', 'lando.norris@mclaren.com', '(234) 567-8901');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Oscar Piastri', 'oscar.piastri@mclaren.com', '(345) 678-9012');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Charles Leclerc', 'charles.leclerc@ferrari.com', '(456) 789-0123');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Lewis Hamilton', 'lewis.hamilton@ferrari.com', '(567) 890-1234');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Max Verstappen', 'max.verstappen@redbullracing.com', '(678) 901-2345');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Yuki Tsunoda', 'yuki.tsunoda@redbullracing.com', '(789) 012-3456');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('George Russell', 'george.russell@mercedesamgf1.com', '(890) 123-4567');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Kimi Antonelli', 'kimi.antonelli@mercedesamgf1.com', '(901) 234-5678');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Fernando Alonso', 'fernando.alonso@astonmartinf1.com', '(212) 345-6789');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Lance Stroll', 'lance.stroll@astonmartinf1.com', '(312) 456-7890');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Pierre Gasly', 'pierre.gasly@alpinef1.com', '(412) 567-8901');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Franco Colapinto', 'franco.colapinto@alpinef1.com', '(512) 678-9012');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Oliver Bearman', 'oliver.bearman@haasf1team.com', '(612) 789-0123');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Esteban Ocon', 'esteban.ocon@haasf1team.com', '(713) 890-1234');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Liam Lawson', 'liam.lawson@visacashapprb.com', '(813) 901-2345');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Isack Hadjar', 'isack.hadjar@visacashapprb.com', '(913) 012-3456');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Alex Albon', 'alex.albon@williamsf1.com', '(214) 123-4567');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Carlos Sainz', 'carlos.sainz@williamsf1.com', '(314) 234-5678');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Nico Hulkenberg', 'nico.hulkenberg@sauber-group.com', '(414) 345-6789');
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Gabriel Bortoleto', 'gabriel.bortoleto@sauber-group.com', '(514) 456-7890');
GO

-- Find emails whose local-part contains a dot followed by a token
-- that begins with "al" and continues with lowercase letters only
-- for at least 3 more characters, at a .com domain.
-- (Matches alonso and albon but would exclude short tokens like "al9"
-- or "al__" — a variable-length, letters-only rule LIKE can't express.)
SELECT [Name], Email
FROM dbo.EMPLOYEES
WHERE REGEXP_LIKE(LOWER(Email), '^[^@]*\.al[a-z]{3,}@[a-z0-9.-]+\.com$');
GO
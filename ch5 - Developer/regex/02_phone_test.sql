USE hr;
GO

-- =============================================
-- 2025 Formula 1 Grid
-- =============================================

-- McLaren
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Lando Norris', 'lando.norris@mclaren.com', '(441) 555-0101');
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Oscar Piastri', 'oscar.piastri@mclaren.com', '(613) 555-0102');
GO

-- Ferrari
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Charles Leclerc', 'charles.leclerc@ferrari.com', '(377) 555-0103');
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Lewis Hamilton', 'lewis.hamilton@ferrari.com', '(441) 555-0104');
GO

-- Red Bull Racing
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Max Verstappen', 'max.verstappen@redbull.com', '(310) 555-0105');
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Yuki Tsunoda', 'yuki.tsunoda@redbull.com', '(813) 555-0106');
GO

-- Mercedes
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('George Russell', 'george.russell@mercedes.com', '(441) 555-0107');
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Kimi Antonelli', 'kimi.antonelli@mercedes.com', '(390) 555-0108');
GO

-- Aston Martin
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Fernando Alonso', 'fernando.alonso@astonmartin.com', '(349) 555-0109');
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Lance Stroll', 'lance.stroll@astonmartin.com', '(514) 555-0110');
GO

-- Alpine
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Pierre Gasly', 'pierre.gasly@alpine.com', '(331) 555-0111');
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Franco Colapinto', 'franco.colapinto@alpine.com', '(541) 555-0112');
GO

-- Haas
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Oliver Bearman', 'oliver.bearman@haas.com', '(441) 555-0113');
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Esteban Ocon', 'esteban.ocon@haas.com', '(331) 555-0114');
GO

-- Racing Bulls
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Liam Lawson', 'liam.lawson@racingbulls.com', '(640) 555-0115');
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Isack Hadjar', 'isack.hadjar@racingbulls.com', '(331) 555-0116');
GO

-- Williams
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Alex Albon', 'alex.albon@williams.com', '(441) 555-0117');
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Carlos Sainz', 'carlos.sainz@williams.com', '(349) 555-0118');
GO

-- Kick Sauber
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Nico Hulkenberg', 'nico.hulkenberg@sauber.com', '(490) 555-0119');
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Gabriel Bortoleto', 'gabriel.bortoleto@sauber.com', '(551) 555-0120');
GO

-- =============================================
-- Invalid INSERTs (to test phone validation)
-- =============================================
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Max Verstappen', 'max.verstappen@redbull.com', '+31 6 555.1212');
GO
INSERT INTO EMPLOYEES ([Name], Email, PhoneNumber)
VALUES ('Lewis Hamilton', 'lewis.hamilton@ferrari.com', '44-7700-900123');
GO
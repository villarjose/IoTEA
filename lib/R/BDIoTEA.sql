CREATE USER 'root'@'%' IDENTIFIED BY 'Papatolati666';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'Papatolati666' WITH GRANT OPTION;

CREATE USER 'essy'@'%';
CREATE USER 'essy'@'localhost';
CREATE USER 'essy'@'127.0.0.1';
update user set Password=PASSWORD('Papatolati666') where User='essy';
CREATE DATABASE ESSYDB;
GRANT ALL PRIVILEGES ON ESSYDB.* TO 'essy'@'%';
GRANT ALL PRIVILEGES ON ESSYDB.* TO 'essy'@'localhost';
GRANT ALL PRIVILEGES ON ESSYDB.* TO 'essy'@'127.0.0.1';

DROP TABLE ESSYDB.data_processed CASCADE;
DROP TABLE ESSYDB.classifier CASCADE;
DROP TABLE ESSYDB.data CASCADE;
DROP TABLE ESSYDB.method CASCADE;
DROP TABLE ESSYDB.activity_distances CASCADE; 
DROP TABLE ESSYDB.sliding_window CASCADE;
DROP TABLE ESSYDB.activity CASCADE;
DROP TABLE ESSYDB.participant CASCADE;
DROP TABLE ESSYDB.profile CASCADE;


CREATE TABLE ESSYDB.profile (
  `idprofile` TINYINT NOT NULL,
  `label` VarChar(50) NOT NULL,
  PRIMARY KEY (`idprofile`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO ESSYDB.profile VALUES
(0, 'Not considered -all the profiles are included-'),
(1, 'Healthy'),
(2, 'Walking stick, crutch or crutches, etc'),
(3, 'Cognitive impairment');

CREATE TABLE ESSYDB.activity (
  `idactivity` VarChar(11) NOT NULL,
  `label` VarChar(50) NOT NULL,
  `isa` VarChar(11),
  PRIMARY KEY (`idactivity`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO ESSYDB.activity VALUES
('1.0.0', 'Resting', NULL),
('1.1.0', 'Lying', '1.0.0'),
('1.1.1', 'Sleeping', '1.1.0'),
('1.1.2', 'Resting', '1.1.0'),
('1.2.0', 'Sitting', '1.0.0'),
('1.2.1', 'Sleeping', '1.3.0'),
('1.3.2', 'Resting', '1.3.0'),
('2.0.0', 'Transition', NULL),
('2.1.0', 'Getting up', '2.0.0'),
('2.1.1', 'Uprise from a bed', '2.1.0'),
('2.1.2', 'Uprise from a chair', '2.1.0'),
('2.2.0', 'Lying down', '2.0.0'),
('2.2.1', 'Lying down on a bed', '2.2.0'),
('2.2.2', 'Sitting down on a chair', '2.2.0'),
('3.0.0', 'Walk', NULL),
('3.1.0', 'Without assistance', '3.0.0'),
('3.1.1', 'Walk', '3.1.0'),
('3.1.2', 'Stairs up', '3.1.0'),
('3.1.3', 'Going down a ramp', '3.1.0'),
('3.2.0', 'With the assistance of a rail', '3.0.0'),
('3.2.1', 'Walk', '3.1.0'),
('3.2.2', 'Stairs up', '3.1.0'),
('3.2.3', 'Going down a ramp', '3.1.0');


CREATE TABLE ESSYDB.participant (
 `idparticipant` TINYINT NOT NULL,
 `idprofile` TINYINT NOT NULL,
 `label` VARCHAR(50),
 FOREIGN KEY (`idprofile`) REFERENCES ESSYDB.profile(`idprofile`),
 PRIMARY KEY (`idparticipant`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE ESSYDB.activity_distances (
  `idact1` VarChar(11) NOT NULL,
  `idact2` VarChar(11) NOT NULL,
  `idprofile` TINYINT DEFAULT NULL,
  `idparticipant` TINYINT DEFAULT NULL,
  `q25` REAL,
  `q50` REAL,
  `q75` REAL,
  FOREIGN KEY (`idact1`) REFERENCES ESSYDB.activity(`idactivity`), 
  FOREIGN KEY (`idact2`) REFERENCES ESSYDB.activity(`idactivity`),
  FOREIGN KEY (`idprofile`) REFERENCES ESSYDB.profile(`idprofile`),
  FOREIGN KEY (`idparticipant`) REFERENCES ESSYDB.participant(`idparticipant`),
  PRIMARY KEY (`idact1`, `idact2`, `idprofile`, `idparticipant`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE ESSYDB.sliding_window (
  `idact1` VarChar(11) NOT NULL,
  `idprofile` TINYINT NOT NULL,
  `idparticipant` TINYINT,
  `windowsize` TINYINT,
  `shift` TINYINT,
  FOREIGN KEY (`idact1`) REFERENCES ESSYDB.activity(`idactivity`), 
  FOREIGN KEY (`idprofile`) REFERENCES ESSYDB.profile(`idprofile`),
  FOREIGN KEY (`idparticipant`) REFERENCES ESSYDB.participant(`idparticipant`),
  PRIMARY KEY (`idact1`, `idprofile`,`idparticipant`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE ESSYDB.data (
  `idparticipant` TINYINT NOT NULL,
  `time` BIGINT NOT NULL,
  `idactivity` VarChar(11),
  `hr` TINYINT,
  `oxigen` TINYINT,
  `accx` SMALLINT,
  `accy` SMALLINT,
  `accz` SMALLINT,
  FOREIGN KEY (`idactivity`) REFERENCES ESSYDB.activity(`idactivity`), 
  FOREIGN KEY (`idparticipant`) REFERENCES ESSYDB.participant(`idparticipant`),
  PRIMARY KEY (`idparticipant`, `Time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE ESSYDB.method ( 
  `idmethod` TINYINT NOT NULL,  
  `description` VarChar(100) NOT NULL,
  PRIMARY KEY (`idmethod`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE ESSYDB.classifier ( 
  `idclassifier` TINYINT NOT NULL,  
  `idmethod` TINYINT NOT NULL,
  `idactivity` VarChar(11) NOT NULL,
  `idparticipant` TINYINT NOT NULL,
  `idprofile` TINYINT NOT NULL,
  `output` FLOAT,
  FOREIGN KEY (`idmethod`) REFERENCES ESSYDB.method(`idmethod`),
  FOREIGN KEY (`idactivity`) REFERENCES ESSYDB.activity(`idactivity`),
  FOREIGN KEY (`idparticipant`) REFERENCES ESSYDB.participant(`idparticipant`),
  FOREIGN KEY (`idprofile`) REFERENCES ESSYDB.profile(`idprofile`),  
  FOREIGN KEY (`idprofile`) REFERENCES ESSYDB.profile(`idprofile`),  
  PRIMARY KEY (`idclassifier`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE ESSYDB.data_processed ( 
  `time` BIGINT NOT NULL,
  `idclassifier` TINYINT NOT NULL,
  `sma` FLOAT,
  `aom` FLOAT,
  `tbp` FLOAT,
  `hrmean` FLOAT,
  `hrinc` FLOAT,
  `aux` FLOAT,
  `idparticipant` TINYINT NOT NULL,
  `idprofile` TINYINT NOT NULL,
  `output` FLOAT NOT NULL,
  FOREIGN KEY (`idclassifier`) REFERENCES ESSYDB.classifier(`idclassifier`), 
  FOREIGN KEY (`idprofile`) REFERENCES ESSYDB.profile(`idprofile`),
  FOREIGN KEY (`idparticipant`) REFERENCES ESSYDB.participant(`idparticipant`),
  PRIMARY KEY (`time`, `idparticipant`, `idclassifier`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;







FLUSH PRIVILEGES;
#CREATE USER 'root'@'%' IDENTIFIED BY 'Papatolati666';
#GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'Papatolati666' WITH GRANT OPTION;
#
#CREATE USER 'essy'@'%';
#CREATE USER 'essy'@'localhost';
#CREATE USER 'essy'@'127.0.0.1';
#update user set Password=PASSWORD('Papatolati666') where User='essy';
#CREATE DATABASE ESSYDB;
#GRANT ALL PRIVILEGES ON ESSYDB.* TO 'essy'@'%';
#GRANT ALL PRIVILEGES ON ESSYDB.* TO 'essy'@'localhost';
#GRANT ALL PRIVILEGES ON ESSYDB.* TO 'essy'@'127.0.0.1';


DROP TABLE IF EXISTS ESSYDB.calibration_activitytemplate CASCADE;
DROP TABLE IF EXISTS ESSYDB.calibration_experiment CASCADE;
DROP TABLE IF EXISTS ESSYDB.data_processed CASCADE;
DROP TABLE IF EXISTS ESSYDB.classifier CASCADE;
DROP TABLE IF EXISTS ESSYDB.data CASCADE;
DROP TABLE IF EXISTS ESSYDB.method CASCADE;
DROP TABLE IF EXISTS ESSYDB.activity_distances CASCADE; 
DROP TABLE IF EXISTS ESSYDB.sliding_window CASCADE;
DROP TABLE IF EXISTS ESSYDB.activity CASCADE;
DROP TABLE IF EXISTS ESSYDB.participant CASCADE;
DROP TABLE IF EXISTS ESSYDB.profile CASCADE;


CREATE TABLE ESSYDB.profile (
  `idprofile` TINYINT UNSIGNED NOT NULL,
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
('0.0.0', 'Zero Activity', NULL),
('1.0.0', 'Resting', NULL),
   ('1.1.0', 'Lying', '1.0.0'),
      ('1.1.1', 'Lying Sleeping', '1.1.0'),
      ('1.1.2', 'Lying Resting', '1.1.0'),
   ('1.2.0', 'Sitting', '1.0.0'),
      ('1.2.1', 'Sitting Sleeping', '1.2.0'),
      ('1.2.2', 'Sitting Resting', '1.2.0'),
('2.0.0', 'Transition', NULL),
   ('2.1.0', 'Getting up', '2.0.0'),
      ('2.1.1', 'Uprise from a bed', '2.1.0'),
      ('2.1.2', 'Uprise from a chair', '2.1.0'),
   ('2.2.0', 'Lying down', '2.0.0'),
      ('2.2.1', 'Lying down on a bed', '2.2.0'),
      ('2.2.2', 'Sitting down on a chair', '2.2.0'),
('3.0.0', 'Walking', NULL),
   ('3.1.0', 'Without assistance', '3.0.0'),
      ('3.1.1', 'Walking independently', '3.1.0'),
      ('3.1.2', 'Stairs up independently', '3.1.0'),
     ('3.1.3', 'Going down a ramp independently', '3.1.0'),
   ('3.2.0', 'With the assistance of a rail', '3.0.0'),
      ('3.2.1', 'Walking with assistance', '3.1.0'),
      ('3.2.2', 'Stairs up with assistance', '3.1.0'),
      ('3.2.3', 'Going down a ramp with assistance', '3.1.0');


CREATE TABLE ESSYDB.participant (
 `idparticipant` TINYINT UNSIGNED NOT NULL,
 `idprofile` TINYINT UNSIGNED NOT NULL,
 `label` VARCHAR(50),
 FOREIGN KEY (`idprofile`) REFERENCES ESSYDB.profile(`idprofile`),
 PRIMARY KEY (`idparticipant`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO ESSYDB.participant VALUES 
(1, 1, 'Participant 01'),
(2, 1, 'Participant 02'),
(3, 2, 'Participant 03'),
(14, 3, 'Participant 14'),
(5, 3, 'Participant 05'),
(6, 2, 'Participant 06'),
(7, 1, 'Participant 07'),
(9, 3, 'Participant 09'),
(10, 2, 'Participant 10'),
(11, 1, 'Participant 08');

CREATE TABLE ESSYDB.activity_distances (
  `idact1` VarChar(11) NOT NULL,
  `idact2` VarChar(11) NOT NULL,
  `idprofile` TINYINT UNSIGNED DEFAULT NULL,
  `idparticipant` TINYINT UNSIGNED DEFAULT NULL,
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
  `idprofile` TINYINT UNSIGNED NOT NULL,
  `idparticipant` TINYINT UNSIGNED,
  `windowsize` TINYINT UNSIGNED,
  `shift` TINYINT UNSIGNED,
  FOREIGN KEY (`idact1`) REFERENCES ESSYDB.activity(`idactivity`), 
  FOREIGN KEY (`idprofile`) REFERENCES ESSYDB.profile(`idprofile`),
  PRIMARY KEY (`idact1`, `idprofile`,`idparticipant`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


INSERT INTO ESSYDB.sliding_window VALUES 
('0.0.0',1,NULL, 32,16),
('0.0.0',2,NULL, 32,16),
('0.0.0',3,NULL, 32,16);

CREATE TABLE ESSYDB.data (
  `idparticipant` TINYINT UNSIGNED NOT NULL,
  `time` BIGINT NOT NULL,
  `idactivity` VarChar(11),
  `hr` TINYINT UNSIGNED,
  `oxigen` TINYINT UNSIGNED,
  `accx` SMALLINT,
  `accy` SMALLINT,
  `accz` SMALLINT,
  FOREIGN KEY (`idactivity`) REFERENCES ESSYDB.activity(`idactivity`), 
  FOREIGN KEY (`idparticipant`) REFERENCES ESSYDB.participant(`idparticipant`),
  PRIMARY KEY (`idparticipant`, `time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE ESSYDB.method ( 
  `idmethod` TINYINT UNSIGNED NOT NULL,  
  `description` VarChar(100) NOT NULL,
  PRIMARY KEY (`idmethod`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE ESSYDB.classifier ( 
  `idclassifier` TINYINT UNSIGNED NOT NULL,  
  `idmethod` TINYINT UNSIGNED NOT NULL,
  `idactivity` VarChar(11) NOT NULL,
  `idparticipant` TINYINT UNSIGNED NOT NULL,
  `idprofile` TINYINT UNSIGNED NOT NULL,
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
  `idclassifier` TINYINT UNSIGNED NOT NULL,
  `sma` FLOAT,
  `aom` FLOAT,
  `tbp` FLOAT,
  `hrmean` FLOAT,
  `hrinc` FLOAT,
  `aux` FLOAT,
  `idparticipant` TINYINT UNSIGNED NOT NULL,
  `idprofile` TINYINT UNSIGNED NOT NULL,
  `output` FLOAT NOT NULL,
  FOREIGN KEY (`idclassifier`) REFERENCES ESSYDB.classifier(`idclassifier`), 
  FOREIGN KEY (`idparticipant`) REFERENCES ESSYDB.participant(`idparticipant`),
  FOREIGN KEY (`idprofile`) REFERENCES ESSYDB.profile(`idprofile`),
  PRIMARY KEY (`time`, `idparticipant`, `idclassifier`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Toma de tiempos en los experimentos que deben seguir las actividades en el orden marcado
-- por la tabla calibration_activitytemplate
--
CREATE TABLE ESSYDB.calibration_experiment ( 
  `lap` TINYINT UNSIGNED NOT NULL,
  `idparticipant` TINYINT UNSIGNED NOT NULL,  
  `idactivity` VarChar(11) NOT NULL,  
  `time` BIGINT NOT NULL,
  `pause` BOOLEAN NOT NULL,
  FOREIGN KEY (`idactivity`) REFERENCES ESSYDB.activity(`idactivity`),
  FOREIGN KEY (`idparticipant`) REFERENCES ESSYDB.participant(`idparticipant`),
  PRIMARY KEY (`idparticipant`,`lap`, `time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Plantilla de actividades que se deben seguir de forma ordenada
--

CREATE TABLE ESSYDB.calibration_activitytemplate (
  `idorder` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `idactivity` VarChar(11) NOT NULL,  
  `action` VarChar(100) NOT NULL,
  FOREIGN KEY (`idactivity`) REFERENCES ESSYDB.activity(`idactivity`),
  PRIMARY KEY (`idorder`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE ESSYDB.calibration_activitytemplate AUTO_INCREMENT = 1;

INSERT INTO ESSYDB.calibration_activitytemplate VALUES
(NULL,'1.1.0', 'Inicio de la Prueba con el paciente echado en la camilla'), 
(NULL,'2.1.1', 'Tras 3 minutos, marcar levantarse'),
(NULL,'3.1.1', 'Participante incorporado, inicia camino de ida y vuelta a silla'),
(NULL,'2.2.1', 'Participante llega a camilla, inicio proceso de acostarse'),
(NULL,'1.1.0', 'Participante acostado'),
(NULL,'2.1.1', 'Tras 3 minutos, marcar levantarse'),
(NULL,'3.1.1', 'Participante incorporado, inicia camino a silla'),
(NULL,'2.2.2', 'Participante llega a silla, inicia proceso de sentarse'),
(NULL,'1.2.2', 'Participante sentado'),
(NULL,'2.1.2', 'Tras 1 minuto, marcar levantarse'),
(NULL,'3.1.1', 'Participante incorporado, inicia camino a escalera'),
(NULL,'3.1.2', 'Participante llega a escalera, inicia proceso de subida'),
(NULL,'3.1.1', 'Participante llega al final de la escalera'),
(NULL,'3.2.3', 'Participante llega a rampa, inicia la bajada'),
(NULL,'3.1.1', 'Participante alcanza final de rampa'),
(NULL,'3.1.2', 'Participante llega a escalera, inicia proceso de subida'),
(NULL,'3.1.1', 'Participante llega al final de la escalera'),
(NULL,'3.2.3', 'Participante llega a rampa, inicia la bajada'),
(NULL,'3.1.1', 'Participante alcanza final de rampa'),
(NULL,'3.1.2', 'Participante llega a escalera, inicia proceso de subida'),
(NULL,'3.1.1', 'Participante llega al final de la escalera'),
(NULL,'3.2.3', 'Participante llega a rampa, inicia la bajada'),
(NULL,'3.1.1', 'Participante alcanza final de rampa'),
(NULL,'2.2.2', 'Participante llega a silla, inicia proceso de sentarse'),
(NULL,'1.2.2', 'Participante sentado'),
(NULL,'2.1.2', 'Tras 1 minuto, marcar levantarse'),
(NULL,'3.1.1', 'Participante incorporado, inicia camino a camilla'),
(NULL,'2.2.1', 'Participante llega a camilla, inicio proceso de acostarse'),
(NULL,'1.1.2', 'Participante acostado (Tras 1 minuto, desactivar captacion de datos'),
(NULL,'0.0.0', 'Desconectar todos los aparatos');
      
      
      


FLUSH PRIVILEGES;
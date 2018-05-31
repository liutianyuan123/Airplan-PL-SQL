-- -----------------------------------------------------------------------------
--             Génération d'une base de données pour
--                      Oracle Version 10g
--                        (8/1/2018 15:32:52)
-- -----------------------------------------------------------------------------
--      Nom de la base : BestGroup
--      Projet : Semaine bloque
--      Auteur : Tianyuan LIU, Yan ZHAO
--      Date de dernière modification : 8/1/2018 15:32:38
-- -----------------------------------------------------------------------------

DROP TABLE COUPON_VOL CASCADE CONSTRAINTS;
DROP TABLE RECETTE CASCADE CONSTRAINTS;
DROP TABLE CONTAINER_REEL CASCADE CONSTRAINTS;
DROP TABLE AEROPORT CASCADE CONSTRAINTS;
DROP TABLE VOL CASCADE CONSTRAINTS;
DROP TABLE BILLET CASCADE CONSTRAINTS;
DROP TABLE TRAJET CASCADE CONSTRAINTS;
DROP TABLE OCCURRENCE_VOL CASCADE CONSTRAINTS;
DROP TABLE CONTAINER_VIRTUEL CASCADE CONSTRAINTS;
DROP TABLE BAGAGE CASCADE CONSTRAINTS;
DROP TABLE PROVISION CASCADE CONSTRAINTS;
DROP TABLE CLIENT CASCADE CONSTRAINTS;
DROP TABLE DECHARGER CASCADE CONSTRAINTS;
DROP TABLE CONSTITUER CASCADE CONSTRAINTS;
DROP TABLE CHARGER CASCADE CONSTRAINTS;
DROP TABLE AFFECTER CASCADE CONSTRAINTS;

-- -----------------------------------------------------------------------------
--       CREATION DE LA BASE 
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--       TABLE : COUPON_VOL
-- -----------------------------------------------------------------------------

CREATE TABLE COUPON_VOL
   (
    COUPNUM NUMBER  NOT NULL,
    OCCNUM NUMBER  NOT NULL,
    BILLNUM NUMBER  NOT NULL,
    COUPETAT VARCHAR2(50)  NOT NULL
,   CONSTRAINT PK_COUPON_VOL PRIMARY KEY (COUPNUM),
Constraint check_coupetat
	check (COUPETAT in ('enregistré','annulé','réservé','arrivée'))
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE COUPON_VOL
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_COUPON_VOL_OCCURRENCE_VOL
     ON COUPON_VOL (OCCNUM ASC)
    ;

CREATE  INDEX I_FK_COUPON_VOL_BILLET
     ON COUPON_VOL (BILLNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : RECETTE
-- -----------------------------------------------------------------------------

CREATE TABLE RECETTE
   (
    RECOPNUM NUMBER  NOT NULL,
    BILLNUM NUMBER  NOT NULL,
    RECOPMONTANT NUMBER  NOT NULL,
    RECOPDATE DATE  NOT NULL
,   CONSTRAINT PK_RECETTE PRIMARY KEY (RECOPNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE RECETTE
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_RECETTE_BILLET
     ON RECETTE (BILLNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : AEROPORT
-- -----------------------------------------------------------------------------

CREATE TABLE AEROPORT
   (
    AERONUM NUMBER  NOT NULL,
    AERONOM VARCHAR2(50)  NOT NULL,
    AEROTAXE NUMBER  NOT NULL,
    AEROPOIDSMAXCONTAINER NUMBER  NOT NULL
,   CONSTRAINT PK_AEROPORT PRIMARY KEY (AERONUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : VOL
-- -----------------------------------------------------------------------------

CREATE TABLE VOL
   (
    VOLNUM NUMBER  NOT NULL,
    AERONUM_ARRIVEE NUMBER  NOT NULL,
    AERONUM_DEPART NUMBER  NOT NULL,
    H_DEPART DATE  NOT NULL,
    H_ARRIVEE DATE  NOT NULL,
    VOLNBPLACES NUMBER  NOT NULL
,   CONSTRAINT PK_VOL PRIMARY KEY (VOLNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE VOL
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_VOL_AEROPORT
     ON VOL (AERONUM_ARRIVEE ASC)
    ;

CREATE  INDEX I_FK_VOL_AEROPORT1
     ON VOL (AERONUM_DEPART ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : BILLET
-- -----------------------------------------------------------------------------

CREATE TABLE BILLET
   (
    BILLNUM NUMBER  NOT NULL,
    TRANUM NUMBER  NOT NULL,
    CLINUM NUMBER  NOT NULL,
    BILLDATEACHAT DATE  NOT NULL,
    BILLDATEDEPART DATE  NOT NULL,
    BILLETAT VARCHAR2(50)  NOT NULL
,   CONSTRAINT PK_BILLET PRIMARY KEY (BILLNUM)
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE BILLET
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_BILLET_TRAJET
     ON BILLET (TRANUM ASC)
    ;

CREATE  INDEX I_FK_BILLET_CLIENT
     ON BILLET (CLINUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : TRAJET
-- -----------------------------------------------------------------------------

CREATE TABLE TRAJET
   (
    TRANUM NUMBER  NOT NULL,
    AERONUM_DEPART NUMBER  NOT NULL,
    AERONUM_ARRIVEE NUMBER  NOT NULL,
    TRATARIFBILLET NUMBER(*,2)  NOT NULL,
    TRANKGBAG NUMBER  NOT NULL,
    TRATARIFKGSUP NUMBER  NOT NULL
,   CONSTRAINT PK_TRAJET PRIMARY KEY (TRANUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE TRAJET
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_TRAJET_AEROPORT
     ON TRAJET (AERONUM_DEPART ASC)
    ;

CREATE  INDEX I_FK_TRAJET_AEROPORT1
     ON TRAJET (AERONUM_ARRIVEE ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : OCCURRENCE_VOL
-- -----------------------------------------------------------------------------

CREATE TABLE OCCURRENCE_VOL
   (
    OCCNUM NUMBER  NOT NULL,
    VOLNUM NUMBER  NOT NULL,
    AERONUM NUMBER  NULL,
    OCCDATE DATE NOT NULL,
    OCCETAT VARCHAR2(50) NULL
,   CONSTRAINT PK_OCCURRENCE_VOL PRIMARY KEY (OCCNUM),
Constraint check_onnetat
	CHECK (OCCETAT in ('ouverte à la réservation', 'ouverte à l''embarquement','
   ouverte à la liste d''attente', 'décollée', 'annulée', 'retardée', 
   'déroutée', 'arrivée'))
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE OCCURRENCE_VOL
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_OCCURRENCE_VOL_VOL
     ON OCCURRENCE_VOL (VOLNUM ASC)
    ;

CREATE  INDEX I_FK_OCCURRENCE_VOL_AEROPORT
     ON OCCURRENCE_VOL (AERONUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CONTAINER_VIRTUEL
-- -----------------------------------------------------------------------------

CREATE TABLE CONTAINER_VIRTUEL
   (
    CONTNUM NUMBER  NOT NULL,
    OCCNUM_DESTINER NUMBER  NULL,
    OCCNUM_PROVENIR NUMBER  NULL,
    CONTETAT VARCHAR2(50)  NULL,
	CONTREEL NUMBER NULL
,   CONSTRAINT PK_CONTAINER PRIMARY KEY (CONTNUM),
Constraint check_CONTETAT
	CHECK (CONTETAT in (null,'en cours de chargement','chargé','en cours de déchargement','déchargé')) 
   ) ;
-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CONTAINER_VIRTUEL
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CONTAINER_OCCURRENCE_VOL
     ON CONTAINER_VIRTUEL (CONTREEL ASC)
    ;
CREATE  INDEX I_FK_CONTAINER_CONTREEL
     ON CONTAINER_VIRTUEL (OCCNUM_DESTINER ASC)
    ;
	
CREATE  INDEX I_FK_CONTAINER_OCCURRENCE_VOL1
     ON CONTAINER_VIRTUEL (OCCNUM_PROVENIR ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CONTAINER_REEL
-- -----------------------------------------------------------------------------
CREATE TABLE CONTAINER_REEL
(
	CONTNUM NUMBER NOT NULL,
	AERONUM NUMBER NOT NULL,
	DISPONIBLE varchar2(20) NOT NULL,
	CONSTRAINT PK_CONTAINER_REEL PRIMARY KEY (CONTNUM),
	Constraint check_DISPONIBLE
	CHECK (DISPONIBLE in ('oui','non'))
);
-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CONTAINER_REEL
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CONTREEL_OCCURRENCE_VOL
     ON CONTAINER_REEL (AERONUM ASC)
    ;
	
	
-- -----------------------------------------------------------------------------
--       TABLE : BAGAGE
-- -----------------------------------------------------------------------------

CREATE TABLE BAGAGE
   (
    BAGNUM NUMBER  NOT NULL,
    BILLNUM NUMBER  NOT NULL,
    BAGKG NUMBER  NOT NULL
,   CONSTRAINT PK_BAGAGE PRIMARY KEY (BAGNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE BAGAGE
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_BAGAGE_BILLET
     ON BAGAGE (BILLNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : PROVISION
-- -----------------------------------------------------------------------------

CREATE TABLE PROVISION
   (
    PROVOPNUM NUMBER  NOT NULL,
    BILLNUM NUMBER  NOT NULL,
    PROVOPTYPE VARCHAR2(50)  NOT NULL,
    PROVMONTANT NUMBER  NOT NULL,
    PROVOPDATE DATE  NOT NULL
,   CONSTRAINT PK_PROVISION PRIMARY KEY (PROVOPNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE PROVISION
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_PROVISION_BILLET
     ON PROVISION (BILLNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CLIENT
-- -----------------------------------------------------------------------------

CREATE TABLE CLIENT
   (
    CLINUM NUMBER  NOT NULL,
    CLINOM VARCHAR2(50)  NOT NULL,
    CLITEL VARCHAR2(50)  NULL,
    CLIADRESSE VARCHAR2(50)  NULL
,   CONSTRAINT PK_CLIENT PRIMARY KEY (CLINUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : DECHARGER
-- -----------------------------------------------------------------------------

CREATE TABLE DECHARGER
   (
    BAGNUM NUMBER  NOT NULL,
    CONTNUM NUMBER  NOT NULL,
    DATE_H_DCH DATE  NULL
,   CONSTRAINT PK_DECHARGER PRIMARY KEY (BAGNUM, CONTNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE DECHARGER
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_DECHARGER_BAGAGE
     ON DECHARGER (BAGNUM ASC)
    ;

CREATE  INDEX I_FK_DECHARGER_CONTAINER
     ON DECHARGER (CONTNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CONSTITUER
-- -----------------------------------------------------------------------------

CREATE TABLE CONSTITUER
   (
    TRANUM NUMBER  NOT NULL,
    VOLNUM NUMBER  NOT NULL,
    NUMORDRE NUMBER  NOT NULL,
    JOURPLUS NUMBER  NOT NULL
,   CONSTRAINT PK_CONSTITUER PRIMARY KEY (TRANUM, VOLNUM, NUMORDRE, JOURPLUS)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CONSTITUER
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CONSTITUER_TRAJET
     ON CONSTITUER (TRANUM ASC)
    ;

CREATE  INDEX I_FK_CONSTITUER_VOL
     ON CONSTITUER (VOLNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CHARGER
-- -----------------------------------------------------------------------------

CREATE TABLE CHARGER
   (
    BAGNUM NUMBER  NOT NULL,
    CONTNUM NUMBER  NOT NULL,
    DATE_H_CH DATE  NULL
,   CONSTRAINT PK_CHARGER PRIMARY KEY (BAGNUM, CONTNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CHARGER
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CHARGER_BAGAGE
     ON CHARGER (BAGNUM ASC)
    ;

CREATE  INDEX I_FK_CHARGER_CONTAINER
     ON CHARGER (CONTNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : AFFECTER
-- -----------------------------------------------------------------------------

CREATE TABLE AFFECTER
   (
    BAGNUM NUMBER  NOT NULL,
    CONTNUM NUMBER  NOT NULL,
    DATE_H_AFF DATE  NULL
,   CONSTRAINT PK_AFFECTER PRIMARY KEY (BAGNUM, CONTNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE AFFECTER
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_AFFECTER_BAGAGE
     ON AFFECTER (BAGNUM ASC)
    ;

CREATE  INDEX I_FK_AFFECTER_CONTAINER
     ON AFFECTER (CONTNUM ASC)
    ;


-- -----------------------------------------------------------------------------
--       CREATION DES REFERENCES DE TABLE
-- -----------------------------------------------------------------------------


ALTER TABLE CONTAINER_VIRTUEL ADD (
     CONSTRAINT FK_CONT_REEL_VIRTUEL
          FOREIGN KEY (CONTREEL)
               REFERENCES CONTAINER_REEL (CONTNUM))   ;


ALTER TABLE CONTAINER_REEL ADD (
     CONSTRAINT FK_CONTAINER_REEL_AERO
          FOREIGN KEY (AERONUM)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE COUPON_VOL ADD (
     CONSTRAINT FK_COUPON_VOL_OCCURRENCE_VOL
          FOREIGN KEY (OCCNUM)
               REFERENCES OCCURRENCE_VOL (OCCNUM))   ;

ALTER TABLE COUPON_VOL ADD (
     CONSTRAINT FK_COUPON_VOL_BILLET
          FOREIGN KEY (BILLNUM)
               REFERENCES BILLET (BILLNUM))   ;

ALTER TABLE RECETTE ADD (
     CONSTRAINT FK_RECETTE_BILLET
          FOREIGN KEY (BILLNUM)
               REFERENCES BILLET (BILLNUM))   ;

ALTER TABLE VOL ADD (
     CONSTRAINT FK_VOL_AEROPORT
          FOREIGN KEY (AERONUM_ARRIVEE)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE VOL ADD (
     CONSTRAINT FK_VOL_AEROPORT1
          FOREIGN KEY (AERONUM_DEPART)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE BILLET ADD (
     CONSTRAINT FK_BILLET_TRAJET
          FOREIGN KEY (TRANUM)
               REFERENCES TRAJET (TRANUM))   ;

ALTER TABLE BILLET ADD (
     CONSTRAINT FK_BILLET_CLIENT
          FOREIGN KEY (CLINUM)
               REFERENCES CLIENT (CLINUM))   ;

ALTER TABLE TRAJET ADD (
     CONSTRAINT FK_TRAJET_AEROPORT
          FOREIGN KEY (AERONUM_DEPART)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE TRAJET ADD (
     CONSTRAINT FK_TRAJET_AEROPORT1
          FOREIGN KEY (AERONUM_ARRIVEE)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE OCCURRENCE_VOL ADD (
     CONSTRAINT FK_OCCURRENCE_VOL_VOL
          FOREIGN KEY (VOLNUM)
               REFERENCES VOL (VOLNUM))   ;

ALTER TABLE OCCURRENCE_VOL ADD (
     CONSTRAINT FK_OCCURRENCE_VOL_AEROPORT
          FOREIGN KEY (AERONUM)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE CONTAINER_VIRTUEL ADD (
     CONSTRAINT FK_CONTAINER_OCCURRENCE_VOL
          FOREIGN KEY (OCCNUM_DESTINER)
               REFERENCES OCCURRENCE_VOL (OCCNUM))   ;

ALTER TABLE CONTAINER_VIRTUEL ADD (
     CONSTRAINT FK_CONTAINER_OCCURRENCE_VOL1
          FOREIGN KEY (OCCNUM_PROVENIR)
               REFERENCES OCCURRENCE_VOL (OCCNUM))   ;

ALTER TABLE BAGAGE ADD (
     CONSTRAINT FK_BAGAGE_BILLET
          FOREIGN KEY (BILLNUM)
               REFERENCES BILLET (BILLNUM))   ;

ALTER TABLE PROVISION ADD (
     CONSTRAINT FK_PROVISION_BILLET
          FOREIGN KEY (BILLNUM)
               REFERENCES BILLET (BILLNUM))   ;

ALTER TABLE DECHARGER ADD (
     CONSTRAINT FK_DECHARGER_BAGAGE
          FOREIGN KEY (BAGNUM)
               REFERENCES BAGAGE (BAGNUM))   ;

ALTER TABLE DECHARGER ADD (
     CONSTRAINT FK_DECHARGER_CONTAINER
          FOREIGN KEY (CONTNUM)
               REFERENCES CONTAINER_VIRTUEL (CONTNUM))   ;

ALTER TABLE CONSTITUER ADD (
     CONSTRAINT FK_CONSTITUER_TRAJET
          FOREIGN KEY (TRANUM)
               REFERENCES TRAJET (TRANUM))   ;

ALTER TABLE CONSTITUER ADD (
     CONSTRAINT FK_CONSTITUER_VOL
          FOREIGN KEY (VOLNUM)
               REFERENCES VOL (VOLNUM))   ;

ALTER TABLE CHARGER ADD (
     CONSTRAINT FK_CHARGER_BAGAGE
          FOREIGN KEY (BAGNUM)
               REFERENCES BAGAGE (BAGNUM))   ;

ALTER TABLE CHARGER ADD (
     CONSTRAINT FK_CHARGER_CONTAINER
          FOREIGN KEY (CONTNUM)
               REFERENCES CONTAINER_VIRTUEL (CONTNUM))   ;

ALTER TABLE AFFECTER ADD (
     CONSTRAINT FK_AFFECTER_BAGAGE
          FOREIGN KEY (BAGNUM)
               REFERENCES BAGAGE (BAGNUM))   ;

ALTER TABLE AFFECTER ADD (
     CONSTRAINT FK_AFFECTER_CONTAINER
          FOREIGN KEY (CONTNUM)
               REFERENCES CONTAINER_VIRTUEL (CONTNUM))   ;


-- -----------------------------------------------------------------------------
--                FIN DE GENERATION
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--       PREPARATION DES DONNEES
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--       AEROPORT
-- -----------------------------------------------------------------------------
Insert into AEROPORT (AERONUM,AERONOM,AEROTAXE,AEROPOIDSMAXCONTAINER) values (33001,'Paris-Charles De Gaulle',11,1000);
Insert into AEROPORT (AERONUM,AERONOM,AEROTAXE,AEROPOIDSMAXCONTAINER) values (33002,'Toulouse-Blagnac',7,800);
Insert into AEROPORT (AERONUM,AERONOM,AEROTAXE,AEROPOIDSMAXCONTAINER) values (33003,'Bordeaux-Mérignac',6,800);
Insert into AEROPORT (AERONUM,AERONOM,AEROTAXE,AEROPOIDSMAXCONTAINER) values (86002,'Urumqi',8,950);
Insert into AEROPORT (AERONUM,AERONOM,AEROTAXE,AEROPOIDSMAXCONTAINER) values (86001,'Pékin',10,1000);
Insert into AEROPORT (AERONUM,AERONOM,AEROTAXE,AEROPOIDSMAXCONTAINER) values (10001,'San Francisco',9,900);
Insert into AEROPORT (AERONUM,AERONOM,AEROTAXE,AEROPOIDSMAXCONTAINER) values (43001,'Berlin',9,900);
-- -----------------------------------------------------------------------------
--       TRAJET
-- -----------------------------------------------------------------------------
Insert into TRAJET values (100001,33001,33003,260,20,10);
Insert into TRAJET values (100002,33003,33001,286.37,20,10);
Insert into TRAJET values (100003,33002,33001,270.31,20,10);
Insert into TRAJET values (100004,33002,33001,260.98,20,10);
Insert into TRAJET values (100005,33001,33002,261.57,20,10);
Insert into TRAJET values (100006,33001,86001,298.37,43,8);
Insert into TRAJET values (100007,33001,86001,309.98,43,8);
Insert into TRAJET values (100008,86001,33001,360.61,43,8);
Insert into TRAJET values (100009,86001,33001,336.05,43,8);
Insert into TRAJET values (100010,86001,10001,735,40,9);
Insert into TRAJET values (100011,86001,86002,99.37,23,10);
Insert into TRAJET values (100012,86001,86002,103.27,23,10);
Insert into TRAJET values (100013,86001,86002,100.35,23,10);
Insert into TRAJET values (100014,86002,86001,102.45,23,10);
Insert into TRAJET values (100015,86002,86001,120.3,23,10);
Insert into TRAJET values (100016,33002,86002,868.87,43,10);
Insert into TRAJET values (100017,33002,86002,1118.4,43,8);
Insert into TRAJET values (100018,86002,33002,1816.65,43,9);
Insert into TRAJET values (100020,33003,86002,857.66,40,9);
Insert into TRAJET values (100022,33002,86001,627.58,40,9);
Insert into TRAJET values (100023,33002,86001,603.55,40,9);
Insert into TRAJET values (100024,86001,33002,678,40,9);
Insert into TRAJET values (100026,33001,86002,650.37,46,8);
Insert into TRAJET values (100027,33001,86002,648.29,46,8);
Insert into TRAJET values (100028,86002,33001,900,46,8);
Insert into TRAJET values (100029,86002,33001,800,46,8);

-- -----------------------------------------------------------------------------
--       CLIENT
-- -----------------------------------------------------------------------------
Insert into CLIENT  values (1,'absolon',null,null);
Insert into CLIENT  values (2,'adélaïde',null,null);
Insert into CLIENT  values (3,'adèle',null,null);
Insert into CLIENT  values (4,'adolphe',null,null);
Insert into CLIENT  values (5,'adrien',null,null);
Insert into CLIENT  values (6,'adrienne',null,null);
Insert into CLIENT  values (7,'agnès',null,null);
Insert into CLIENT  values (8,'aimé',null,null);
Insert into CLIENT  values (9,'aimée',null,null);
Insert into CLIENT  values (10,'alain',null,null);


-- -----------------------------------------------------------------------------
--       VOL
-- -----------------------------------------------------------------------------
Insert into VOL values (7622,33003,33001,to_date('09:55:00','HH24:MI:SS'),to_date('11:10:00','HH24:MI:SS'),150);
Insert into VOL values (7629,33001,33003,to_date('14:40:00','HH24:MI:SS'),to_date('17:05:00','HH24:MI:SS'),150);
Insert into VOL values (7523,33001,33002,to_date('12:20:00','HH24:MI:SS'),to_date('13:50:00','HH24:MI:SS'),200);
Insert into VOL values (4952,33001,33002,to_date('07:15:00','HH24:MI:SS'),to_date('08:50:00','HH24:MI:SS'),200);
Insert into VOL values (7190,33002,33001,to_date('08:15:00','HH24:MI:SS'),to_date('09:40:00','HH24:MI:SS'),250);
Insert into VOL values (9340,86001,33001,to_date('19:30:00','HH24:MI:SS'),to_date('12:35:00','HH24:MI:SS'),200);
Insert into VOL values (554,86001,33001,to_date('12:25:00','HH24:MI:SS'),to_date('07:00:00','HH24:MI:SS'),200);
Insert into VOL values (7777,33001,86001,to_date('00:20:00','HH24:MI:SS'),to_date('06:40:00','HH24:MI:SS'),3);
Insert into VOL values (3450,33001,86001,to_date('00:05:00','HH24:MI:SS'),to_date('05:30:00','HH24:MI:SS'),150);
Insert into VOL values (1329,10001,86001,to_date('17:25:00','HH24:MI:SS'),to_date('13:05:00','HH24:MI:SS'),170);
Insert into VOL values (7345,86002,86001,to_date('21:45:00','HH24:MI:SS'),to_date('01:40:00','HH24:MI:SS'),140);
Insert into VOL values (1291,86002,86001,to_date('14:55:00','HH24:MI:SS'),to_date('19:10:00','HH24:MI:SS'),150);
Insert into VOL values (5699,86002,86001,to_date('09:15:00','HH24:MI:SS'),to_date('14:55:00','HH24:MI:SS'),150);
Insert into VOL values (6885,86001,86002,to_date('14:45:00','HH24:MI:SS'),to_date('19:50:00','HH24:MI:SS'),200);
Insert into VOL values (5700,86001,86002,to_date('16:20:00','HH24:MI:SS'),to_date('21:00:00','HH24:MI:SS'),150);
Insert into VOL values (5800,33001,86002,to_date('16:20:00','HH24:MI:SS'),to_date('21:00:00','HH24:MI:SS'),3);
-- -----------------------------------------------------------------------------
--       CONSTITUER
-- -----------------------------------------------------------------------------
Insert into CONSTITUER values (100001,7622,1,0);
Insert into CONSTITUER values (100002,7629,1,0);
Insert into CONSTITUER values (100003,7523,1,0);
Insert into CONSTITUER values (100004,4952,1,0);
Insert into CONSTITUER values (100005,7190,1,0);
Insert into CONSTITUER values (100006,9340,1,0);
Insert into CONSTITUER values (100007,554,1,0);
Insert into CONSTITUER values (100008,7777,1,0);
Insert into CONSTITUER values (100009,3450,1,0);
Insert into CONSTITUER values (100010,1329,1,0);
Insert into CONSTITUER values (100011,7345,1,1);
Insert into CONSTITUER values (100012,1291,1,0);
Insert into CONSTITUER values (100013,5699,1,0);
Insert into CONSTITUER values (100014,6885,1,0);
Insert into CONSTITUER values (100015,5700,1,0);
Insert into CONSTITUER values (100016,1291,3,1);
Insert into CONSTITUER values (100016,7523,1,0);
Insert into CONSTITUER values (100016,9340,2,1);
Insert into CONSTITUER values (100017,554,2,1);
Insert into CONSTITUER values (100017,4952,1,0);
Insert into CONSTITUER values (100017,5699,3,1);
Insert into CONSTITUER values (100018,6885,1,0);
Insert into CONSTITUER values (100018,7190,3,1);
Insert into CONSTITUER values (100018,7777,2,1);
Insert into CONSTITUER values (100020,1291,3,1);
Insert into CONSTITUER values (100020,7629,1,0);
Insert into CONSTITUER values (100020,9340,2,1);
Insert into CONSTITUER values (100022,7523,1,0);
Insert into CONSTITUER values (100022,9340,2,1);
Insert into CONSTITUER values (100023,554,2,1);
Insert into CONSTITUER values (100023,4952,1,0);
Insert into CONSTITUER values (100024,7190,2,0);
Insert into CONSTITUER values (100024,7777,1,0);
Insert into CONSTITUER values (100026,1291,2,1);
Insert into CONSTITUER values (100026,9340,1,1);
Insert into CONSTITUER values (100027,554,1,1);
Insert into CONSTITUER values (100027,5699,2,1);
Insert into CONSTITUER values (100028,3450,2,1);
Insert into CONSTITUER values (100028,5700,1,0);
Insert into CONSTITUER values (100029,5800,1,0);
-- -----------------------------------------------------------------------------
--       OCCURRENCE_VOL
-- -----------------------------------------------------------------------------
Insert into OCCURRENCE_VOL values (580004,5800,33001,sysdate+3,'ouverte à la réservation');
Insert into OCCURRENCE_VOL values (580003,5800,33001,sysdate+2,'ouverte à la réservation');
Insert into OCCURRENCE_VOL values (580002,5800,33001,sysdate+1,'ouverte à la réservation');
Insert into OCCURRENCE_VOL values (762901,7629,33002,sysdate,null);
Insert into OCCURRENCE_VOL values (752301,7523,33003,sysdate,null);
Insert into OCCURRENCE_VOL values (495201,4952,33003,sysdate,null);
Insert into OCCURRENCE_VOL values (719001,7190,33003,sysdate,null);
Insert into OCCURRENCE_VOL values (934001,9340,86002,sysdate,null);
Insert into OCCURRENCE_VOL values (55401,554,86002,sysdate,null);
Insert into OCCURRENCE_VOL values (777701,7777,86002,sysdate,'ouverte à la réservation');
Insert into OCCURRENCE_VOL values (345001,3450,86002,sysdate,null);
Insert into OCCURRENCE_VOL values (132901,1329,86002,sysdate,null);
Insert into OCCURRENCE_VOL values (734501,7345,33001,sysdate,null);
Insert into OCCURRENCE_VOL values (129101,1291,33001,sysdate,null);
Insert into OCCURRENCE_VOL values (569901,5699,33001,sysdate,null);
Insert into OCCURRENCE_VOL values (688501,6885,33001,sysdate,'ouverte à la réservation');
Insert into OCCURRENCE_VOL values (570001,5700,33001,sysdate,null);
Insert into OCCURRENCE_VOL values (762202,7622,33002,sysdate+1,null);
Insert into OCCURRENCE_VOL values (762902,7629,33002,sysdate+1,null);
Insert into OCCURRENCE_VOL values (752302,7523,33003,sysdate+1,null);
Insert into OCCURRENCE_VOL values (495202,4952,33003,sysdate+1,null);
Insert into OCCURRENCE_VOL values (719002,7190,33003,sysdate+1,'ouverte à la réservation');
Insert into OCCURRENCE_VOL values (934002,9340,86002,sysdate+1,null);
Insert into OCCURRENCE_VOL values (55402,554,86002,sysdate+1,null);
Insert into OCCURRENCE_VOL values (777702,7777,86002,sysdate+1,'ouverte à la réservation');
Insert into OCCURRENCE_VOL values (345002,3450,86002,sysdate+1,null);
Insert into OCCURRENCE_VOL values (132902,1329,86002,sysdate+1,null);
Insert into OCCURRENCE_VOL values (734502,7345,33001,sysdate+1,null);
Insert into OCCURRENCE_VOL values (129102,1291,33001,sysdate+1,null);
Insert into OCCURRENCE_VOL values (569902,5699,33001,sysdate+1,null);
Insert into OCCURRENCE_VOL values (688502,6885,33001,sysdate+1,null);
Insert into OCCURRENCE_VOL values (570002,5700,33001,sysdate+1,null);
Insert into OCCURRENCE_VOL values (762201,7622,33002,sysdate,null);

-- -----------------------------------------------------------------------------
--       	Container_reel
-- -----------------------------------------------------------------------------
Insert into CONTAINER_REEL values(1,86002,'oui');
Insert into CONTAINER_REEL values(2,86002,'oui');
Insert into CONTAINER_REEL values(3,86002,'oui');
Insert into CONTAINER_REEL values(4,86002,'oui');
Insert into CONTAINER_REEL values(5,86002,'oui');
Insert into CONTAINER_REEL values(6,86001,'oui');
Insert into CONTAINER_REEL values(7,86001,'oui');
Insert into CONTAINER_REEL values(8,86001,'oui');
Insert into CONTAINER_REEL values(9,86001,'oui');
Insert into CONTAINER_REEL values(10,86001,'oui');
Insert into CONTAINER_REEL values(11,33001,'oui');
Insert into CONTAINER_REEL values(12,33001,'oui');
Insert into CONTAINER_REEL values(13,33001,'oui');
Insert into CONTAINER_REEL values(14,33002,'oui');
Insert into CONTAINER_REEL values(15,33002,'oui');
Insert into CONTAINER_REEL values(16,33002,'oui');
Insert into CONTAINER_REEL values(17,33002,'oui');
Insert into CONTAINER_REEL values(18,43001,'oui');
Insert into CONTAINER_REEL values(19,43001,'oui');
Insert into CONTAINER_REEL values(20,43001,'oui');
Insert into CONTAINER_REEL values(21,10001,'oui');
Insert into CONTAINER_REEL values(22,10001,'oui');
Insert into CONTAINER_REEL values(23,10001,'oui');
Insert into CONTAINER_REEL values(24,10001,'oui');

-- -----------------------------------------------------------------------------
--       SEQUENCE
-- -----------------------------------------------------------------------------


DROP SEQUENCE SEQ_BAGAGE;
CREATE SEQUENCE SEQ_BAGAGE INCREMENT BY 1 START WITH 0 MAXVALUE 9999999999999999999999999999 MINVALUE 0 CACHE 20;

DROP SEQUENCE SEQ_BILLET;
CREATE SEQUENCE SEQ_BILLET INCREMENT BY 1 START WITH 0 MAXVALUE 9999999999999999999999999999 MINVALUE 0 CACHE 20;

DROP SEQUENCE SEQ_CONTAINER;
CREATE SEQUENCE SEQ_CONTAINER INCREMENT BY 1 START WITH 0 MAXVALUE 9999999999999999999999999999 MINVALUE 0 CACHE 20;

DROP SEQUENCE SEQ_COUPONVOL;
CREATE SEQUENCE SEQ_COUPONVOL INCREMENT BY 1 START WITH 0 MAXVALUE 9999999999999999999999999999 MINVALUE 0 CACHE 20;

DROP SEQUENCE SEQ_PROVISION;
CREATE SEQUENCE SEQ_PROVISION INCREMENT BY 1 START WITH 0 MAXVALUE 9999999999999999999999999999 MINVALUE 0 CACHE 20;

DROP SEQUENCE SEQ_RECETTE;
CREATE SEQUENCE SEQ_RECETTE INCREMENT BY 1 START WITH 0 MAXVALUE 9999999999999999999999999999 MINVALUE 0 CACHE 20;

-- -----------------------------------------------------------------------------
--       Trigger
-- -----------------------------------------------------------------------------

create or replace TRIGGER TRIG_BILLET_FINANCE 
BEFORE UPDATE OF BILLETAT ON BILLET 
REFERENCING OLD AS O NEW AS N 
FOR EACH ROW 
WHEN (N.billetat='terminé')
DECLARE
v_montant number;
BEGIN
  select sum(provmontant) INTO v_montant
  FROM PROVISION
  WHERE BILLNUM=:N.BILLNUM
  AND PROVOPTYPE='crédit';

  insert into PROVISION values(SEQ_PROVISION.nextVal,:N.BILLNUM,'dédit',v_montant,sysdate);
  insert into RECETTE values(SEQ_RECETTE.nextVal,:N.BILLNUM,v_montant,sysdate);

END;
/
create or replace TRIGGER "TRIG_CONT_REEL" BEFORE INSERT ON CONTAINER_VIRTUEL 
REFERENCING OLD AS O NEW AS N 
FOR EACH ROW
BEGIN
  UPDATE CONTAINER_REEL SET DISPONIBLE='non' WHERE CONTNUM=:N.CONTREEL;
END;

/
create or replace TRIGGER TRIG_ENREGISTREMENT 
BEFORE UPDATE OF COUPETAT ON COUPON_VOL 
REFERENCING OLD AS O NEW AS N 
FOR EACH ROW 
WHEN (N.coupETAT='enregistré')
DECLARE
v_ouverte_embarquement VARCHAR2(50);
v_fisrt_occnum number;
BEGIN
IF :O.coupETAT='enregistré' THEN
 RAISE_APPLICATION_ERROR(-20101,'le coupon de vol a déjà été enregistré');
END IF;
 select occetat into v_ouverte_embarquement from OCCURRENCE_VOL where OCCNUM=:N.occnum;
 IF v_ouverte_embarquement <> 'ouverte à l''embarquement' THEN
  RAISE_APPLICATION_ERROR(-20100,'L''occurrence de vol '||:N.occnum||' n''est pas ouvete à l''embarquement');
  end if;
  
  SELECT OCC.OCCNUM into v_fisrt_occnum
FROM CONSTITUER C, OCCURRENCE_VOL OCC, BILLET BIL
WHERE BIL.TRANUM = C.TRANUM
AND C.NUMORDRE = 1
AND C.VOLNUM = OCC.VOLNUM
AND TO_DATE(OCC.OCCDATE,'DD/MM/YYYY') = TO_DATE(BIL.BILLDATEDEPART,'DD/MM/YYYY')
AND BIL.BILLNUM = :N.BILLNUM;

if v_fisrt_occnum=:N.occnum then
update BILLET SET BILLETAT='en cours' where BILLNUM=:N.billnum;
END IF;
END;
/
create or replace TRIGGER TRIG_INSERT_BILLET
AFTER INSERT ON "DBA_PROJET_BESTGROUP"."BILLET" 
REFERENCING OLD AS "O" NEW AS "N" 
FOR EACH ROW 
DECLARE

CURSOR cur_occurences IS
  select O.occnum,OccEtat,VolNbPlaces,count(CV.coupnum) as NbPlaceAchetee
  from constituer C, vol V,OCCURRENCE_VOL O
  left join COUPON_VOL CV
  on O.OCCNUM=CV.OCCNUM
  where :N.TRANUM=C.TRANUM
  and C.VOLNUM=V.VOLNUM
  and O.volnum=V.VOLNUM
  and TO_DATE(O.occdate,'dd/mm/yy')=TO_DATE(:N.billdatedepart+C.JOURPLUS,'dd/mm/yy')
    group by O.occnum,OccEtat,VolNbPlaces;


V_OCCNUM NUMBER;
V_OCCTAT varchar2(50);
V_VOLNBPLACE NUMBER;
V_NBPlaceAchete number;
BEGIN


 
  OPEN cur_occurences;
  FETCH cur_occurences INTO V_OCCNUM,V_OCCTAT,V_VOLNBPLACE,V_NBPlaceAchete;
  IF cur_occurences%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'La trajet '||:N.tranum||' n''ont aucun occurrence de vol pour la date de départ '||:N.billdatedepart);
  END IF;
  
  close cur_occurences;
    for occRecord in cur_occurences loop
    IF occRecord.OccEtat is null THEN
        RAISE_APPLICATION_ERROR(-20001, 'La trajet '||:N.tranum||' n''ont aucun occurrence de vol pour la date de départ '||:N.billdatedepart);
    ELSIF occRecord.OccEtat<>'ouverte à la réservation' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Les occurrences de vol de la trajet '||:N.tranum||' ne sont pas encore ouvertées à la réservation pour la date de départ '||:N.billdatedepart);
    ELSIF occRecord.NbPlaceAchetee=occRecord.VolNbPlaces then
        RAISE_APPLICATION_ERROR(-20003, 'Les occurrences de vol de la trajet '||:N.tranum||' n''ont pas assez de place libre pour la date de départ '||:N.billdatedepart);
    END IF;
   END LOOP;

  for occRecord in cur_occurences loop
      insert into coupon_vol values(SEQ_COUPONVOL.nextVal,occRecord.occnum,:N.billnum,'réservé');
  END LOOP;

  PRO_RG_PROVISION_TICKET(:N.billnum,:N.tranum);
  

END;
/
create or replace TRIGGER TRIG_LIBRE_CON
BEFORE UPDATE OF CONTETAT ON CONTAINER_VIRTUEL 
REFERENCING OLD AS O NEW AS N 
FOR EACH ROW 
WHEN (N.CONTETAT='déchargé') 
BEGIN
    UPDATE CONTAINER_REEL SET DISPONIBLE='oui' WHERE CONTNUM=:N.CONTREEL;
END;

-- -----------------------------------------------------------------------------
--       FIN D'INITIALISATION
-- -----------------------------------------------------------------------------
commit;

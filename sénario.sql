--il y a deux persons qui achetent le trajet 100018 de Urumqi(Chine) à Toulouse-Blagnac(Paris) pour la date de départ aujourd'hui.

------------------------------------------------------
--Context: trajet 100018
--1.AERO:URUMQI-----VOL:6885(NbPlaceMax:200)-----AERO:PEKIN
--2.AERO:PEKIN------VOL:7777(NbPlaceMax:2)------AERO:PARIS
--3.AERO:PARIS------VOL:7190(NbPlaceMax:250)------AERO:TOULOUSE
------------------------------------------------------
set SERVEROUTPUT ON;
EXECUTE PRO_AJOUTER_BILLET(100018,SYSDATE,1);
EXECUTE PRO_AJOUTER_BILLET(100018,SYSDATE,2);
EXECUTE PRO_AJOUTER_BILLET(100018,SYSDATE,3);
--Wrong Test: Le client ne peut pas acheter le même trajet de la même date de départ
EXECUTE PRO_AJOUTER_BILLET(100018,SYSDATE,2);

--Wrong Test:Parce que le nombre de place de vol 777 est 3, donc si la quatrième personne ne peut pas encore acheter ce  trajet
EXECUTE PRO_AJOUTER_BILLET(100018,SYSDATE,4);

--Wrong Test:Le coupon de vol ne peut pas être enregisté avant l'ouvert à la l'embarquement
UPDATE COUPON_VOL SET COUPETAT='enregistré' WHERE COUPNUM=1;

--Passe l'occurrence de vol 6885 dans l'état <ouverte à la l'emparquement>
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(688501,'ouverte à l''embarquement');

--Le client 1 et 2 enregistrent leurs coupons de vol avant de décoller
EXECUTE PRO_ENREGISTER_COUPONVOL(1,688501);
EXECUTE PRO_ENREGISTER_COUPONVOL(2,688501);
EXECUTE PRO_ENREGISTER_COUPONVOL(3,688501);

--Le client 1 et 2 enregistrent leurs bagages, l'aéroport Urimqi va prépare 2 containers (Le max poid de container est de 950)
EXECUTE PRO_AJOUTER_BAGAGGE(1,10);
EXECUTE PRO_AJOUTER_BAGAGGE(2,950);

--Le client 1 continue à ajouter autre un bagages , Ce bagage n'a pas besoin de nouvel container
EXECUTE PRO_AJOUTER_BAGAGGE(1,20);


--Chargeur commence à charger le bagage par bagage
EXECUTE pro_charger(1,1);
EXECUTE pro_charger(2,2);
--Wrong  Test:Si les bagages n'ont pas fini de charger, on ne peut pas commencer à décharger
execute pro_decharger(4,1);
--On fini de charger tous les bagages
EXECUTE pro_charger(3,1);

--Wrong Test:Si le bagage n'est pas correspond le container, il y va afficher une erreur
execute pro_charger(1,5);


--On commence à décharger les bagages
execute pro_decharger(1,1);
execute pro_decharger(2,2);
execute pro_decharger(3,1);

--l'occurrence de vol 688501 décolle
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(688501,'décollée');

--l'occurrence de vol 688501 arrive et l'occurrence de vol 777702 ouverte à l'embarquement
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(688501,'arrivée');
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(777702,'ouverte à l''embarquement');

--Charger et décharger les bagages
execute pro_charger(1,3);
execute pro_charger(2,3);
execute pro_charger(3,3);
execute pro_decharger(1,3);
execute pro_decharger(2,3);
execute pro_decharger(3,3);
--Les clients enregistrent coupons
EXECUTE PRO_ENREGISTER_COUPONVOL(1,777702);
EXECUTE PRO_ENREGISTER_COUPONVOL(2,777702);
EXECUTE PRO_ENREGISTER_COUPONVOL(3,777702);


--l'occurrence de vol 777702 décolle
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(777702,'décollée');
set SERVEROUTPUT ON;
--Oops, on rencontre têmpate, l'occurrence doit dérouter
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(777702,'déroutée');

--L'occurrence de vol 58004 ouverte à l'embarquement
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(580004,'ouverte à l''embarquement');

execute pro_charger(1,5);
execute pro_charger(2,5);
execute pro_charger(3,5);
execute pro_decharger(1,5);
execute pro_decharger(2,5);
execute pro_decharger(3,5);

--Les clients enregistrent coupons
EXECUTE PRO_ENREGISTER_COUPONVOL(1,580004);
EXECUTE PRO_ENREGISTER_COUPONVOL(2,580004);
EXECUTE PRO_ENREGISTER_COUPONVOL(3,580004);

--l'occurrence de vol 580004 décolle
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(580004,'décollée');
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(580004,'arrivée');
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(719002,'ouverte à l''embarquement');

execute pro_charger(1,6);
execute pro_charger(3,6);
execute pro_charger(2,6);
execute pro_decharger(1,6);
execute pro_decharger(2,6);
execute pro_decharger(3,6);

EXECUTE PRO_ENREGISTER_COUPONVOL(1,719002);
EXECUTE PRO_ENREGISTER_COUPONVOL(2,719002);
EXECUTE PRO_ENREGISTER_COUPONVOL(3,719002);


EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(719002,'décollée');
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(719002,'arrivée');
commit;
--il y a deux persons qui achetent le trajet 100018 de Urumqi(Chine) � Toulouse-Blagnac(Paris) pour la date de d�part aujourd'hui.

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
--Wrong Test: Le client ne peut pas acheter le m�me trajet de la m�me date de d�part
EXECUTE PRO_AJOUTER_BILLET(100018,SYSDATE,2);

--Wrong Test:Parce que le nombre de place de vol 777 est 3, donc si la quatri�me personne ne peut pas encore acheter ce  trajet
EXECUTE PRO_AJOUTER_BILLET(100018,SYSDATE,4);

--Wrong Test:Le coupon de vol ne peut pas �tre enregist� avant l'ouvert � la l'embarquement
UPDATE COUPON_VOL SET COUPETAT='enregistr�' WHERE COUPNUM=1;

--Passe l'occurrence de vol 6885 dans l'�tat <ouverte � la l'emparquement>
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(688501,'ouverte � l''embarquement');

--Le client 1 et 2 enregistrent leurs coupons de vol avant de d�coller
EXECUTE PRO_ENREGISTER_COUPONVOL(1,688501);
EXECUTE PRO_ENREGISTER_COUPONVOL(2,688501);
EXECUTE PRO_ENREGISTER_COUPONVOL(3,688501);

--Le client 1 et 2 enregistrent leurs bagages, l'a�roport Urimqi va pr�pare 2 containers (Le max poid de container est de 950)
EXECUTE PRO_AJOUTER_BAGAGGE(1,10);
EXECUTE PRO_AJOUTER_BAGAGGE(2,950);

--Le client 1 continue � ajouter autre un bagages , Ce bagage n'a pas besoin de nouvel container
EXECUTE PRO_AJOUTER_BAGAGGE(1,20);


--Chargeur commence � charger le bagage par bagage
EXECUTE pro_charger(1,1);
EXECUTE pro_charger(2,2);
--Wrong  Test:Si les bagages n'ont pas fini de charger, on ne peut pas commencer � d�charger
execute pro_decharger(4,1);
--On fini de charger tous les bagages
EXECUTE pro_charger(3,1);

--Wrong Test:Si le bagage n'est pas correspond le container, il y va afficher une erreur
execute pro_charger(1,5);


--On commence � d�charger les bagages
execute pro_decharger(1,1);
execute pro_decharger(2,2);
execute pro_decharger(3,1);

--l'occurrence de vol 688501 d�colle
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(688501,'d�coll�e');

--l'occurrence de vol 688501 arrive et l'occurrence de vol 777702 ouverte � l'embarquement
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(688501,'arriv�e');
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(777702,'ouverte � l''embarquement');

--Charger et d�charger les bagages
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


--l'occurrence de vol 777702 d�colle
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(777702,'d�coll�e');
set SERVEROUTPUT ON;
--Oops, on rencontre t�mpate, l'occurrence doit d�router
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(777702,'d�rout�e');

--L'occurrence de vol 58004 ouverte � l'embarquement
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(580004,'ouverte � l''embarquement');

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

--l'occurrence de vol 580004 d�colle
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(580004,'d�coll�e');
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(580004,'arriv�e');
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(719002,'ouverte � l''embarquement');

execute pro_charger(1,6);
execute pro_charger(3,6);
execute pro_charger(2,6);
execute pro_decharger(1,6);
execute pro_decharger(2,6);
execute pro_decharger(3,6);

EXECUTE PRO_ENREGISTER_COUPONVOL(1,719002);
EXECUTE PRO_ENREGISTER_COUPONVOL(2,719002);
EXECUTE PRO_ENREGISTER_COUPONVOL(3,719002);


EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(719002,'d�coll�e');
EXECUTE PRO_CHANGER_OCCURRENCE_ETAT(719002,'arriv�e');
commit;
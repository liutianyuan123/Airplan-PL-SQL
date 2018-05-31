create or replace PROCEDURE PRO_AJOUTER_BAGAGGE (
    P_BILLNUM   IN BAGAGE.BILLNUM%TYPE,
    P_BAGKG     IN BAGAGE.BAGKG%TYPE
) AS
    V_OCCNUM    OCCURRENCE_VOL.OCCNUM%TYPE;
    V_OCCETAT   OCCURRENCE_VOL.OCCETAT%TYPE;
    V_CLINUM    CLIENT.CLINUM%TYPE;
BEGIN
  --TROUVER LA PREMIÈRE OCCURRENCE POUR CE BILLET
    SELECT OCC.OCCNUM, OCC.OCCETAT INTO V_OCCNUM,V_OCCETAT
      FROM CONSTITUER C, OCCURRENCE_VOL OCC, BILLET BIL
      WHERE BIL.TRANUM = C.TRANUM
      AND C.NUMORDRE = 1
      AND C.VOLNUM = OCC.VOLNUM
      AND TO_DATE(OCC.OCCDATE,'DD/MM/YYYY') = TO_DATE(BIL.BILLDATEDEPART,'DD/MM/YYYY')
      AND BIL.BILLNUM = P_BILLNUM;
    --VÉRIFIER L'ÉTAT DE CE OCCURRENCE
    --Si cette occurrence est en état de "ouverte à l'embarquement"
    IF V_OCCETAT = 'ouverte à l''embarquement' THEN
      --Ajouter ce bagae
      INSERT INTO BAGAGE VALUES (SEQ_BAGAGE.NEXTVAL, P_BILLNUM, P_BAGKG);
      --Créditer ce bagage
      PRO_RG_PROVISION_BAGAGE(P_BILLNUM,P_BAGKG);
      --AFFECTER CE BAGAGE
      PRO_RG_AFFECTER(SEQ_BAGAGE.CURRVAL,NULL,V_OCCNUM);
      SELECT CLINUM INTO V_CLINUM
        FROM BILLET
        WHERE BILLNUM = P_BILLNUM;
    DBMS_OUTPUT.PUT_LINE('Le client '||V_CLINUM||' a enregistré un '||P_BAGKG||' kg bagage (N°'||SEQ_BAGAGE.CURRVAL||')');
    ELSE
        RAISE_APPLICATION_ERROR(-20001,'L''occurrence n''est pas ouverte à l''embarquement!');
    END IF;
    --Affichier le résultat d'ajoute

END PRO_AJOUTER_BAGAGGE;
/
create or replace PROCEDURE PRO_AJOUTER_BILLET (
    P_TRAJETNUM    IN TRAJET.TRANUM%TYPE,
    P_DATEDEPART   IN BILLET.BILLDATEDEPART%TYPE,
    P_CLIENTNUM    IN CLIENT.CLINUM%TYPE
) AS
    V_RESULTAT_CLI         NUMBER;
    V_AFFICH_AERODEPART    AEROPORT.AERONOM%TYPE;
    V_AFFICH_AEROARRIVEE   AEROPORT.AERONOM%TYPE;
BEGIN
    --Vérifier si ce client a déjà acheté le même billet pour le même trajet da la même date de départ 
    SELECT COUNT(*) INTO V_RESULTAT_CLI 
        FROM BILLET
        WHERE CLINUM = P_CLIENTNUM
        AND TRANUM = P_TRAJETNUM
        AND To_char(BILLDATEDEPART,'dd/mm/yy') = to_char(P_DATEDEPART,'dd/mm/yy');
    --Si v_resultat_cli>0, il signifie que ce client a déjà acheté ce trajet pour la date de départ 
    IF V_RESULTAT_CLI > 0 THEN
        RAISE_APPLICATION_ERROR(-20000,
            'Le trajet '|| P_TRAJETNUM || ' ont été déjà acheté par client :'|| P_CLIENTNUM|| ' pour la date:'|| P_DATEDEPART);
    END IF;
    --Inserer les donées dans la table billet et ça va déclencher un trigger pour vérifier la disponibilité de ce billet
    INSERT INTO BILLET VALUES (SEQ_BILLET.NEXTVAL, P_TRAJETNUM, P_CLIENTNUM, SYSDATE, P_DATEDEPART, 'émis');
    --AFFICHER LE RÉSULTAT
    SELECT A1.AERONOM,A2.AERONOM INTO V_AFFICH_AERODEPART,V_AFFICH_AEROARRIVEE
        FROM TRAJET T,AEROPORT A1,AEROPORT A2
        WHERE A1.AERONUM = T.AERONUM_DEPART
        AND   A2.AERONUM = T.AERONUM_ARRIVEE
        AND   T.TRANUM = P_TRAJETNUM ;
    DBMS_OUTPUT.PUT_LINE('Client '|| P_CLIENTNUM||' a acheté le billet '|| SEQ_BILLET.CURRVAL||' pour le trajet '
                          || P_TRAJETNUM || ' de '||V_AFFICH_AERODEPART||' à '||V_AFFICH_AEROARRIVEE);
    COMMIT;
END PRO_AJOUTER_BILLET;
/
create or replace PROCEDURE PRO_CHANGER_OCCURRENCE_ETAT 
(
    P_OCCNUM  IN OCCURRENCE_VOL.OCCNUM%TYPE 
,   P_ETAT    IN OCCURRENCE_VOL.OCCETAT%TYPE
) AS 
    V_ETAT_AVANT OCCURRENCE_VOL.OCCETAT%TYPE;
BEGIN
  --On trouve l'état d'occurrence précédent. 
    SELECT OCCETAT  INTO V_ETAT_AVANT FROM OCCURRENCE_VOL WHERE OCCNUM=P_OCCNUM;
  --Executer le processus selon l'état à changer
    CASE P_ETAT
    WHEN 'ouverte à l''embarquement' THEN 
        IF V_ETAT_AVANT<>'ouverte à la réservation' THEN 
            RAISE_APPLICATION_ERROR(-20301,
                'L''état d''occurrence de vol '||P_OCCNUM||' devrait être <ouverte à la réservation>');
        END IF;
    WHEN 'décollée' THEN 
        IF V_ETAT_AVANT='ouverte à l''embarquement' THEN 
            PRO_RG_DECOLLEE(P_OCCNUM);
        ELSE
            RAISE_APPLICATION_ERROR(-20301,
                'L''état d''occurrence de vol '||P_OCCNUM||' devrait être <ouverte à l''embarquement>');
        END IF;
    WHEN 'arrivée' THEN 
        IF V_ETAT_AVANT='décollée' THEN
            PRO_RG_ARRIVE(P_OCCNUM);
        ELSE
            RAISE_APPLICATION_ERROR(-20302,'L''état d''occurrence de vol '||P_OCCNUM||' devrait être <décollée>');
        END IF;
    WHEN 'déroutée' THEN 
        IF V_ETAT_AVANT='décollée' THEN
            PRO_RG_DEROUTEE(P_OCCNUM);
        ELSE
            RAISE_APPLICATION_ERROR(-20302,'L''état d''occurrence de vol '||P_OCCNUM||' devrait être <décollée>');
        END IF;
    ELSE NULL;
    END CASE;
    --Après les processus correspondants fini, on met en jour l'état de l'occurrence de vol et affiche le resultat
    UPDATE OCCURRENCE_VOL SET OCCETAT=P_ETAT WHERE OCCNUM=P_OCCNUM;
    DBMS_OUTPUT.PUT_LINE('L''occurrence de vol '||P_OCCNUM||' est passée dans l''état '||P_ETAT);
    commit;
END PRO_CHANGER_OCCURRENCE_ETAT;
/
create or replace PROCEDURE PRO_CHARGER 
(
    P_BAGNUM    IN BAGAGE.BAGNUM%TYPE 
,   P_CONTNUM   IN CONTAINER_VIRTUEL.CONTNUM%TYPE 
) AS 
    V_AFFECTE   NUMBER;
    V_NBAFFEC   NUMBER;
    V_NBCHAR    NUMBER;
    V_OCC_PROV_ETAT OCCURRENCE_VOL.OCCETAT%TYPE;
    V_OK BOOLEAN := FALSE;
    V_FLAG_PREMIER_OCC OCCURRENCE_VOL.OCCNUM%TYPE;
BEGIN
    --Vérifier si ce bagage est correspondant à le container
    SELECT COUNT(*) INTO V_AFFECTE FROM AFFECTER WHERE BAGNUM = P_BAGNUM AND CONTNUM = P_CONTNUM;
    IF V_AFFECTE = 0 THEN
        --SI CE BAGAGE N'EST PAS AFFECTÉ À CE CONTENEUR -> ARRÊTER LE PROCÉDURE
        RAISE_APPLICATION_ERROR(-20001,
        'Ce bagage n''est pas affecté à ce conteneur!');
    ELSE
    --Ce bagage est bien affecté à ce conteneur
    
    
    --Vérifier si ce container correspond une occurrence provenu
    SELECT CASE
        WHEN OCCNUM_PROVENIR IS NULL THEN -1 ELSE OCCNUM_PROVENIR END AS OCCNUM_PROVENIR
        INTO V_FLAG_PREMIER_OCC
        FROM CONTAINER_VIRTUEL
        WHERE CONTNUM=P_CONTNUM;
    --Si V_FLAG_PREMIER_OCC n'est pas -1, c'est à dire ce container correspond une occurrence provenu
    IF V_FLAG_PREMIER_OCC<>-1 THEN
    --Trouver l'état de l'occurrence de vol provenu pour véfirifier si le container peut être chargé
        SELECT 
            CASE WHEN OCC.OCCETAT IS NULL THEN 'premier' ELSE OCC.OCCETAT END AS OCCETAT
            INTO V_OCC_PROV_ETAT
            FROM OCCURRENCE_VOL OCC, CONTAINER_VIRTUEL C
            WHERE C.OCCNUM_PROVENIR = OCC.OCCNUM
            AND C.CONTNUM = P_CONTNUM;    
            /*Le container peut être chargé quant l'état de l'occurrence de vol provenu est seulment 
            arrivée ou déroutée ou c'est la prémière occurrence de vol dans le trajet*/
            IF V_OCC_PROV_ETAT <> 'arrivée' AND V_OCC_PROV_ETAT<>'déroutée' AND V_OCC_PROV_ETAT<>'premier' THEN
                RAISE_APPLICATION_ERROR(-20003,
                    'vous ne pouvez pas charger des bagages d''une occurrence qui n''est pas encore arrivée!');
            END IF;
    END IF;
        --Charger les bagages
        INSERT INTO CHARGER VALUES(P_BAGNUM, P_CONTNUM, SYSDATE);
        --Si on charge le premier bagage, on pass le container virtuel dans l'état <en cours de chargement>.     
        SELECT COUNT(*) INTO V_NBAFFEC FROM AFFECTER WHERE CONTNUM = P_CONTNUM;
        SELECT COUNT(*) INTO V_NBCHAR FROM CHARGER WHERE CONTNUM = P_CONTNUM;
        IF V_NBCHAR = 1 THEN
            UPDATE CONTAINER_VIRTUEL SET CONTETAT = 'en cours de chargement' WHERE CONTNUM = P_CONTNUM;
        END IF;
        --Si tous les bagaes sont bien chargés, on pass le container virtuel dans l'état <chargé>.
        IF V_NBCHAR = V_NBAFFEC THEN
            UPDATE CONTAINER_VIRTUEL SET CONTETAT = 'chargé' WHERE CONTNUM = P_CONTNUM;
        END IF;
    END IF;
exception
  WHEN DUP_VAL_ON_INDEX THEN
     RAISE_APPLICATION_ERROR(-20004,
                    'Le bagage a déjà été chargé');
END PRO_CHARGER;
/

create or replace PROCEDURE PRO_DECHARGER (
    P_BAGNUM    IN BAGAGE.BAGNUM%TYPE,
    P_CONTNUM   IN CONTAINER_VIRTUEL.CONTNUM%TYPE
) AS
    V_AFFECTE    NUMBER;
    V_NBAFFEC    NUMBER;
    V_NBDECHAR   NUMBER;
    V_ETAT       CONTAINER_VIRTUEL.CONTETAT%TYPE;
    V_CONTREEL   CONTAINER_REEL.CONTNUM%TYPE;
BEGIN
    --Trouver l'état de container virtuel
    SELECT CONTETAT INTO V_ETAT FROM CONTAINER_VIRTUEL WHERE CONTNUM = P_CONTNUM;
    --Un bagage peut seulement être déchargé si l'état de container est <chargé> ou <en cours de déchargement>
    IF V_ETAT = 'chargé' OR V_ETAT = 'en cours de déchargement' THEN
        --Vérifier si ce bagage a été affecté à ce conteneur
        SELECT COUNT(*) INTO V_AFFECTE FROM AFFECTER WHERE BAGNUM = P_BAGNUM AND   CONTNUM = P_CONTNUM;
        IF V_AFFECTE = 0 THEN
            RAISE_APPLICATION_ERROR(-20001,'Ce bagage n''est pas affecté à ce conteneur!');
        ELSE
            --Décharger ce bagage
            INSERT INTO DECHARGER VALUES (P_BAGNUM,P_CONTNUM,SYSDATE);
            --Si on décharge à la première fois un bagage, on passe ce container dans l'état <en cours de déchargement>
            SELECT COUNT(*) INTO V_NBAFFEC FROM AFFECTER WHERE CONTNUM = P_CONTNUM;
            SELECT COUNT(*) INTO V_NBDECHAR FROM DECHARGER WHERE CONTNUM = P_CONTNUM;
            IF V_NBDECHAR = 1 THEN
                UPDATE CONTAINER_VIRTUEL SET CONTETAT = 'en cours de déchargement' 
                    WHERE CONTNUM = P_CONTNUM;
            END IF;
            --Si tous les bagages sont bien déchargés, on pass ce container dans l'état <déchargé>
            IF V_NBDECHAR = V_NBAFFEC THEN
                SELECT CONTREEL INTO V_CONTREEL FROM CONTAINER_VIRTUEL WHERE CONTNUM = P_CONTNUM;
                UPDATE CONTAINER_VIRTUEL SET CONTETAT = 'déchargé' WHERE CONTNUM = P_CONTNUM;
            END IF;
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20001,'Ce conteneur n''est pas encore chargé!');
    END IF;
EXCEPTION
    --Si on ne trouve pas l'état de container, c'est-à-dire Ce conteneur virtuel n'existe pas!
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001,'Ce conteneur virtuel n''existe pas!');
   
  WHEN DUP_VAL_ON_INDEX THEN
     RAISE_APPLICATION_ERROR(-20004,
                    'Le bagage a déjà été déchargé');
END PRO_DECHARGER;

/

create or replace PROCEDURE PRO_DEROUTER_AFFECTER 
(
  P_BAGNUM          IN BAGAGE.BAGNUM%TYPE 
, P_OCCNUM_DESTINER IN OCCURRENCE_VOL.OCCNUM%TYPE  
, P_OCCNUM_DEROUTER IN OCCURRENCE_VOL.OCCNUM%TYPE  
, P_OCCNUM_PROVENIR IN OCCURRENCE_VOL.OCCNUM%TYPE 
) AS 
--Trouver les  containers anciens
CURSOR CUR_CONT IS
    SELECT CONTNUM
    FROM  CONTAINER_VIRTUEL
    WHERE OCCNUM_PROVENIR=P_OCCNUM_PROVENIR
    AND OCCNUM_DESTINER=P_OCCNUM_DESTINER;
BEGIN
    --SUPPRIMER LES AFFECTION ANCIENES
    FOR V_CONT IN CUR_CONT LOOP
        --SUPPRIMER LES LIGNES DANS LA TABLE AFFECTER
        DELETE FROM AFFECTER WHERE CONTNUM= V_CONT.CONTNUM;
        --SUPPRIMER LES CONTAINERS
    DELETE FROM CONTAINER_VIRTUEL WHERE CONTNUM= V_CONT.CONTNUM;
    END LOOP;
    --AJOUTER NOUVEL AFFECTER
    PRO_RG_AFFECTER(P_BAGNUM,P_OCCNUM_PROVENIR,P_OCCNUM_DEROUTER);
END PRO_DEROUTER_AFFECTER;
/

create or replace PROCEDURE PRO_ENREGISTER_COUPONVOL 
(
  P_CLINUM IN CLIENT.CLINUM%TYPE 
, P_OCCNUM IN OCCURRENCE_VOL.OCCNUM%TYPE
) AS 
V_COUPNUM COUPON_VOL.COUPNUM%TYPE;
V_FLAG NUMBER;
BEGIN
  

  
    --TROUVER LE COUPON DE VOL PAR CLINUM ET OCCNUM
    SELECT CV.COUPNUM INTO V_COUPNUM
        FROM BILLET B,COUPON_VOL CV
        WHERE B.BILLNUM=CV.BILLNUM
        AND B.CLINUM=P_CLINUM
        AND CV.OCCNUM=P_OCCNUM;
    --Mis en jour à l'état de coupon de vol
    UPDATE COUPON_VOL SET COUPETAT='enregistré' WHERE COUPNUM=V_COUPNUM;
    --Afficher le résultat
    SYS.DBMS_OUTPUT.PUT_LINE('Le client '||P_CLINUM ||' a réussi de enregistre son coupon de vol '||P_OCCNUM);
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20006,
            'Le client '||P_CLINUM||' n''a aucun coupon de vol '||P_OCCNUM);
END PRO_ENREGISTER_COUPONVOL;
/

create or replace PROCEDURE PRO_RG_AFFECTER 
(
  I_BAGNUM IN BAGAGE.BAGNUM%TYPE 
, I_OCCNUM_PROVENIR IN OCCURRENCE_VOL.OCCNUM%TYPE 
, I_OCCNUM_DESTINER IN OCCURRENCE_VOL.OCCNUM%TYPE 
) AS 
  V_MAXCONT AEROPORT.AEROPOIDSMAXCONTAINER%TYPE;
  V_CONTNUM CONTAINER_VIRTUEL.CONTNUM%TYPE;
  V_AERONUM AEROPORT.AERONUM%TYPE;
  V_BAGKG BAGAGE.BAGKG%TYPE;
V_CONTREEL CONTAINER_REEL.CONTNUM%TYPE;
BEGIN
    BEGIN
        SELECT AE.AEROPOIDSMAXCONTAINER, AE.AERONUM INTO V_MAXCONT, V_AERONUM
            FROM AEROPORT AE, OCCURRENCE_VOL OCC, VOL V
            WHERE AE.AERONUM = V.AERONUM_ARRIVEE
            AND V.VOLNUM = OCC.VOLNUM
            AND OCC.OCCNUM = I_OCCNUM_PROVENIR;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            SELECT AE.AEROPOIDSMAXCONTAINER, AE.AERONUM INTO V_MAXCONT, V_AERONUM
                FROM AEROPORT AE, OCCURRENCE_VOL OCC, VOL V
                WHERE AE.AERONUM = V.AERONUM_DEPART
                AND V.VOLNUM = OCC.VOLNUM
                AND OCC.OCCNUM = I_OCCNUM_DESTINER;
    END;
  
    V_CONTREEL:=FUNC_AFFECT_REAL(V_AERONUM);
 
    IF I_OCCNUM_PROVENIR IS NULL THEN
    
        BEGIN
            SELECT BAGKG INTO V_BAGKG FROM BAGAGE WHERE BAGNUM = I_BAGNUM;
            SELECT C.CONTNUM INTO V_CONTNUM
                FROM CONTAINER_VIRTUEL C, BAGAGE B, AFFECTER A
                WHERE C.CONTNUM = A.CONTNUM
                AND A.BAGNUM = B.BAGNUM
                AND C.OCCNUM_PROVENIR IS NULL
                AND C.OCCNUM_DESTINER = I_OCCNUM_DESTINER
                AND ROWNUM = 1
                GROUP BY C.CONTNUM
                HAVING SUM(B.BAGKG)+V_BAGKG< V_MAXCONT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO CONTAINER_VIRTUEL VALUES(SEQ_CONTAINER.NEXTVAL, I_OCCNUM_DESTINER, NULL, NULL, V_CONTREEL);
                V_CONTNUM := SEQ_CONTAINER.CURRVAL;
        END;

    ELSIF I_OCCNUM_DESTINER IS NULL THEN
    
        BEGIN
            SELECT BAGKG INTO V_BAGKG FROM BAGAGE WHERE BAGNUM = I_BAGNUM;
            SELECT C.CONTNUM INTO V_CONTNUM
                FROM CONTAINER_VIRTUEL C, BAGAGE B, AFFECTER A
                WHERE C.CONTNUM = A.CONTNUM
                AND A.BAGNUM = B.BAGNUM
                AND C.OCCNUM_PROVENIR = I_OCCNUM_PROVENIR
                AND C.OCCNUM_DESTINER IS NULL
                AND ROWNUM = 1
                GROUP BY C.CONTNUM
                HAVING SUM(B.BAGKG)+V_BAGKG< V_MAXCONT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO CONTAINER_VIRTUEL VALUES(SEQ_CONTAINER.NEXTVAL, NULL, I_OCCNUM_PROVENIR, NULL, V_CONTREEL);
                V_CONTNUM := SEQ_CONTAINER.CURRVAL;
        END;

    ELSE
        BEGIN
            SELECT BAGKG INTO V_BAGKG FROM BAGAGE WHERE BAGNUM = I_BAGNUM;
            SELECT C.CONTNUM INTO V_CONTNUM
                FROM CONTAINER_VIRTUEL C, BAGAGE B, AFFECTER A
                WHERE C.CONTNUM = A.CONTNUM
                AND A.BAGNUM = B.BAGNUM
                AND C.OCCNUM_PROVENIR = I_OCCNUM_PROVENIR
                AND C.OCCNUM_DESTINER = I_OCCNUM_DESTINER
                AND ROWNUM = 1
                GROUP BY C.CONTNUM
                HAVING SUM(B.BAGKG)+V_BAGKG< V_MAXCONT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            INSERT INTO CONTAINER_VIRTUEL VALUES(SEQ_CONTAINER.NEXTVAL, I_OCCNUM_DESTINER, I_OCCNUM_PROVENIR, NULL, V_CONTREEL);
            V_CONTNUM := SEQ_CONTAINER.CURRVAL;
        END;
        
    END IF;

    INSERT INTO AFFECTER VALUES(I_BAGNUM, V_CONTNUM, SYSDATE);
    COMMIT;
END PRO_RG_AFFECTER;
/

create or replace PROCEDURE PRO_RG_ARRIVE 
(
  I_OCCNUM IN OCCURRENCE_VOL.OCCNUM%TYPE 
) AS 


V_AERONUM_ARRIVEE_TRAJET   AEROPORT.AERONUM%TYPE;
V_AERONUM_ARRIVEE_OCCU     AEROPORT.AERONUM%TYPE;

CURSOR CUR_COUPON IS
    SELECT COUPNUM,B.BILLNUM,TRANUM
    FROM COUPON_VOL CV,BILLET B
    WHERE CV.OCCNUM=I_OCCNUM
    AND B.BILLNUM=CV.BILLNUM
    AND CV.COUPETAT='enregistré';

V_NEXT_OCCNUM OCCURRENCE_VOL.OCCNUM%TYPE ;

BEGIN

    FOR V_COUPON IN CUR_COUPON LOOP
        --Mis en jour l'état de coupon de vol en <arrivée>
        UPDATE COUPON_VOL SET COUPETAT='arrivée' WHERE COUPNUM=V_COUPON.COUPNUM;
        --Vérifier que si c'est la dernière occurrence de vol dans ce trajet, on mettra l'état de billet en <terminé>
        SELECT AERONUM_ARRIVEE INTO V_AERONUM_ARRIVEE_TRAJET FROM TRAJET WHERE TRANUM=V_COUPON.TRANUM;
        SELECT AERONUM_ARRIVEE INTO V_AERONUM_ARRIVEE_OCCU FROM VOL V,OCCURRENCE_VOL CV WHERE CV.VOLNUM=V.VOLNUM AND CV.OCCNUM=I_OCCNUM;
        V_NEXT_OCCNUM:=FUNC_NEXTOCCURRENCE(I_OCCNUM,V_COUPON.BILLNUM);
        IF V_AERONUM_ARRIVEE_TRAJET=V_AERONUM_ARRIVEE_OCCU THEN
            UPDATE BILLET SET BILLETAT='terminé' WHERE BILLNUM=V_COUPON.BILLNUM;
        END IF;

    END LOOP;
  
    COMMIT;
END PRO_RG_ARRIVE;
/

create or replace PROCEDURE PRO_RG_COUPON_ANNULE 
(
  I_OCCNUM IN OCCURRENCE_VOL.OCCNUM%TYPE  
) AS 
CURSOR CUR_COUPON IS
    SELECT COUPNUM,BILLNUM
    FROM COUPON_VOL
    WHERE OCCNUM=I_OCCNUM
    AND COUPETAT<>'enregistré';
BEGIN
    --On pass tous les coupon de vol dont état n'est pas enregistré de cette occurrence de vol dans l'état <annulé>
    FOR V_COUPONS IN CUR_COUPON LOOP

        UPDATE COUPON_VOL SET COUPETAT ='annulé' WHERE COUPNUM=V_COUPONS.COUPNUM;
        UPDATE BILLET SET BILLETAT='terminé' WHERE BILLNUM=V_COUPONS.BILLNUM;
    END LOOP;
    COMMIT;
END PRO_RG_COUPON_ANNULE;
/

create or replace PROCEDURE PRO_RG_DECOLLEE 
(
  P_OCCNUM IN OCCURRENCE_VOL.OCCNUM%TYPE  
) AS 

CURSOR CUR_LIST IS
SELECT CV.BILLNUM,B.BILLDATEDEPART
    FROM COUPON_VOL CV,BILLET B
    WHERE B.BILLNUM=CV.BILLNUM
    AND CV.OCCNUM=P_OCCNUM;


CURSOR CUR_BAGAGES(V_BILLNUM BILLET.BILLNUM%TYPE) IS
    SELECT DISTINCT(BAGNUM) AS BAGNUM
    FROM BAGAGE 
    WHERE BILLNUM=V_BILLNUM;
    


V_OCCNUM_DESTINER OCCURRENCE_VOL.OCCNUM%TYPE ;
V_VOLNUM VOL.VOLNUM%TYPE;
V_TRAJET TRAJET.TRANUM%TYPE;
V_FALG_DEROUTER NUMBER;
V_INPUT_BILLNUM BILLET.BILLNUM%TYPE;
BEGIN
    FOR V_LIST IN CUR_LIST LOOP
        --Trouver le numéro de vol de cette orrucrrence
        SELECT VOLNUM INTO V_VOLNUM FROM OCCURRENCE_VOL WHERE OCCNUM=P_OCCNUM;
        --Trouver le numéro de billet
        SELECT TRANUM INTO V_TRAJET FROM BILLET WHERE BILLNUM=V_LIST.BILLNUM;
        /*
        Si une occurrence de vol est déroutée, avec le numéro de nouvelle occurrence de vol, 
        le trajet et la date que le client a choisies il faut trouver la prochaine occurrence de vol.
        Lorsqu¿une occurrence de vol passe dans l¿état dérouté, les clients vont avoir des coupons correspondent à une nouvelle occurrence de vol. 
        Comme cette nouvelle occurrence de vol n¿existe pas dans ses trajets originaux, 
        il faut trouver les prochaines occurrences selon ses billets.
        */
        SELECT COUNT(*) INTO V_FALG_DEROUTER FROM CONSTITUER WHERE TRANUM=V_TRAJET AND VOLNUM=V_VOLNUM;
        IF V_FALG_DEROUTER=1 THEN
            --CETTE OCCURRENCE EST DANS LE TRAJET
            V_OCCNUM_DESTINER:=FUNC_NEXTOCCURRENCE(P_OCCNUM,V_LIST.BILLNUM);
        ELSE
            --CETTE OCCURRENCE EST DÉROUTÉE
            SELECT OV.OCCNUM INTO V_OCCNUM_DESTINER
                FROM CONSTITUER C,VOL V,OCCURRENCE_VOL OV
                WHERE C.TRANUM=V_TRAJET
                AND C.VOLNUM=V.VOLNUM
                AND OV.VOLNUM=V.VOLNUM
                AND TO_DATE(TO_CHAR(OV.OCCDATE,'dd/mm/yy'),'dd/mm/yy')=TO_DATE(TO_CHAR(V_LIST.BILLDATEDEPART,'dd/mm/yy'),'dd/mm/yy')+C.JOURPLUS
                AND V.AERONUM_DEPART=(
                    SELECT AERONUM_ARRIVEE FROM VOL V2 WHERE V2.VOLNUM=V_VOLNUM
                );
        END IF;
        --Quand l'occurrence de vol décolle, on affect les bagages
        --Trouver les bagages de passenger
        OPEN CUR_BAGAGES(V_LIST.BILLNUM);
        LOOP
            FETCH CUR_BAGAGES INTO V_INPUT_BILLNUM;
            EXIT WHEN CUR_BAGAGES%NOTFOUND;
            PRO_RG_AFFECTER(V_INPUT_BILLNUM,P_OCCNUM,V_OCCNUM_DESTINER);
        END LOOP;
        CLOSE CUR_BAGAGES;
    END LOOP;
    --Si l'état de coupon n'est pas enregistré, on va changer l'état de ces coupons de vol à <anullée>
    PRO_RG_COUPON_ANNULE(P_OCCNUM);
    
COMMIT;
END PRO_RG_DECOLLEE;
/

create or replace PROCEDURE PRO_RG_DEROUTEE 
(
  P_OCCNUM IN OCCURRENCE_VOL.OCCNUM%TYPE  
) AS 

CURSOR CUR_COUPON IS
    SELECT COUPNUM,BILLNUM
    FROM COUPON_VOL CV
    WHERE OCCNUM=P_OCCNUM;

CURSOR CUR_BAGAGES(V_BILLNUM BILLET.BILLNUM%TYPE) IS
    SELECT DISTINCT(BAGNUM) AS BAGNUM
    FROM BAGAGE
    WHERE BILLNUM=V_BILLNUM;

V_NOUVEL_OCCNUM OCCURRENCE_VOL.OCCNUM%TYPE ;
V_OCC_DESTINER_AVANT OCCURRENCE_VOL.OCCNUM%TYPE ;
V_INPUT_BILLNUM BILLET.BILLNUM%TYPE;
BEGIN
    FOR V_COUPON IN CUR_COUPON LOOP
        --Passer les coupons de vol dans l'état <arrivée>
        UPDATE COUPON_VOL SET COUPETAT='arrivée' WHERE COUPNUM=V_COUPON.COUPNUM;
        --Trouver l'occurrence de vol disponible la plus proche
        SELECT OV.OCCNUM INTO V_NOUVEL_OCCNUM
            FROM  VOL V,OCCURRENCE_VOL OV
            LEFT JOIN COUPON_VOL CV ON OV.OCCNUM=CV.OCCNUM
            WHERE V.AERONUM_DEPART=(
                SELECT AERONUM
                    FROM OCCURRENCE_VOL OV1
                    WHERE OV1.OCCNUM=P_OCCNUM)
            AND V.AERONUM_ARRIVEE=(
                SELECT AERONUM_ARRIVEE
                    FROM VOL V2,OCCURRENCE_VOL OV2
                    WHERE V2.VOLNUM=OV2.VOLNUM
                    AND OV2.OCCNUM=P_OCCNUM)
            AND OV.VOLNUM=V.VOLNUM
            --Trouver les occurrences dont la date de départ doit être suivante de le moment où cette processus est executé
            AND TO_DATE(TO_CHAR(OV.OCCDATE,'dd/mm/yy')||'-'||TO_CHAR(V.H_DEPART,'HH24:MI:SS'),'dd/mm/yy-HH24:MI:SS')>SYSDATE 
            AND OV.OCCETAT='ouverte à la réservation'
            AND ROWNUM=1    --La première ligne est l'occurrence de vol disponible la plus proche
            GROUP BY OV.OCCNUM,V.VOLNBPLACES,OCCDATE
            HAVING COUNT(CV.COUPNUM)<V.VOLNBPLACES --Trouver les occurrences disponibles dont places est disponible
            ORDER BY OCCDATE ASC; --Mis en ordre les occurrences par la date pour trouver l'occurrence la plus proche

        --On crée les nouvels coupons de vol dont l'état est réservé
        INSERT INTO COUPON_VOL VALUES(SEQ_COUPONVOL.NEXTVAL,V_NOUVEL_OCCNUM,V_COUPON.BILLNUM,'réservé');

        --On affect les bagages
        --On trouve l'occurrence de vol prochaine pour permettre le processus <PRO_DEROUTER_AFFECTER> de trouver et supprimer 
        --les containers anciens affectés  qui sont déjà affecté quand cette occurrence décollé.
        V_OCC_DESTINER_AVANT:=FUNC_NEXTOCCURRENCE(P_OCCNUM,V_COUPON.BILLNUM);
        OPEN CUR_BAGAGES(V_COUPON.BILLNUM);
        LOOP
            FETCH CUR_BAGAGES INTO V_INPUT_BILLNUM;
            EXIT WHEN CUR_BAGAGES%NOTFOUND;
            PRO_DEROUTER_AFFECTER(V_INPUT_BILLNUM,V_OCC_DESTINER_AVANT,V_NOUVEL_OCCNUM,P_OCCNUM);
        END LOOP;
        CLOSE CUR_BAGAGES;
    END LOOP;
  COMMIT;
EXCEPTION
 WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20200,'Il n''y pas de vol correspondant');
END PRO_RG_DEROUTEE;
/

create or replace PROCEDURE PRO_RG_PROVISION_BAGAGE 
(
  P_BILLNUM IN BILLET.BILLNUM%TYPE
, P_BAGKG IN BAGAGE.BAGKG%TYPE
) AS 
  V_LIMITEKG TRAJET.TRANKGBAG%TYPE;
  V_KGBAG TRAJET.TRANKGBAG%TYPE;
  V_TRATARIFKGSUP TRAJET.TRATARIFKGSUP%TYPE;
  V_MONTANT_BAG PROVISION.PROVMONTANT%TYPE;
  V_NBOPPROV NUMBER;
BEGIN
    --Trouver le poids limité pour ce billet
    SELECT T.TRANKGBAG, T.TRATARIFKGSUP INTO V_LIMITEKG, V_TRATARIFKGSUP
        FROM TRAJET T, BILLET BIL
        WHERE BIL.TRANUM = T.TRANUM
        AND BIL.BILLNUM = P_BILLNUM;
    --Voir le tableau provision pour vérifier si le client a déjà payé pour son bagage
    SELECT COUNT (*) INTO V_NBOPPROV
        FROM PROVISION 
        WHERE BILLNUM = P_BILLNUM
        AND PROVOPTYPE='crédit';
    --If no extra fee, count all bagages to see if need to pay more
    IF V_NBOPPROV = 1 THEN
        --Count the weight of all bagages of this ticket
        SELECT NVL(SUM(BAGKG),0) INTO V_KGBAG
            FROM BAGAGE
            WHERE BILLNUM = P_BILLNUM;
    --Comparer le poids du bagage et le poids limité pour ce billet
    
        IF V_LIMITEKG < (V_KGBAG) THEN
            --Compter le montant suplimentaire et ajouter ce montant dans le tableau provision
            V_MONTANT_BAG := (V_KGBAG- V_LIMITEKG) * V_TRATARIFKGSUP;
            INSERT INTO PROVISION VALUES(SEQ_PROVISION.NEXTVAL, P_BILLNUM, 'crédit', V_MONTANT_BAG, SYSDATE);
        END IF;    
    ELSE
        V_MONTANT_BAG := P_BAGKG * V_TRATARIFKGSUP;
        INSERT INTO PROVISION VALUES(SEQ_PROVISION.NEXTVAL, P_BILLNUM, 'crédit', V_MONTANT_BAG, SYSDATE);
    END IF;
  COMMIT;
END PRO_RG_PROVISION_BAGAGE;
/

create or replace PROCEDURE PRO_RG_PROVISION_TICKET 
(
  P_BILLETNUM IN BILLET.BILLNUM%TYPE,
  P_TRAJETNUM IN TRAJET.TRANUM%TYPE
) AS 
    V_MONTANT_TRAJET NUMBER;
    V_MONTANT_TAXE AEROPORT.AEROTAXE%TYPE;
BEGIN
    --Calcul le montant de trajet
    SELECT TRATARIFBILLET INTO V_MONTANT_TRAJET FROM TRAJET WHERE TRANUM=P_TRAJETNUM;
    --Calcul le somme de taxe
    SELECT SUM(AEROTAXE) INTO V_MONTANT_TAXE
        FROM(--La liste de taxe
            SELECT AEROTAXE 
                FROM CONSTITUER C,VOL V,AEROPORT A
                WHERE C.TRANUM=P_TRAJETNUM
                AND C.VOLNUM=V.VOLNUM
                AND (V.AERONUM_DEPART=A.AERONUM
                OR   V.AERONUM_ARRIVEE=A.AERONUM)
        ) A;
  

    --Inserter la valeur
    INSERT INTO PROVISION VALUES(SEQ_PROVISION.NEXTVAL,P_BILLETNUM,'crédit',V_MONTANT_TRAJET+V_MONTANT_TAXE,SYSDATE);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'La trajet '||P_TRAJETNUM||' n''exist pas ');

END PRO_RG_PROVISION_TICKET;
/

create or replace FUNCTION FUNC_AFFECT_REAL (P_AERONUM IN AEROPORT.AERONUM%TYPE) 
RETURN CONTAINER_REEL.CONTNUM%TYPE
AS 
  V_RESULT CONTAINER_REEL.CONTNUM%TYPE; 
BEGIN 
    --TROUVER  UN CONTAINER RÉEL DISPONIBLE
    SELECT CONTNUM  INTO  V_RESULT 
        FROM    CONTAINER_REEL 
        WHERE   AERONUM = P_AERONUM 
        AND     ROWNUM = 1 
        AND     DISPONIBLE ='oui'; 
    RETURN V_RESULT; 
EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        RAISE_APPLICATION_ERROR(-20200, 
                'Il n''y pas assez de container réel'); 
END FUNC_AFFECT_REAL;
/

create or replace FUNCTION FUNC_NEXTOCCURRENCE 
(
  P_OCCNUM IN OCCURRENCE_VOL.OCCNUM%TYPE  
, P_BILLNUM IN BILLET.BILLNUM%TYPE 
) RETURN OCCURRENCE_VOL.OCCNUM%TYPE  AS
  V_NEXTOCCU NUMBER:=-1;
BEGIN
    BEGIN
        --Trouver l'occurrence de vol prochaine dans le trajet
        SELECT DISTINCT(OCC.OCCNUM) INTO V_NEXTOCCU
        FROM CONSTITUER C, OCCURRENCE_VOL OCC, BILLET BIL,
            (SELECT C1.NUMORDRE AS OCCNOW, C1.JOURPLUS AS JP
            FROM CONSTITUER C1, OCCURRENCE_VOL OCC1, BILLET BIL1
            WHERE BIL1.TRANUM = C1.TRANUM
            AND C1.VOLNUM = OCC1.VOLNUM
            AND OCC1.OCCNUM = P_OCCNUM
            AND BIL1.BILLNUM = P_BILLNUM) OCCM
        WHERE BIL.TRANUM = C.TRANUM
        AND C.NUMORDRE = OCCM.OCCNOW + 1
        AND C.VOLNUM = OCC.VOLNUM
        AND TO_DATE(To_char(OCC.OCCDATE, 'YYYY/MM/DD'),'YYYY/MM/DD') = TO_DATE(To_char(BIL.BILLDATEDEPART+C.JOURPLUS,'YYYY/MM/DD'), 'YYYY/MM/DD');
 
    EXCEPTION
        WHEN NO_DATA_FOUND THEN V_NEXTOCCU:=NULL;
    END;
    RETURN V_NEXTOCCU;
END FUNC_NEXTOCCURRENCE;
/
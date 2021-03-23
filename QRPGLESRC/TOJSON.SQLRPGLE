**free
////////////////////////////////////////////////////////////////////////////////
//                                    PROGRAMME
//
// Création : Lucas Kleinmann
//            27/11/2020
//
//
// Description :
// Exécute une requête SQL, récupère les données retournées et les insère dans un tampon YAJL puis
// retourne un pointeur vers ce tampon ainsi que sa taille en octets.
////////////////////////////////////////////////////////////////////////////////


//------------------------------------------------------------------------------
// Options de compilation
//------------------------------------------------------------------------------
ctl-opt dftactgrp(*no) actgrp('SQLTO') bnddir('YAJL': 'SQLTO');
ctl-opt datfmt(*iso) timfmt(*iso) decedit(*jobrun) option(*nodebugio);


//------------------------------------------------------------------------------
// Imports de fichiers
//------------------------------------------------------------------------------
/copy QRPGLESRC,YAJL_H  // YAJL : fichier d'en-têtes
/copy QCOPYSRC,SQLTORPG_H  // Conversion des données SQL en RPG: fichier d'en-têtes


//------------------------------------------------------------------------------
// Constantes et variables
//------------------------------------------------------------------------------

// Variables YAJL
dcl-s errorMessage varchar(500) inz;

// Variables globales
dcl-s i uns(5) inz;




////////////////////////////////////////////////////////////////////////////////////////////////////
// Programme principal                                                                             /
////////////////////////////////////////////////////////////////////////////////////////////////////




//------------------------------------------------------------------------------
// Interface du programme principal
//------------------------------------------------------------------------------
dcl-pi *n;
  request varchar(32000) options(*varsize);
  IFSpath varchar(5000) options(*nopass);
end-pi;


//------------------------------------------------------------------------------
// Initialisations
//------------------------------------------------------------------------------

yajl_genOpen(*on);

// Signalisation de l'utilisation de SQLDA
exec SQL
  INCLUDE SQLDA;

// Déclaration du curseur sur la requête
exec SQL
  DECLARE C1 CURSOR FOR Q1;

// Exécution de la requête, définition de la structure de la réponse
exec SQL
  PREPARE Q1 INTO :SQLDA FROM :request;

// Gestion d'erreur SQL
if SQLstate <> '00000';
  // Cas d'un envoi de résultat par serveur HTTP
  if %parms = 1;
    yajl_beginObj();
      yajl_addChar('Error': 'Failed to prepare SQL request. SQLSTATE : ' + SQLSTATE);
    yajl_endObj();

    yajl_writeStdout(200: errorMessage);
    yajl_genClose();
  endif;

  return;
endif;

InitializeSQLDA(); // Préparation de la LDA pour l'accueil de données


//------------------------------------------------------------------------------
// Création du buffer JSON
//------------------------------------------------------------------------------


yajl_beginObj();
yajl_beginArray();

// Ouverture du curseur
exec SQL
  OPEN C1;

dow SQLSTATE = '00000';
  // Récupération d'une ligne du curseur
  exec SQL
  FETCH C1 USING DESCRIPTOR :SQLDA;

  if SQLSTATE <> '00000';
    iter;
  else; // Parcours des colonnes de la ligne via SQL_VAR
    yajl_beginObj();
    for i = 1 to SQLD;
      SQLVAR = SQL_VAR(i);
      SQLVARtoJSON();
    endfor;
    yajl_endObj();
  endif;

enddo;

exec SQL
  CLOSE c1;

yajl_endArray();
yajl_endObj();


// Envoi / stockage du document JSON et fini du programme
if %parms() > 1;
  yajl_saveBuf(IFSpath: errorMessage);
else;
  yajl_writeStdout(200: errorMessage);
endif;

yajl_genClose();
return;




////////////////////////////////////////////////////////////////////////////////////////////////////
// Fonctions et procédures
////////////////////////////////////////////////////////////////////////////////////////////////////




//------------------------------------------------------------------------------
// InitializeSQLDA
//   Effectue une allocation mémoire pour chaque champ de SQLVAR
//------------------------------------------------------------------------------
dcl-proc InitializeSQLDA;

  // Interface de procédure
  dcl-pi *n end-pi;

  //--------------------------------------------------------

  // Parcours de la SQLDA
  for i = 1 to SQLD;
    SQLVAR = SQL_VAR(i);
    SQLDATA = %alloc(SQLLEN); // données SQL utiles

    // Indicateur de données nullables pour les CLOBs
    if SQLTYPE = 408 or SQLTYPE = 409;
      SQLIND = %alloc(1);
    endif;

    SQL_VAR(i) = SQLVAR;
  endfor;
end-proc;



//------------------------------------------------------------------------------
// SQLVARtoJSON
//   Identifie le type de donnée contenue dans SQLVAR, la convertie et renseigne le document JSON
//   avec.
//------------------------------------------------------------------------------
dcl-proc SQLVARtoJSON;

  // Interface de procédure
  dcl-pi *n end-pi;

  //--------------------------------------------------------

  select;
    // Date
    when SQLTYPE = 384 or SQLTYPE = 385;
      yajl_addChar(%trim(SQLNAME): %char(ToDate(SQLDATA)));

    // Time
    when SQLTYPE = 388 or SQLTYPE = 389;
      yajl_addChar(%trim(SQLNAME): %char(ToTime(SQLDATA)) );

    // Timestamp sans timezone
    when SQLTYPE = 392 or SQLTYPE = 393;
      yajl_addChar(%trim(SQLNAME): %char(ToTimeStamp(SQLDATA)) );

    // CLOB
    when SQLTYPE = 408 or SQLTYPE = 409;
    // Se renseigner sur la conversion de CLOBs

    // VarChar court
    when SQLTYPE = 448 or SQLTYPE = 449;
      yajl_addChar(%trim(SQLNAME): ToVarCharShort(SQLDATA: SQLLEN));

    // Char
    when SQLTYPE = 452 or SQLTYPE = 453;
      yajl_addChar(%trim(SQLNAME): %trim(ToChar(SQLDATA: SQLLEN)) );

    // Varchar long
    when SQLTYPE = 456 or SQLTYPE = 457;
      yajl_addChar(%trim(SQLNAME): ToVarCharLong(SQLDATA: SQLLEN));

    // Vargraph court
    when SQLTYPE = 464 or SQLTYPE = 465;
    //yajl_addChar(%trim(SQLNAME): ToVarGraphShort(SQLDATA: SQLLEN));

    // Graph
    when SQLTYPE = 468 or SQLTYPE = 469;
    //yajl_addChar(%trim(SQLNAME): ToGraph(SQLDATA: SQLLEN));

    // Vargraph long
    when SQLTYPE = 472 or SQLTYPE = 473;
    //yajl_addChar(%trim(SQLNAME): ToVarGraphLong(SQLDATA: SQLLEN));

    // Floating point
    when SQLTYPE = 480 or SQLTYPE = 481;
      if SQLLEN = 4;
        yajl_addNum(%trim(SQLNAME): %char(ToFloatSingle(SQLDATA)) ); // Simple précision
      else;
        yajl_addNum(%trim(SQLNAME): %char(ToFloatDouble(SQLDATA)) ); // Double précision
      endif;

    // Packed
    when SQLTYPE = 484 or SQLTYPE = 485;
      yajl_addNumf(%trim(SQLNAME): ToPacked(SQLDATA: SQLLEN));

    // Zoned
    when SQLTYPE = 488 or SQLTYPE = 489;
      yajl_addNumf(%trim(SQLNAME): ToZoned(SQLDATA: SQLLEN));

    // Big Integer
    when SQLTYPE = 492 or SQLTYPE = 493;
      yajl_addNumf(%trim(SQLNAME): ToInt20(SQLDATA));

    // Large Integer
    when SQLTYPE = 496 or SQLTYPE = 497;
      yajl_addNumf(%trim(SQLNAME): ToInt10(SQLDATA));

    // Small Integers
    when  SQLTYPE = 500 or SQLTYPE = 501;
      If SQLLEN = 5;
        yajl_addNumf(%trim(SQLNAME): ToInt5(SQLDATA)); // Small Integer
      else;
        yajl_addNumf(%trim(SQLNAME): ToInt3(SQLDATA)); // Tiny Integer
      endif;

    // Char par défaut
    other;
      yajl_addChar(%trim(SQLNAME): %trim(ToChar(SQLDATA: SQLLEN)) );
  endsl;

end-proc;

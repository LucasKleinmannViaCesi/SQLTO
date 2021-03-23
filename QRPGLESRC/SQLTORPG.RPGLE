**free
////////////////////////////////////////////////////////////////////////////////
//                             PROGRAMME DE SERVICES
//
// Création : Lucas Kleinmann
//            25/01/2021
//
// Description :
//   Fonctions de conversion de données au format SQL en des variables RPG
//
////////////////////////////////////////////////////////////////////////////////


//******************************************************************************
// Options de compilation                                                      *
//******************************************************************************
ctl-opt datfmt(*iso) timfmt(*iso) decedit(*jobrun) option(*nodebugio) nomain;
ctl-opt bnddir('SQLTO' : 'QC2LE');



//******************************************************************************
// Imports de fichiers                                                         *
//******************************************************************************
/copy QCOPYSRC,SQLTORPG_H  // Conversion SQL vers RPG : prtotypes et variables




////////////////////////////////////////////////////////////////////////////////////////////////////
// Procédures et fonctions                                                                         /
////////////////////////////////////////////////////////////////////////////////////////////////////




//----------------------------------------------------------
// ToDate
//----------------------------------------------------------
dcl-proc ToDate export;
  // Interface de procédure
  dcl-pi *n date(*iso) rtnparm;
    data pointer const;
  end-pi;

  //--------------------------------------------------------

  // Variables locales
  dcl-s res date based(data);

  //--------------------------------------------------------

  return res;
end-proc;



//----------------------------------------------------------
// ToTime
//----------------------------------------------------------
dcl-proc ToTime export;
  // Interface de procédure
  dcl-pi *n time(*iso) rtnparm;
    data pointer const;
  end-pi;

  //--------------------------------------------------------

  // Variables locales
  dcl-s res time based(data);

  //--------------------------------------------------------

  return res;
end-proc;



//----------------------------------------------------------
// ToTimeStamp
//----------------------------------------------------------
dcl-proc ToTimeStamp export;
  // Interface de procédure
  dcl-pi *n timestamp rtnparm;
    data pointer const;
  end-pi;

  //--------------------------------------------------------

  // Variables locales
  dcl-s res timestamp based(data);

  //--------------------------------------------------------

  return res;
end-proc;



//----------------------------------------------------------
// ToVarCharShort
//----------------------------------------------------------
dcl-proc ToVarCharShort export;
  // Interface de procédure
  dcl-pi *n varchar(STRING_MAX_LENGTH: 2) rtnparm;
    data pointer const;
    length int(5) const;
  end-pi;

  //--------------------------------------------------------

  return %str(data : length);
end-proc;



//----------------------------------------------------------
// ToVarCharLong
//----------------------------------------------------------
dcl-proc ToVarCharLong export;
  // Interface de procédure
  dcl-pi *n varchar(STRING_MAX_LENGTH: 4) rtnparm;
    data pointer const;
    length int(5) const;
  end-pi;

  //--------------------------------------------------------

  return %str(data : length);
end-proc;




//----------------------------------------------------------
// ToChar
//----------------------------------------------------------
dcl-proc ToChar export;
  // Interface de procédure
  dcl-pi *n char(STRING_MAX_LENGTH) rtnparm;
    data pointer const;
    length int(5) const;
  end-pi;

  //--------------------------------------------------------

  return %str(data : length);
end-proc;



//----------------------------------------------------------
// ToFloatSingle
//----------------------------------------------------------
dcl-proc ToFloatSingle export;
  // Interface de procédure
  dcl-pi *n float(4) rtnparm;
    data pointer const;
  end-pi;

  //--------------------------------------------------------

  // Variables locales
  dcl-s res float(4) based(data);

  //--------------------------------------------------------

  return res;
end-proc;



//----------------------------------------------------------
// ToFloatDouble
//----------------------------------------------------------
dcl-proc ToFloatDouble export;
  // Interface de procédure
  dcl-pi *n float(8) rtnparm;
    data pointer const;
  end-pi;

  //--------------------------------------------------------

  // Variables locales
  dcl-s res float(8) based(data);

  //--------------------------------------------------------

  return res;
end-proc;



//----------------------------------------------------------
// ToPacked
//----------------------------------------------------------
dcl-proc ToPacked export;
  // Interface de procédure
  dcl-pi *n packed(63:15) rtnparm;
    data pointer const;
    length int(5) const;
  end-pi;

  //--------------------------------------------------------

  // programmes extérieurs
  dcl-pr HexaToChar extproc('cvthc');
    res pointer value;
    hexadecimals pointer value;
    resSize int(10) value;
  end-pr;

  //--------------------------------------------------------

  // Variables locales
  dcl-s res varchar(128) inz;
  dcl-s alphaNumeric char(128) inz;
  dcl-s totalLength int(5) inz;
  dcl-s decimalsLength int(5) inz;

  dcl-s digitsPosition int(5) inz;
  dcl-s decimalsPosition int(5) inz;
  dcl-s substractLength int(5) inz;

  //--------------------------------------------------------

  // Initialisation (je ne connais pas la raison de cette division par 256)
  totalLength = %int(length / 256);
  decimalsLength = length - (totalLength * 256);

  // Nombre pair / impair (Représentation en mémoire d'un packed)
  if %rem(totalLength: 2) = 0;
    totalLength += 2;
  else;
    totalLength += 1;
  endif;

  // Conversion hexadecimal en alphanumérique
  HexaToChar(%addr(alphaNumeric): data: totalLength);
  digitsPosition = %check('0': alphaNumeric);
  decimalsPosition = totalLength - decimalsLength;

  if %check('0FD': alphaNumeric) = 0;
    res = '0'; // Valeur nulle
  else;

    // Sans décimales
    if decimalsLength = 0;
      substractLength = totalLength - digitsPosition;
      res += %subst(alphaNumeric: digitsPosition: substractLength);

    // Avec décimales
    else;
      if digitsPosition >= decimalsPosition;
        res += '0'; // Décimales nulles
      else;
        substractLength = decimalsPosition - digitsPosition;
        res += %subst(alphaNumeric: digitsPosition: substractLength); // Décimales non nulles
      endif;

      res += ',' + %subst(alphaNumeric: decimalsPosition: decimalsLength);
    endif;
  endif;

  // vérification finale et retour du résultat
  if res = *blanks;
    res = '0';
  endif;
  return %dec(res: 63: 15);
end-proc;



//----------------------------------------------------------
// ToZoned
//----------------------------------------------------------
dcl-proc ToZoned export;
  // Interface de procédure
  dcl-pi *n zoned(63:15) rtnparm;
    data pointer const;
    length int(5) const;
  end-pi;

  //--------------------------------------------------------

  // Variables locales
  dcl-s res varchar(64) inz;

  //--------------------------------------------------------
  res = %str(data : length);
  return %dec(res : 63 : 15);
end-proc;



//----------------------------------------------------------
// ToInt3
//----------------------------------------------------------
dcl-proc ToInt3 export;
  // Interface de procédure
  dcl-pi *n int(3) rtnparm;
    data pointer const;
  end-pi;

  //--------------------------------------------------------

  // Variables locales
  dcl-s res int(3) based(data);

  //--------------------------------------------------------

  return res;
end-proc;



//----------------------------------------------------------
// ToInt5
//----------------------------------------------------------
dcl-proc ToInt5 export;
  // Interface de procédure
  dcl-pi *n int(5) rtnparm;
    data pointer const;
  end-pi;

  //--------------------------------------------------------

  // Variables locales
  dcl-s res int(5) based(data);

  //--------------------------------------------------------

  return res;
end-proc;



//----------------------------------------------------------
// ToInt10
//----------------------------------------------------------
dcl-proc ToInt10 export;
  // Interface de procédure
  dcl-pi *n int(10) rtnparm;
    data pointer const;
  end-pi;

  //--------------------------------------------------------

  // Variables locales
  dcl-s res int(10) based(data);

  //--------------------------------------------------------

  return res;
end-proc;



//----------------------------------------------------------
// ToInt20
//----------------------------------------------------------
dcl-proc ToInt20 export;
  // Interface de procédure
  dcl-pi *n int(20) rtnparm;
    data pointer const;
  end-pi;

  //--------------------------------------------------------

  // Variables locales
  dcl-s res int(20) based(data);

  //--------------------------------------------------------

  return res;
end-proc;

**free
////////////////////////////////////////////////////////////////////////////////////////////////////
//                                      Source à importer                                          /
//                                                                                                 /
// Création : Lucas Kleinmann                                                                      /
//            25/01/2021                                                                           /
//                                                                                                 /
// Fichier source à importer dans un programme via une instruction '/copy'.                        /
// Contient les prototypes des programmes du programme de services SQLTORPG                        /
////////////////////////////////////////////////////////////////////////////////////////////////////




//------------------------------------------------------------------------------
// Constantes et variables
//------------------------------------------------------------------------------
dcl-c SQL_NUM 40; // Nombre de champs par ligne (valeur recommandée par le manuel IBM pour DB2 10)
dcl-c STRING_MAX_LENGTH 32767;




////////////////////////////////////////////////////////////////////////////////
// Prototypes des programmes
////////////////////////////////////////////////////////////////////////////////




//------------------------------------------------------------------------------
// ToDate
//   Convertit une donnée de type SQL Date au type RPG Date
//------------------------------------------------------------------------------
dcl-pr ToDate date(*iso) rtnparm;
  data pointer const;
end-pr;


//------------------------------------------------------------------------------
// ToTime
//   Convertit une donnée de type SQl Time au type RPG Time
//------------------------------------------------------------------------------
dcl-pr ToTime time(*iso) rtnparm;
  data pointer const;
end-pr;


//------------------------------------------------------------------------------
// ToTimeStamp
//   Convertit une donnée de type SQl TimeStamp au type RPG TimeStamp
//------------------------------------------------------------------------------
dcl-pr ToTimestamp timestamp rtnparm;
  data pointer const;
end-pr;


//------------------------------------------------------------------------------
// ToVarCharShort
//   Convertit une donnée de type SQl VarChar au type RPG VarChar avec la longeur de la variable
//   stockée sur 2 octets
//------------------------------------------------------------------------------
dcl-pr ToVarCharShort varchar(STRING_MAX_LENGTH:2) rtnparm;
  data pointer const;
  length int(5) const;
end-pr;


//------------------------------------------------------------------------------
// ToVarCharLong
//   Convertit une donnée de type SQl VarChar au type RPG VarChar avec la longueur de la variable
//   stockée sur 4 octets
//------------------------------------------------------------------------------
dcl-pr ToVarCharLong varchar(STRING_MAX_LENGTH:4) rtnparm;
  data pointer const;
  length int(5) const;
end-pr;


//------------------------------------------------------------------------------
// ToChar
//   Convertit une donnée de type SQl Char au type RPG Char
//------------------------------------------------------------------------------
dcl-pr ToChar char(STRING_MAX_LENGTH) rtnparm;
  data pointer const;
  length int(5) const;
end-pr;


//------------------------------------------------------------------------------
// ToFloatSingle
//   Convertit une donnée de type SQl Floating Point au type RPG FLoat simple précision
//------------------------------------------------------------------------------
dcl-pr ToFloatSingle float(4) rtnparm;
  data pointer const;
end-pr;


//------------------------------------------------------------------------------
// ToFloatDouble
//   Convertit une donnée de type SQl Floating Point au type RPG Float double précision
//------------------------------------------------------------------------------
dcl-pr ToFloatDouble float(8) rtnparm;
  data pointer const;
end-pr;


//------------------------------------------------------------------------------
// ToPacked
//   Convertit une donnée de type SQl Packed Decimal au type RPG Packed
//------------------------------------------------------------------------------
dcl-pr ToPacked packed(63:15) rtnparm;
  data pointer const;
  length int(5) const;
end-pr;


//------------------------------------------------------------------------------
// ToZoned
//   Convertit une donnée de type SQl Numeric au type RPG Zoned
//------------------------------------------------------------------------------
dcl-pr ToZoned zoned(63:15) rtnparm;
  data pointer const;
  length int(5) const;
end-pr;


//------------------------------------------------------------------------------
// ToInt3
//   Convertit une donnée de type SQl Packed Decimal au type RPG Packed
//------------------------------------------------------------------------------
dcl-pr ToInt3 int(3) rtnparm;
  data pointer const;
end-pr;


//------------------------------------------------------------------------------
// ToInt5
//   Convertit une donnée de type SQl Packed Decimal au type RPG Packed
//------------------------------------------------------------------------------
dcl-pr ToInt5 int(5) rtnparm;
  data pointer const;
end-pr;


//------------------------------------------------------------------------------
// ToInt10
//   Convertit une donnée de type SQl Packed Decimal au type RPG Packed
//------------------------------------------------------------------------------
dcl-pr ToInt10 int(10) rtnparm;
  data pointer const;
end-pr;


//------------------------------------------------------------------------------
// ToInt20
//   Convertit une donnée de type SQl Packed Decimal au type RPG Packed
//------------------------------------------------------------------------------
dcl-pr ToInt20 int(20) rtnparm;
  data pointer const;
end-pr;

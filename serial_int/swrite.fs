: SWRITE
  BEGIN 
    BEGIN ( WAIT FOR KEY )
      INKEY
      ?DUP
    UNTIL

    DUP 0D = ( IF CR, ALSO NEED LF )
    IF
      TX
      0A TX
    ELSE
      TX
    THEN

    BEGIN ( WAIT FOR NO KEY, TO AVOID TOO MANY CHARACTERS )
      INKEY 0=
    UNTIL
    0
  UNTIL ( LOOP UNTIL USER BREAKS OUT )
;
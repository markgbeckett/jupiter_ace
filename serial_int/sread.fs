: SREAD
  BEGIN
    BEGIN
      RX
      1+ ?DUP
    UNTIL

    1- EMIT

    0
  UNTIL
;

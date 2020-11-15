15 CONSTANT COUNT ( NUMBER OF STARS, <= 40 )

0 VARIABLE SEED  ( RANDOM NUMBER SEED )

DEFINER ARRAY ( ARRAY CONSTRUCT )
  2 * ALLOT
DOES>
  SWAP 2 * +
;!

( SET ASIDE SPACE FOR VARIOUS ARRAYS )
40 ARRAY XC
40 ARRAY YC
40 ARRAY ZC
40 ARRAY TX
40 ARRAY TY

( RANDOM NUMBER GENERATOR )
: (RND)
  SEED @
  259 * 3 +
  32767 AND
  DUP
  SEED !
;

: RND
  (RND)
  32767 */
;

: STARS
  CLS
  COUNT 0 DO (INITIALISE STARS)
    16 RND 8 - 4 * I XC !
    11 RND 5 - 4 * I YC !
    12 6 RND + I ZC !
    32 I TX !
    22 I TY !
  LOOP

  ( MAIN LOOP )
  BEGIN
    COUNT 0 DO ( DELETE OLD STARS )
      I TX @ 32 +
      I TY @ 22 +
      0 PLOT

      ( UPDATE POSITION )
      I XC @ 4 *
      I ZC @ 3 + /
      I TX !

      I YC @ 4 *
      I ZC @ 3 + /
      I TY !

      I ZC @ 1 -
      I ZC !
      I ZC @

      ( CHECK IF LEFT SCREEN )
      1 < IF
        16 RND 8 - 4 * I XC !
	11 RND 5 - 4 * I YC !
	12 6 RND + I ZC !
      THEN

      ( REPLOT STARS )
      I TX @ 32 +
      I TY @ 22 +
      1 PLOT
    LOOP

    0
  UNTIL
;

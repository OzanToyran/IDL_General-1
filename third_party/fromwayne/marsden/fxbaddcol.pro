	PRO FXBADDCOL,INDEX,HEADER,ARRAY,TTYPE,COMMENT,TUNIT=TUNIT,	$
		TSCAL=TSCAL,TZERO=TZERO,TNULL=TNULL,TDISP=TDISP,	$
		TDMIN=TDMIN,TDMAX=TDMAX,TDESC=TDESC,TROTA=TROTA,	$
		TRPIX=TRPIX,TRVAL=TRVAL,TDELT=TDELT,NO_TDIM=NO_TDIM,	$
		VARIABLE=VARIABLE,DCOMPLEX=DCOMPLEX,BIT=BIT,LOGICAL=LOGICAL
;+
; Project     : SOHO - CDS
;
; Name        : 
;	FXBADDCOL
; Purpose     : 
;	Adds a column to a binary table extension.
; Explanation : 
;	Modify a basic FITS binary table extension (BINTABLE) header array to
;	define a column.
; Use         : 
;	FXBADDCOL, INDEX, HEADER, ARRAY  [, TTYPE ]
; Inputs      : 
;	HEADER	= String array containing FITS extension header.
;	ARRAY	= IDL variable used to determine the data size and type
;		  associated with the column.  If the column is defined as
;		  containing variable length arrays, then ARRAY must be of the
;		  maximum size to be stored in the column.
; Opt. Inputs : 
;	TTYPE	= Column label.
;	COMMENT = Comment for TTYPE
; Outputs     : 
;	INDEX	= Index (1-999) of the created column.
;	HEADER	= The header is modified to reflect the added column.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	VARIABLE= If set, then the column is defined to contain pointers to
;		  variable length arrays in the heap area.
;	DCOMPLEX= If set, and ARRAY is complex, with the first dimension being
;		  two (real and imaginary parts), then the column is defined as
;		  double-precision complex (type "M").
;	BIT	= If passed, and ARRAY is of type byte, then the column is
;		  defined as containg bit mask arrays (type "X"), with the
;		  value of BIT being equal to the number of mask bits.
;	LOGICAL	= If set, and array is of type byte, then the column is defined
;		  as containing logical arrays (type "L").
;	NO_TDIM	= If set, then the TDIMn keyword is not written out to the
;		  header.  No TDIMn keywords are written for columns containing
;		  variable length arrays.
;	TUNIT	= If passed, then corresponding keyword is added to header.
;	TSCAL	= Same.
;	TZERO	= Same.
;	TNULL	= Same.
;	TDISP	= Same.
;	TDMIN	= Same.
;	TDMAX	= Same.
;	TDESC	= Same.
;	TROTA	= Same.
;	TRPIX	= Same.
;	TRVAL	= Same.
;	TDELT	= Same.
; Calls       : 
;	FXADDPAR, FXPAR
; Common      : 
;	None.
; Restrictions: 
;	Warning: No checking is done of any of the parameters defining the
;	values of optional FITS keywords.
;
;	FXBHMAKE must first be called to initialize the header.
;
;	If ARRAY is of type character, then it must be of the maximum length
;	expected for this column.  If a character string array, then the
;	largest string in the array is used to determine the maximum length.
;
;	The DCOMPLEX keyword is ignored if ARRAY is not double-precision.
;	ARRAY must also have a first dimension of two representing the real and
;	imaginary parts.
;
;	The BIT and LOGICAL keywords are ignored if ARRAY is not of type byte.
;	BIT takes precedence over LOGICAL.
;
; Side effects: 
;	If the data array is multidimensional, then a TDIM keyword is added to
;	the header, unless either NO_TDIM or VARIABLE is set.
;
;	No TDIMn keywords are written out for bit arrays (format 'X'), since
;	the dimensions would refer to bits, not bytes.
;
; Category    : 
;	Data Handling, I/O, FITS, Generic.
; Prev. Hist. : 
;	William Thompson, Jan 1992.
;	W. Thompson, Feb 1992, changed from function to procedure.
;	W. Thompson, Feb 1992, modified to support variable length arrays.
; Written     : 
;	William Thompson, GSFC, January 1992.
; Modified    : 
;	Version 1, William Thompson, GSFC, 12 April 1993.
;		Incorporated into CDS library.
; Version     : 
;	Version 1, 12 April 1993.
;-
;
	ON_ERROR,2
;
;  Check the number of parameters first.
;
	IF N_PARAMS() LT 3 THEN MESSAGE,	$
		'Syntax: FXBADDCOL, INDEX, HEADER, ARRAY [, TTYPE [, COMMENT]]'
;
;  Get the next column number.
;
	INDEX = FXPAR(HEADER,'TFIELDS') + 1
;
;  Determine the data type and size of the data array.  Use this to
;  calculate the parameters needed for the binary table.
;
	S = SIZE(ARRAY)			;obtain size of array.
	TYPE = S(S(0)+1)		;type of data.
	N_ELEM = N_ELEMENTS(ARRAY)	;Number of elements
;
	CASE TYPE OF
		0:  MESSAGE,'Data parameter is not defined'
;
;  If the array is of type byte, then check to see if either the BIT or LOGICAL
;  keywords were passed.
;
		1:  BEGIN
			IF N_ELEMENTS(BIT) EQ 1 THEN BEGIN
				N_BYTES = LONG((BIT+7)/8)
				IF N_BYTES NE N_ELEM THEN MESSAGE, $
					'Number of bits does not match ' + $
					'array size.'
				N_ELEM = BIT
				TFORM = "X"
				TF_COMMENT = 'Bit array'
			END ELSE IF KEYWORD_SET(LOGICAL) THEN BEGIN
				N_BYTES = N_ELEM
				TFORM = "L"
				TF_COMMENT = 'Logical array'
			END ELSE BEGIN
				N_BYTES = N_ELEM
				TFORM = "B"
				TF_COMMENT = 'Integer*1 (byte)'
			ENDELSE
			END
;
;  If complex, then check to see if the DCOMPLEX keyword was set, and if the
;  first dimension is two.
;
		5:  BEGIN
			IF KEYWORD_SET(DCOMPLEX) THEN BEGIN
				IF  S(1) NE 2 THEN MESSAGE,	$
					'The first dimension of ARRAY ' + $
					'must be two'
				N_BYTES = 8*N_ELEM
				N_ELEM = N_ELEM / 2
				TFORM = "M"
				TF_COMMENT = 'Complex*16 (double-' +	$
					'precision complex)'
				S = [S(0)-1,S(2:*)]
			END ELSE BEGIN
				N_BYTES = 8*N_ELEM
				TFORM = "D"
				TF_COMMENT = 'Real*8 (double precision)'
			ENDELSE
			END
;
;  Note that character string arrays are considered to have an extra first
;  dimension, namely the (maximum) number of characters.
;
		7:  BEGIN
			STR_LEN = MAX(STRLEN(ARRAY))
			N_BYTES = STR_LEN*N_ELEM
			N_ELEM = N_BYTES
			TFORM = "A"
			TF_COMMENT = 'Character string'
			S = [S(0)+1, STR_LEN, S(1:*)]	;Add extra dimension
			END
;
;  All other types are straightforward.
;
		2:  BEGIN
			N_BYTES = 2*N_ELEM
			TFORM = "I"
			TF_COMMENT = 'Integer*2 (short integer)'
			END
		3:  BEGIN
			N_BYTES = 4*N_ELEM
			TFORM = "J"
			TF_COMMENT = 'Integer*4 (long integer)'
			END
		4:  BEGIN
			N_BYTES = 4*N_ELEM
			TFORM = "E"
			TF_COMMENT = 'Real*4 (floating point)'
			END
		6:  BEGIN
			N_BYTES = 8*N_ELEM
			TFORM = "C"
			TF_COMMENT = 'Complex*8 (complex)'
			END
		8:  MESSAGE,"Can't write structures to FITS files"
	ENDCASE
;
;  If the column is to contain variable length data, then the number of bytes
;  is 8, and TFORM has "1P" in the front, and "(<n_elem>)" in the back.
;
	IF KEYWORD_SET(VARIABLE) THEN BEGIN
		N_BYTES = 8
		TFORM = '1P' + TFORM + '(' + STRTRIM(N_ELEM,2) + ')'
		TF_COMMENT = TF_COMMENT + ', variable length'
;
;  Otherwise, TFORM has "<n_elem>" in the front.
;
	END ELSE TFORM = STRTRIM(N_ELEM,2) + TFORM
;
;  Update the mandatory keywords in the header.
;
	NAXIS1 = FXPAR(HEADER,'NAXIS1')
	FXADDPAR,HEADER,'NAXIS1',NAXIS1+N_BYTES
	FXADDPAR,HEADER,'TFIELDS',INDEX
;
;  Add the keyword defining this column.
;
	COL = STRTRIM(INDEX,2)		;ASCII form of column index
	FXADDPAR, HEADER, 'TFORM'+COL, TFORM, TF_COMMENT
;
;  If the TTYPE parameter has been passed, then add this keyword to the header.
;
	IF N_PARAMS() GE 4 THEN BEGIN
		If N_PARAMS() EQ 4 THEN COMMENT="Label for column "+COL
		FXADDPAR,HEADER,'TTYPE'+COL,STRUPCASE(TTYPE),COMMENT
	ENDIF
;
;  If the number of dimensions of the data array are greater than one, then add
;  the TDIM keyword.  Don't add this keyword if either the NO_TDIM, VARIABLE or
;  BIT keyword is set.
;
	IF (S(0) GT 1) AND NOT (KEYWORD_SET(NO_TDIM) OR KEYWORD_SET(BIT) OR $
			KEYWORD_SET(VARIABLE)) THEN BEGIN
		TDIM = "(" + STRTRIM(S(1),2)
		FOR I = 2,S(0) DO TDIM = TDIM + "," + STRTRIM(S(I),2)
		TDIM = TDIM + ')'
		FXADDPAR,HEADER,'TDIM'+COL,TDIM,	$
			'Array dimensions for column '+COL
	ENDIF
;
;  If the various keywords were passed, then add them to the header.
;
	IF N_ELEMENTS(TUNIT) EQ 1 THEN FXADDPAR,HEADER,'TUNIT'+COL,TUNIT, $
		'Units of column '+COL
	IF N_ELEMENTS(TSCAL) EQ 1 THEN FXADDPAR,HEADER,'TSCAL'+COL,TSCAL, $
		'Scale parameter for column '+COL
	IF N_ELEMENTS(TZERO) EQ 1 THEN FXADDPAR,HEADER,'TZERO'+COL,TZERO, $
		'Zero offset for column '+COL
	IF N_ELEMENTS(TNULL) EQ 1 THEN FXADDPAR,HEADER,'TNULL'+COL,TNULL, $
		'Null value for column '+COL
	IF N_ELEMENTS(TDISP) EQ 1 THEN FXADDPAR,HEADER,'TDISP'+COL,TDISP, $
		'Display format for column '+COL
;
	IF N_ELEMENTS(TDMIN) EQ 1 THEN FXADDPAR,HEADER,'TDMIN'+COL,TDMIN, $
		'Minimum value in column '+COL
	IF N_ELEMENTS(TDMAX) EQ 1 THEN FXADDPAR,HEADER,'TDMAX'+COL,TDMAX, $
		'Maximum value in column '+COL
	IF N_ELEMENTS(TDESC) EQ 1 THEN FXADDPAR,HEADER,'TDESC'+COL,TDESC, $
		'Axis labels for column '+COL
	IF N_ELEMENTS(TROTA) EQ 1 THEN FXADDPAR,HEADER,'TROTA'+COL,TROTA, $
		'Rotation angles for column '+COL
	IF N_ELEMENTS(TRPIX) EQ 1 THEN FXADDPAR,HEADER,'TRPIX'+COL,TRPIX, $
		'Reference pixel for column '+COL
	IF N_ELEMENTS(TRVAL) EQ 1 THEN FXADDPAR,HEADER,'TRVAL'+COL,TRVAL, $
		'Reference position for column '+COL
	IF N_ELEMENTS(TDELT) EQ 1 THEN FXADDPAR,HEADER,'TDELT'+COL,TDELT, $
		'Axis increments for column '+COL
;
	RETURN
	END

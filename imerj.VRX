/*:VRX         Main
*/
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end; else do
        call VROptions 'ImplicitNames'
        call VROptions 'NoEchoQuit'
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
    end
_VREHalt:
    _VREReturnValue = Fini()
    call VRDestroy _VREPrimaryWindow
_VRELeaveMain:
    call VRFini
exit _VREReturnValue

VRLoadSecondary:
    __vrlsWait = abbrev( 'WAIT', translate(arg(2)), 1 )
    if __vrlsWait then do
        call VRFlush
    end
    __vrlsHWnd = VRLoad( VRWindow(), VRWindowPath(), arg(1) )
    if __vrlsHWnd = '' then signal __vrlsDone
    if __vrlsWait \= 1 then signal __vrlsDone
    call VRSet __vrlsHWnd, 'WindowMode', 'Modal' 
    __vrlsTmp = __vrlsWindows.0
    if( DataType(__vrlsTmp) \= 'NUM' ) then do
        __vrlsTmp = 1
    end
    else do
        __vrlsTmp = __vrlsTmp + 1
    end
    __vrlsWindows.__vrlsTmp = VRWindow( __vrlsHWnd )
    __vrlsWindows.0 = __vrlsTmp
    do while( VRIsValidObject( VRWindow() ) = 1 )
        __vrlsEvent = VREvent()
        interpret __vrlsEvent
    end
    __vrlsTmp = __vrlsWindows.0
    __vrlsWindows.0 = __vrlsTmp - 1
    call VRWindow __vrlsWindows.__vrlsTmp 
    __vrlsHWnd = ''
__vrlsDone:
return __vrlsHWnd

/*:VRX         AdjustPos
*/
/* Determines whether or not the byte at the given position is part of a 
 * double-byte character, and (if so) where that character's actual starting 
 * position is.
 */
AdjustPos: PROCEDURE EXPOSE cwidth
    PARSE ARG flags, offset, shift

    cwidth = 0
    start  = 0
    IF flags == '' THEN RETURN 1
    IF offset < 1  THEN RETURN 1
    SELECT
        WHEN SUBSTR( flags, offset, 1 ) == 1 THEN DO
            cwidth = 2
            start  = offset
        END
        WHEN SUBSTR( flags, offset, 1 ) == 2 THEN DO
            cwidth = 2
            /* Shift = 0, move to start of previous char.
             * Shift = 1, move to start of next char.
             */
            IF shift = 0 THEN start  = offset - 1
            ELSE              start  = offset + 1
        END
        OTHERWISE DO
            cwidth = 1
            start  = offset 
        END
    END

RETURN start

/*:VRX         CharAttr
*/
/* Build a sequence of attribute flags for each byte in the text:
 *   0 = single-byte character
 *   1 = first byte of a double-byte character
 *   2 = second byte of a double-byte character
 */
CharAttr: PROCEDURE 
    PARSE ARG text, offset

    flags = ''
    dbcs  = 0
    DO i = 1 TO LENGTH( text ) 
        nextbyte = C2D( SUBSTR( text, i, 1 ))

        IF ( \dbcs ) THEN DO
            IF ( nextbyte > 128 & nextbyte < 160 ) | ( nextbyte > 223 & nextbyte < 253 ) THEN DO
                flags = flags || '1'
                dbcs  = 1
            END
            ELSE 
                flags = flags || '0'
        END
        ELSE DO
            flags = flags || '2'
            dbcs  = 0
        END
    END

RETURN flags

/*:VRX         ConvertFullwidth
*/
ConvertFullwidth: 
    PARSE ARG letter

    SELECT
        WHEN letter == 'A' THEN out = '‚`'
        WHEN letter == 'B' THEN out = '‚a'
        WHEN letter == 'C' THEN out = '‚b'
        WHEN letter == 'D' THEN out = '‚c'
        WHEN letter == 'E' THEN out = '‚d'
        WHEN letter == 'F' THEN out = '‚e'
        WHEN letter == 'G' THEN out = '‚f'
        WHEN letter == 'H' THEN out = '‚g'
        WHEN letter == 'I' THEN out = '‚h'
        WHEN letter == 'J' THEN out = '‚i'
        WHEN letter == 'K' THEN out = '‚j'
        WHEN letter == 'L' THEN out = '‚k'
        WHEN letter == 'M' THEN out = '‚l'
        WHEN letter == 'N' THEN out = '‚m'
        WHEN letter == 'O' THEN out = '‚n'
        WHEN letter == 'P' THEN out = '‚o'
        WHEN letter == 'Q' THEN out = '‚p'
        WHEN letter == 'R' THEN out = '‚q'
        WHEN letter == 'S' THEN out = '‚r'
        WHEN letter == 'T' THEN out = '‚s'
        WHEN letter == 'U' THEN out = '‚t'
        WHEN letter == 'V' THEN out = '‚u'
        WHEN letter == 'W' THEN out = '‚v'
        WHEN letter == 'X' THEN out = '‚w'
        WHEN letter == 'Y' THEN out = '‚x'
        WHEN letter == 'Z' THEN out = '‚y'
        WHEN letter == 'a' THEN out = '‚'
        WHEN letter == 'b' THEN out = '‚‚'
        WHEN letter == 'c' THEN out = '‚ƒ'
        WHEN letter == 'd' THEN out = '‚„'
        WHEN letter == 'e' THEN out = '‚…'
        WHEN letter == 'f' THEN out = '‚†'
        WHEN letter == 'g' THEN out = '‚‡'
        WHEN letter == 'h' THEN out = '‚ˆ'
        WHEN letter == 'i' THEN out = '‚‰'
        WHEN letter == 'j' THEN out = '‚Š'
        WHEN letter == 'k' THEN out = '‚‹'
        WHEN letter == 'l' THEN out = '‚Œ'
        WHEN letter == 'm' THEN out = '‚'
        WHEN letter == 'n' THEN out = '‚Ž'
        WHEN letter == 'o' THEN out = '‚'
        WHEN letter == 'p' THEN out = '‚'
        WHEN letter == 'q' THEN out = '‚‘'
        WHEN letter == 'r' THEN out = '‚’'
        WHEN letter == 's' THEN out = '‚“'
        WHEN letter == 't' THEN out = '‚”'
        WHEN letter == 'u' THEN out = '‚•'
        WHEN letter == 'v' THEN out = '‚–'
        WHEN letter == 'w' THEN out = '‚—'
        WHEN letter == 'x' THEN out = '‚˜'
        WHEN letter == 'y' THEN out = '‚™'
        WHEN letter == 'z' THEN out = '‚š'
        WHEN letter == '0' THEN out = '‚O'
        WHEN letter == '1' THEN out = '‚P'
        WHEN letter == '2' THEN out = '‚Q'
        WHEN letter == '3' THEN out = '‚R'
        WHEN letter == '4' THEN out = '‚S'
        WHEN letter == '5' THEN out = '‚T'
        WHEN letter == '6' THEN out = '‚U'
        WHEN letter == '7' THEN out = '‚V'
        WHEN letter == '8' THEN out = '‚W'
        WHEN letter == '9' THEN out = '‚X'
        WHEN letter == '.' THEN out = 'D'
        WHEN letter == ',' THEN out = 'C'
        WHEN letter == '!' THEN out = 'I'
        WHEN letter == '@' THEN out = '—'
        WHEN letter == '#' THEN out = '”'
        WHEN letter == '$' THEN out = ''
        WHEN letter == '%' THEN out = '“'
        WHEN letter == '^' THEN out = 'O'
        WHEN letter == '`' THEN out = 'e'
        WHEN letter == '&' THEN out = '•'
        WHEN letter == '*' THEN out = '–'
        WHEN letter == '(' THEN out = 'i'
        WHEN letter == ')' THEN out = 'j'
        WHEN letter == '-' THEN out = '|'
        WHEN letter == '~' THEN out = 'P'
        WHEN letter == '+' THEN out = '{'
        WHEN letter == '_' THEN out = 'Q'
        WHEN letter == '=' THEN out = ''
        WHEN letter == '[' THEN out = 'm'
        WHEN letter == ']' THEN out = 'n'
        WHEN letter == '{' THEN out = 'o'
        WHEN letter == '}' THEN out = 'p'
        WHEN letter == '\' THEN out = '_'
        WHEN letter == '/' THEN out = '^'
        WHEN letter == ':' THEN out = 'F'
        WHEN letter == ';' THEN out = 'G'
        WHEN letter == '<' THEN out = 'q'
        WHEN letter == '>' THEN out = 'r'
        WHEN letter == '?' THEN out = 'H'
        WHEN letter == "'" THEN out = 'f'
        WHEN letter == '"' THEN out = 'úW'
        WHEN letter == ' ' THEN out = '@'

        WHEN letter == '' THEN out = ''
        OTHERWISE out = letter
    END

RETURN out

/*:VRX         ConvertKana
*/
ConvertKana: 
    PARSE ARG wapuro

    IF VRGet('MI_FULLWIDTH', 'Checked') THEN DO

        IF VERIFY( LEFT( wapuro, 1 ), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') == 0 THEN 
            wapuro = TRANSLATE( wapuro )

        SELECT
        /* ideographic punctuation characters */
            WHEN wapuro == ' '                      THEN out = '@'
            WHEN wapuro == ','                      THEN out = 'A'
            WHEN wapuro == '.'                      THEN out = 'B'
            WHEN wapuro == '-'                      THEN out = '['
            WHEN wapuro == '|'                      THEN out = 'E'
            WHEN wapuro == "'"                      THEN out = 'u'
            WHEN wapuro == '"'                      THEN out = 'v'

        /* hiragana */
            WHEN wapuro == 'a'                      THEN DO 
                                                        IF smallkana == 1 THEN out = '‚Ÿ' 
                                                        ELSE                   out = '‚ ' 
                                                    END
            WHEN wapuro == 'i'                      THEN DO 
                                                        IF smallkana == 1 THEN out = '‚¡' 
                                                        ELSE                   out = '‚¢'
                                                    END
            WHEN wapuro == 'u'                      THEN DO 
                                                        IF smallkana == 1 THEN out = '‚£' 
                                                        ELSE                   out = '‚¤' 
                                                    END
            WHEN wapuro == 'e'                      THEN DO 
                                                        IF smallkana == 1 THEN out = '‚¥' 
                                                        ELSE                   out = '‚¦' 
                                                    END
            WHEN wapuro == 'o'                      THEN DO 
                                                        IF smallkana == 1 THEN out = '‚§' 
                                                        ELSE                   out = '‚¨' 
                                                    END
            WHEN wapuro == 'ka'                     THEN out = '‚©'
            WHEN wapuro == 'ki'                     THEN out = '‚«'
            WHEN wapuro == 'ku'                     THEN out = '‚­'
            WHEN wapuro == 'ke'                     THEN out = '‚¯'
            WHEN wapuro == 'ko'                     THEN out = '‚±'
            WHEN wapuro == 'ga'                     THEN out = '‚ª'
            WHEN wapuro == 'gi'                     THEN out = '‚¬'
            WHEN wapuro == 'gu'                     THEN out = '‚®'
            WHEN wapuro == 'ge'                     THEN out = '‚°'
            WHEN wapuro == 'go'                     THEN out = '‚²'
            WHEN wapuro == 'sa'                     THEN out = '‚³'
            WHEN wapuro == 'shi' | wapuro == 'si'   THEN out = '‚µ'
            WHEN wapuro == 'su'                     THEN out = '‚·'
            WHEN wapuro == 'se'                     THEN out = '‚¹'
            WHEN wapuro == 'so'                     THEN out = '‚»'
            WHEN wapuro == 'za'                     THEN out = '‚´'
            WHEN wapuro == 'ji' | wapuro == 'zi'    THEN out = '‚¶'
            WHEN wapuro == 'zu'                     THEN out = '‚¸'
            WHEN wapuro == 'ze'                     THEN out = '‚º'
            WHEN wapuro == 'zo'                     THEN out = '‚¼'
            WHEN wapuro == 'ta'                     THEN out = '‚½'
            WHEN wapuro == 'chi' | wapuro == 'ti'   THEN out = '‚¿'
            WHEN wapuro == 'tsu' | wapuro == 'tu'   THEN DO 
                                                        IF smallkana == 1 THEN out = '‚Á' 
                                                        ELSE                   out = '‚Â' 
                                                    END
            WHEN wapuro == 'te'                     THEN out = '‚Ä'
            WHEN wapuro == 'to'                     THEN out = '‚Æ'
            WHEN wapuro == 'da'                     THEN out = '‚¾'
            WHEN wapuro == 'di' | wapuro == 'dzi'   THEN out = '‚À'
            WHEN wapuro == 'du' | wapuro == 'dzu'   THEN out = '‚Ã'
            WHEN wapuro == 'de'                     THEN out = '‚Å'
            WHEN wapuro == 'do'                     THEN out = '‚Ç'
            WHEN wapuro == 'na'                     THEN out = '‚È'
            WHEN wapuro == 'ni'                     THEN out = '‚É'
            WHEN wapuro == 'nu'                     THEN out = '‚Ê'
            WHEN wapuro == 'ne'                     THEN out = '‚Ë'
            WHEN wapuro == 'no'                     THEN out = '‚Ì'
            WHEN wapuro == 'ha'                     THEN out = '‚Í'
            WHEN wapuro == 'hi'                     THEN out = '‚Ð'
            WHEN wapuro == 'fu'                     THEN out = '‚Ó'
            WHEN wapuro == 'he'                     THEN out = '‚Ö'
            WHEN wapuro == 'ho'                     THEN out = '‚Ù'
            WHEN wapuro == 'ba'                     THEN out = '‚Î'
            WHEN wapuro == 'bi'                     THEN out = '‚Ñ'
            WHEN wapuro == 'bu'                     THEN out = '‚Ô'
            WHEN wapuro == 'be'                     THEN out = '‚×'
            WHEN wapuro == 'bo'                     THEN out = '‚Ú'
            WHEN wapuro == 'pa'                     THEN out = '‚Ï'
            WHEN wapuro == 'pi'                     THEN out = '‚Ò'
            WHEN wapuro == 'pu'                     THEN out = '‚Õ'
            WHEN wapuro == 'pe'                     THEN out = '‚Ø'
            WHEN wapuro == 'po'                     THEN out = '‚Û'
            WHEN wapuro == 'ma'                     THEN out = '‚Ü'
            WHEN wapuro == 'mi'                     THEN out = '‚Ý'
            WHEN wapuro == 'mu'                     THEN out = '‚Þ'
            WHEN wapuro == 'me'                     THEN out = '‚ß'
            WHEN wapuro == 'mo'                     THEN out = '‚à'
            WHEN wapuro == 'ya'                     THEN DO 
                                                        IF smallkana == 1 THEN out = '‚á' 
                                                        ELSE                   out = '‚â'
                                                    END
            WHEN wapuro == 'yu'                     THEN DO 
                                                        IF smallkana == 1 THEN out = '‚ã' 
                                                        ELSE                   out = '‚ä'
                                                    END
            WHEN wapuro == 'yo'                     THEN DO 
                                                        IF smallkana == 1 THEN out = '‚å' 
                                                        ELSE                   out = '‚æ'
                                                    END
            WHEN wapuro == 'ra' | wapuro == 'la'    THEN out = '‚ç'
            WHEN wapuro == 'ri' | wapuro == 'li'    THEN out = '‚è'
            WHEN wapuro == 'ru' | wapuro == 'lu'    THEN out = '‚é'
            WHEN wapuro == 're' | wapuro == 'le'    THEN out = '‚ê'
            WHEN wapuro == 'ro' | wapuro == 'lo'    THEN out = '‚ë'
            WHEN wapuro == 'wa'                     THEN DO 
                                                        IF smallkana == 1 THEN out = '‚ì' 
                                                        ELSE                   out = '‚í'
                                                    END
            WHEN wapuro == 'wo'                     THEN out = '‚ð'
            WHEN wapuro == 'n'  | wapuro == 'm'     THEN out = '‚ñ'
            WHEN wapuro == 'kya'                    THEN out = '‚«‚á'
            WHEN wapuro == 'kyu'                    THEN out = '‚«‚ã'
            WHEN wapuro == 'kyo'                    THEN out = '‚«‚å'
            WHEN wapuro == 'gya'                    THEN out = '‚¬‚á'
            WHEN wapuro == 'gyu'                    THEN out = '‚«‚ã'
            WHEN wapuro == 'gyo'                    THEN out = '‚¬‚å'
            WHEN wapuro == 'sha' | wapuro == 'sya'  THEN out = '‚µ‚á'
            WHEN wapuro == 'shu' | wapuro == 'syu'  THEN out = '‚µ‚ã'
            WHEN wapuro == 'sho' | wapuro == 'syo'  THEN out = '‚µ‚å'
            WHEN wapuro == 'ja'  | wapuro == 'zya'  THEN out = '‚¶‚á'
            WHEN wapuro == 'ju'  | wapuro == 'zyu'  THEN out = '‚¶‚ã'
            WHEN wapuro == 'jo'  | wapuro == 'zyo'  THEN out = '‚¶‚å'
            WHEN wapuro == 'cha'                    THEN out = '‚¿‚á'
            WHEN wapuro == 'chu'                    THEN out = '‚¿‚ã'
            WHEN wapuro == 'cho'                    THEN out = '‚¿‚å'
            WHEN wapuro == 'nya'                    THEN out = '‚É‚á'
            WHEN wapuro == 'nyu'                    THEN out = '‚É‚ã'
            WHEN wapuro == 'nyo'                    THEN out = '‚É‚å'
            WHEN wapuro == 'hya'                    THEN out = '‚Ð‚á'
            WHEN wapuro == 'hyu'                    THEN out = '‚Ð‚ã'
            WHEN wapuro == 'hyo'                    THEN out = '‚Ð‚å'
            WHEN wapuro == 'bya'                    THEN out = '‚Ñ‚á'
            WHEN wapuro == 'byu'                    THEN out = '‚Ñ‚ã'
            WHEN wapuro == 'byo'                    THEN out = '‚Ñ‚å'
            WHEN wapuro == 'pya'                    THEN out = '‚Ò‚á'
            WHEN wapuro == 'pyu'                    THEN out = '‚Ò‚ã'
            WHEN wapuro == 'pyo'                    THEN out = '‚Ò‚å'
            WHEN wapuro == 'mya'                    THEN out = '‚Ý‚á'
            WHEN wapuro == 'myu'                    THEN out = '‚Ý‚ã'
            WHEN wapuro == 'myo'                    THEN out = '‚Ý‚å'
            WHEN wapuro == 'rya'                    THEN out = '‚è‚á'
            WHEN wapuro == 'ryu'                    THEN out = '‚è‚ã'
            WHEN wapuro == 'ryo'                    THEN out = '‚è‚å'

        /* katakana */
            WHEN wapuro == 'A'                      THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒ@' 
                                                        ELSE out = 'ƒA'
                                                    END
            WHEN wapuro == 'I'                      THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒB' 
                                                        ELSE out = 'ƒC'
                                                    END
            WHEN wapuro == 'U'                      THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒD' 
                                                        ELSE out = 'ƒE'
                                                    END
            WHEN wapuro == 'E'                      THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒF' 
                                                        ELSE out = 'ƒG'
                                                    END
            WHEN wapuro == 'O'                      THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒH' 
                                                        ELSE out = 'ƒI'
                                                    END
            WHEN wapuro == 'KA'                     THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒ•' 
                                                        ELSE out = 'ƒJ'
                                                    END
            WHEN wapuro == 'KI'                     THEN out = 'ƒL'
            WHEN wapuro == 'KU'                     THEN out = 'ƒN'
            WHEN wapuro == 'KE'                     THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒ–' 
                                                        ELSE out = 'ƒP'
                                                    END
            WHEN wapuro == 'KO'                     THEN out = 'ƒR'
            WHEN wapuro == 'GA'                     THEN out = 'ƒK'
            WHEN wapuro == 'GI'                     THEN out = 'ƒM'
            WHEN wapuro == 'GU'                     THEN out = 'ƒO'
            WHEN wapuro == 'GE'                     THEN out = 'ƒQ'
            WHEN wapuro == 'GO'                     THEN out = 'ƒS'
            WHEN wapuro == 'SA'                     THEN out = 'ƒT'
            WHEN wapuro == 'SHI' | wapuro == 'SI'   THEN out = 'ƒV'
            WHEN wapuro == 'SU'                     THEN out = 'ƒX'
            WHEN wapuro == 'SE'                     THEN out = 'ƒZ'
            WHEN wapuro == 'SO'                     THEN out = 'ƒ\'
            WHEN wapuro == 'ZA'                     THEN out = 'ƒU'
            WHEN wapuro == 'JI' | wapuro == 'ZI'    THEN out = 'ƒW'
            WHEN wapuro == 'ZU'                     THEN out = 'ƒY'
            WHEN wapuro == 'ZE'                     THEN out = 'ƒ['
            WHEN wapuro == 'ZO'                     THEN out = 'ƒ]'
            WHEN wapuro == 'TA'                     THEN out = 'ƒ^'
            WHEN wapuro == 'CHI'                    THEN out = 'ƒ`'
            WHEN wapuro == 'TSU' | wapuro == 'TU'   THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒb' 
                                                        ELSE                   out = 'ƒc'
                                                    END
            WHEN wapuro == 'TE'                     THEN out = 'ƒe'
            WHEN wapuro == 'TO'                     THEN out = 'ƒg'
            WHEN wapuro == 'DA'                     THEN out = 'ƒ_'
            WHEN wapuro == 'DZI'                    THEN out = 'ƒa'
            WHEN wapuro == 'DU' | wapuro == 'DZU'   THEN out = 'ƒd'
            WHEN wapuro == 'DE'                     THEN out = 'ƒf'
            WHEN wapuro == 'DO'                     THEN out = 'ƒh'
            WHEN wapuro == 'NA'                     THEN out = 'ƒi'
            WHEN wapuro == 'NI'                     THEN out = 'ƒj'
            WHEN wapuro == 'NU'                     THEN out = 'ƒk'
            WHEN wapuro == 'NE'                     THEN out = 'ƒl'
            WHEN wapuro == 'NO'                     THEN out = 'ƒm'
            WHEN wapuro == 'HA'                     THEN out = 'ƒn'
            WHEN wapuro == 'HI'                     THEN out = 'ƒq'
            WHEN wapuro == 'FU' | wapuro == 'HU'    THEN out = 'ƒt'
            WHEN wapuro == 'HE'                     THEN out = 'ƒw'
            WHEN wapuro == 'HO'                     THEN out = 'ƒz'
            WHEN wapuro == 'BA'                     THEN out = 'ƒo'
            WHEN wapuro == 'BI'                     THEN out = 'ƒr'
            WHEN wapuro == 'BU'                     THEN out = 'ƒu'
            WHEN wapuro == 'BE'                     THEN out = 'ƒx'
            WHEN wapuro == 'BO'                     THEN out = 'ƒ{'
            WHEN wapuro == 'PA'                     THEN out = 'ƒp'
            WHEN wapuro == 'PI'                     THEN out = 'ƒs'
            WHEN wapuro == 'PU'                     THEN out = 'ƒv'
            WHEN wapuro == 'PE'                     THEN out = 'ƒy'
            WHEN wapuro == 'PO'                     THEN out = 'ƒ|'
            WHEN wapuro == 'MA'                     THEN out = 'ƒ}'
            WHEN wapuro == 'MI'                     THEN out = 'ƒ~'
            WHEN wapuro == 'MU'                     THEN out = 'ƒ€'
            WHEN wapuro == 'ME'                     THEN out = 'ƒ'
            WHEN wapuro == 'MO'                     THEN out = 'ƒ‚'
            WHEN wapuro == 'YA'                     THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒƒ' 
                                                        ELSE                   out = 'ƒ„'
                                                    END
            WHEN wapuro == 'YU'                     THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒ…' 
                                                        ELSE                   out = 'ƒ†'
                                                    END
            WHEN wapuro == 'YO'                     THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒ‡' 
                                                        ELSE                   out = 'ƒˆ'
                                                    END
            WHEN wapuro == 'RA' | wapuro == 'LA'    THEN out = 'ƒ‰'
            WHEN wapuro == 'RI' | wapuro == 'LI'    THEN out = 'ƒŠ'
            WHEN wapuro == 'RU' | wapuro == 'LU'    THEN out = 'ƒ‹'
            WHEN wapuro == 'RE' | wapuro == 'LE'    THEN out = 'ƒŒ'
            WHEN wapuro == 'RO' | wapuro == 'LO'    THEN out = 'ƒ'
            WHEN wapuro == 'WA'                     THEN DO 
                                                        IF smallkana == 1 THEN out = 'ƒŽ' 
                                                        ELSE                   out = 'ƒ'
                                                    END
            WHEN wapuro == 'WO'                     THEN out = 'ƒ’'
            WHEN wapuro == 'N'  | wapuro == 'M'     THEN out = 'ƒ“'
            WHEN wapuro == 'KYA'                    THEN out = 'ƒLƒƒ'
            WHEN wapuro == 'KYU'                    THEN out = 'ƒLƒ…'
            WHEN wapuro == 'KYO'                    THEN out = 'ƒLƒ‡'
            WHEN wapuro == 'GYA'                    THEN out = 'ƒMƒƒ'
            WHEN wapuro == 'GYU'                    THEN out = 'ƒMƒ…'
            WHEN wapuro == 'GYO'                    THEN out = 'ƒMƒ‡'
            WHEN wapuro == 'SHA' | wapuro == 'SYA'  THEN out = 'ƒVƒƒ'
            WHEN wapuro == 'SHU' | wapuro == 'SYU'  THEN out = 'ƒVƒ…'
            WHEN wapuro == 'SHO' | wapuro == 'SYO'  THEN out = 'ƒVƒ‡'
            WHEN wapuro == 'JA'  | wapuro == 'ZYA'  THEN out = 'ƒWƒƒ'
            WHEN wapuro == 'JU'  | wapuro == 'ZYU'  THEN out = 'ƒWƒ…'
            WHEN wapuro == 'JO'  | wapuro == 'ZYO'  THEN out = 'ƒWƒ‡'
            WHEN wapuro == 'CHA'                    THEN out = 'ƒ`ƒƒ'
            WHEN wapuro == 'CHU'                    THEN out = 'ƒ`ƒ…'
            WHEN wapuro == 'CHO'                    THEN out = 'ƒ`ƒ‡'
            WHEN wapuro == 'NYA'                    THEN out = 'ƒjƒƒ'
            WHEN wapuro == 'NYU'                    THEN out = 'ƒjƒ…'
            WHEN wapuro == 'NYO'                    THEN out = 'ƒjƒ‡'
            WHEN wapuro == 'HYA'                    THEN out = 'ƒqƒƒ'
            WHEN wapuro == 'HYU'                    THEN out = 'ƒqƒ…'
            WHEN wapuro == 'HYO'                    THEN out = 'ƒqƒ‡'
            WHEN wapuro == 'BYA'                    THEN out = 'ƒrƒƒ'
            WHEN wapuro == 'BYU'                    THEN out = 'ƒrƒ…'
            WHEN wapuro == 'BYO'                    THEN out = 'ƒrƒ‡'
            WHEN wapuro == 'PYA'                    THEN out = 'ƒsƒƒ'
            WHEN wapuro == 'PYU'                    THEN out = 'ƒsƒ…'
            WHEN wapuro == 'PYO'                    THEN out = 'ƒsƒ‡'
            WHEN wapuro == 'MYA'                    THEN out = 'ƒ~ƒƒ'
            WHEN wapuro == 'MYU'                    THEN out = 'ƒ~ƒ…'
            WHEN wapuro == 'MYO'                    THEN out = 'ƒ~ƒ‡'
            WHEN wapuro == 'RYA'                    THEN out = 'ƒŠƒƒ'
            WHEN wapuro == 'RYU'                    THEN out = 'ƒŠƒ…'
            WHEN wapuro == 'RYO'                    THEN out = 'ƒŠƒ‡'

        /* special katakana forms */
            WHEN wapuro == 'KWA' THEN out = 'ƒNƒƒ'
            WHEN wapuro == 'KWO' THEN out = 'ƒNƒH'
            WHEN wapuro == 'GWA' THEN out = 'ƒOƒƒ'
            WHEN wapuro == 'SHE' THEN out = 'ƒVƒF'
            WHEN wapuro == 'JE'  THEN out = 'ƒWƒF'
            WHEN wapuro == 'CHE' THEN out = 'ƒ`ƒF'
            WHEN wapuro == 'TSA' THEN out = 'ƒcƒƒ'
            WHEN wapuro == 'TSE' THEN out = 'ƒcƒF'
            WHEN wapuro == 'TSO' THEN out = 'ƒcƒH'
            WHEN wapuro == 'TI'  THEN out = 'ƒeƒB'
            WHEN wapuro == 'DI'  THEN out = 'ƒfƒB'
            WHEN wapuro == 'DYU' THEN out = 'ƒfƒ…'
            WHEN wapuro == 'FA'  THEN out = 'ƒtƒƒ'
            WHEN wapuro == 'FI'  THEN out = 'ƒtƒB'
            WHEN wapuro == 'FE'  THEN out = 'ƒtƒF'
            WHEN wapuro == 'FO'  THEN out = 'ƒtƒH'
            WHEN wapuro == 'WI'  THEN out = 'ƒEƒB'
            WHEN wapuro == 'WE'  THEN out = 'ƒEƒF'
            WHEN wapuro == 'WO'  THEN out = 'ƒEƒH'
            WHEN wapuro == 'YE'  THEN out = 'ƒCƒF'
            WHEN wapuro == 'VA'  THEN out = 'ƒ”ƒƒ'
            WHEN wapuro == 'VI'  THEN out = 'ƒ”ƒB'
            WHEN wapuro == 'VU'  THEN out = 'ƒ”'
            WHEN wapuro == 'VE'  THEN out = 'ƒ”ƒF'
            WHEN wapuro == 'VO'  THEN out = 'ƒ”ƒH'

            WHEN wapuro == '' THEN out = ''
            OTHERWISE              out = ConvertFullwidth( wapuro )
        END
    END

    ELSE DO
        /* When fullwidth mode is off, all kana will be converted to halfwidth 
         * katakana.
         */
        wapuro = TRANSLATE( wapuro )
        SELECT
            WHEN wapuro == ','                      THEN out = '¤'
            WHEN wapuro == '.'                      THEN out = '¡'
            WHEN wapuro == '-'                      THEN out = '°'
            WHEN wapuro == '|'                      THEN out = '¥'
            WHEN wapuro == "'"                      THEN out = '¢'
            WHEN wapuro == '"'                      THEN out = '£'

            WHEN wapuro == 'A'                      THEN DO 
                                                        IF smallkana == 1 THEN out = '§'
                                                        ELSE                   out = '±'
                                                    END
            WHEN wapuro == 'I'                      THEN DO 
                                                        IF smallkana == 1 THEN out = '¨'
                                                        ELSE                   out = '²'
                                                    END
            WHEN wapuro == 'U'                      THEN DO 
                                                        IF smallkana == 1 THEN out = '©'
                                                        ELSE                   out = '³'
                                                    END
            WHEN wapuro == 'E'                      THEN DO 
                                                        IF smallkana == 1 THEN out = 'ª'
                                                        ELSE                   out = '´'
                                                    END
            WHEN wapuro == 'O'                      THEN DO 
                                                        IF smallkana == 1 THEN out = '«'
                                                        ELSE                   out = 'µ'
                                                    END
            WHEN wapuro == 'KA'                     THEN out = '¶'
            WHEN wapuro == 'KI'                     THEN out = '·'
            WHEN wapuro == 'KU'                     THEN out = '¸'
            WHEN wapuro == 'KE'                     THEN out = '¹'
            WHEN wapuro == 'KO'                     THEN out = 'º'
            WHEN wapuro == 'GA'                     THEN out = '¶Þ'
            WHEN wapuro == 'GI'                     THEN out = '·Þ'
            WHEN wapuro == 'GU'                     THEN out = '¸Þ'
            WHEN wapuro == 'GE'                     THEN out = '¹Þ'
            WHEN wapuro == 'GO'                     THEN out = 'ºÞ'
            WHEN wapuro == 'SA'                     THEN out = '»'
            WHEN wapuro == 'SHI' | wapuro == 'SI'   THEN out = '¼'
            WHEN wapuro == 'SU'                     THEN out = '½'
            WHEN wapuro == 'SE'                     THEN out = '¾'
            WHEN wapuro == 'SO'                     THEN out = '¿'
            WHEN wapuro == 'ZA'                     THEN out = '»Þ'
            WHEN wapuro == 'JI' | wapuro == 'ZI'    THEN out = '¼Þ'
            WHEN wapuro == 'ZU'                     THEN out = '½Þ'
            WHEN wapuro == 'ZE'                     THEN out = '¾Þ'
            WHEN wapuro == 'ZO'                     THEN out = '¿Þ'
            WHEN wapuro == 'TA'                     THEN out = 'À'
            WHEN wapuro == 'CHI'                    THEN out = 'Á'
            WHEN wapuro == 'TSU' | wapuro == 'TU'   THEN DO 
                                                        IF smallkana == 1 THEN out = '¯'
                                                        ELSE                   out = 'Â'
                                                    END
            WHEN wapuro == 'TE'                     THEN out = 'Ã'
            WHEN wapuro == 'TO'                     THEN out = 'Ä'
            WHEN wapuro == 'DA'                     THEN out = 'ÀÞ'
            WHEN wapuro == 'DZI'                    THEN out = 'ÁÞ'
            WHEN wapuro == 'DU' | wapuro == 'DZU'   THEN out = 'ÂÞ'
            WHEN wapuro == 'DE'                     THEN out = 'ÃÞ'
            WHEN wapuro == 'DO'                     THEN out = 'ÄÞ'
            WHEN wapuro == 'NA'                     THEN out = 'Å'
            WHEN wapuro == 'NI'                     THEN out = 'Æ'
            WHEN wapuro == 'NU'                     THEN out = 'Ç'
            WHEN wapuro == 'NE'                     THEN out = 'È'
            WHEN wapuro == 'NO'                     THEN out = 'É'
            WHEN wapuro == 'HA'                     THEN out = 'Ê'
            WHEN wapuro == 'HI'                     THEN out = 'Ë'
            WHEN wapuro == 'FU' | wapuro == 'HU'    THEN out = 'Ì'
            WHEN wapuro == 'HE'                     THEN out = 'Í'
            WHEN wapuro == 'HO'                     THEN out = 'Î'
            WHEN wapuro == 'BA'                     THEN out = 'ÊÞ'
            WHEN wapuro == 'BI'                     THEN out = 'ËÞ'
            WHEN wapuro == 'BU'                     THEN out = 'ÌÞ'
            WHEN wapuro == 'BE'                     THEN out = 'ÍÞ'
            WHEN wapuro == 'BO'                     THEN out = 'ÎÞ'
            WHEN wapuro == 'PA'                     THEN out = 'Êß'
            WHEN wapuro == 'PI'                     THEN out = 'Ëß'
            WHEN wapuro == 'PU'                     THEN out = 'Ìß'
            WHEN wapuro == 'PE'                     THEN out = 'Íß'
            WHEN wapuro == 'PO'                     THEN out = 'Îß'
            WHEN wapuro == 'MA'                     THEN out = 'Ï'
            WHEN wapuro == 'MI'                     THEN out = 'Ð'
            WHEN wapuro == 'MU'                     THEN out = 'Ñ'
            WHEN wapuro == 'ME'                     THEN out = 'Ò'
            WHEN wapuro == 'MO'                     THEN out = 'Ó'
            WHEN wapuro == 'YA'                     THEN DO 
                                                        IF smallkana == 1 THEN out = '¬'
                                                        ELSE                   out = 'Ô'
                                                    END
            WHEN wapuro == 'YU'                     THEN DO 
                                                        IF smallkana == 1 THEN out = '­'
                                                        ELSE                   out = 'Õ'
                                                    END
            WHEN wapuro == 'YO'                     THEN DO 
                                                        IF smallkana == 1 THEN out = '®'
                                                        ELSE                   out = 'Ö'
                                                    END
            WHEN wapuro == 'RA' | wapuro == 'LA'    THEN out = '×'
            WHEN wapuro == 'RI' | wapuro == 'LI'    THEN out = 'Ø'
            WHEN wapuro == 'RU' | wapuro == 'LU'    THEN out = 'Ù'
            WHEN wapuro == 'RE' | wapuro == 'LE'    THEN out = 'Ú'
            WHEN wapuro == 'RO' | wapuro == 'LO'    THEN out = 'Û'
            WHEN wapuro == 'WA'                     THEN out = 'Ü'
            WHEN wapuro == 'WO'                     THEN out = '¦'
            WHEN wapuro == 'N'  | wapuro == 'M'     THEN out = 'Ý'
            WHEN wapuro == 'KYA'                    THEN out = '·¬'
            WHEN wapuro == 'KYU'                    THEN out = '·­'
            WHEN wapuro == 'KYO'                    THEN out = '·®'
            WHEN wapuro == 'GYA'                    THEN out = '·Þ¬'
            WHEN wapuro == 'GYU'                    THEN out = '·Þ­'
            WHEN wapuro == 'GYO'                    THEN out = '·Þ®'
            WHEN wapuro == 'SHA' | wapuro == 'SYA'  THEN out = '¼¬'
            WHEN wapuro == 'SHU' | wapuro == 'SYU'  THEN out = '¼­'
            WHEN wapuro == 'SHO' | wapuro == 'SYO'  THEN out = '¼®'
            WHEN wapuro == 'JA'  | wapuro == 'ZYA'  THEN out = '¼Þ¬'
            WHEN wapuro == 'JU'  | wapuro == 'ZYU'  THEN out = '¼Þ­'
            WHEN wapuro == 'JO'  | wapuro == 'ZYO'  THEN out = '¼Þ®'
            WHEN wapuro == 'CHA'                    THEN out = 'Á¬'
            WHEN wapuro == 'CHU'                    THEN out = 'Á­'
            WHEN wapuro == 'CHO'                    THEN out = 'Á®'
            WHEN wapuro == 'NYA'                    THEN out = 'Æ¬'
            WHEN wapuro == 'NYU'                    THEN out = 'Æ­'
            WHEN wapuro == 'NYO'                    THEN out = 'Æ®'
            WHEN wapuro == 'HYA'                    THEN out = 'Ë¬'
            WHEN wapuro == 'HYU'                    THEN out = 'Ë­'
            WHEN wapuro == 'HYO'                    THEN out = 'Ë®'
            WHEN wapuro == 'BYA'                    THEN out = 'ËÞ¬'
            WHEN wapuro == 'BYU'                    THEN out = 'ËÞ­'
            WHEN wapuro == 'BYO'                    THEN out = 'ËÞ®'
            WHEN wapuro == 'PYA'                    THEN out = 'Ëß¬'
            WHEN wapuro == 'PYU'                    THEN out = 'Ëß­'
            WHEN wapuro == 'PYO'                    THEN out = 'Ëß®'
            WHEN wapuro == 'MYA'                    THEN out = 'Ð¬'
            WHEN wapuro == 'MYU'                    THEN out = 'Ð­'
            WHEN wapuro == 'MYO'                    THEN out = 'Ð®'
            WHEN wapuro == 'RYA'                    THEN out = 'Ø¬'
            WHEN wapuro == 'RYU'                    THEN out = 'Ø­'
            WHEN wapuro == 'RYO'                    THEN out = 'Ø®'
            WHEN wapuro == 'KWA'                    THEN out = '¸§'
            WHEN wapuro == 'KWO'                    THEN out = '¸«'
            WHEN wapuro == 'GWA'                    THEN out = '¸Þ§'
            WHEN wapuro == 'SHE'                    THEN out = '¸Þ«'
            WHEN wapuro == 'JE'                     THEN out = '¼Þª'
            WHEN wapuro == 'CHE'                    THEN out = 'Áª'
            WHEN wapuro == 'TSA'                    THEN out = 'Â§'
            WHEN wapuro == 'TSE'                    THEN out = 'Âª'
            WHEN wapuro == 'TSO'                    THEN out = 'Â«'
            WHEN wapuro == 'TI'                     THEN out = 'Ã¨'
            WHEN wapuro == 'DI'                     THEN out = 'ÃÞ¨'
            WHEN wapuro == 'DYU'                    THEN out = 'ÃÞ­'
            WHEN wapuro == 'FA'                     THEN out = 'Ì§'
            WHEN wapuro == 'FI'                     THEN out = 'Ì¨'
            WHEN wapuro == 'FE'                     THEN out = 'Ìª'
            WHEN wapuro == 'FO'                     THEN out = 'Ì«'
            WHEN wapuro == 'WI'                     THEN out = '³¨'
            WHEN wapuro == 'WE'                     THEN out = '³ª'
            WHEN wapuro == 'WO'                     THEN out = '³«'
            WHEN wapuro == 'YE'                     THEN out = '²ª'
            WHEN wapuro == 'VA'                     THEN out = '³Þ§'
            WHEN wapuro == 'VI'                     THEN out = '³Þ¨'
            WHEN wapuro == 'VU'                     THEN out = '³Þ'
            WHEN wapuro == 'VE'                     THEN out = '³Þª'
            WHEN wapuro == 'VO'                     THEN out = '³Þ«'
            OTHERWISE
                out = wapuro
        END
    END
    smallkana = 0

    ok = VRMethod( "MLE_INPUT", "Insert", out )

RETURN 1

/*:VRX         DoCopy
*/
DoCopy: PROCEDURE EXPOSE rxuls
    PARSE ARG cliptext

    CALL VRMethod 'Application', 'PutClipboard', cliptext
    IF rxuls THEN DO
        CALL ULSPutUnicodeClipboard cliptext, 932 
/*
        IF ULSERR \= '0' THEN SAY ULSERR 
        CALL BEEP 262, 10
        CALL BEEP 440, 10
*/
    END

RETURN

/*:VRX         DoPaste
*/
DoPaste: PROCEDURE EXPOSE rxuls

    IF rxuls THEN DO
        cliptext = ULSGetUnicodeClipboard( 932 ) 
        /* IF ULSERR \= '0' THEN SAY ULSERR */
        IF cliptext == '' THEN 
            cliptext = VRMethod('Application', 'GetClipboard')
/*
        ELSE DO
            CALL BEEP 440, 10
            CALL BEEP 262, 10
        END
*/
    END
    ELSE
        cliptext = VRMethod('Application', 'GetClipboard')

    /* Only accept the first line of clipboard text, because linebreaks play 
     * havoc with the boundary parsing logic.
     */
    cliptext = TRANSLATE( cliptext, '0d'x, '0a'x )
    PARSE VAR cliptext pastetext '0d'x .
    CALL VRMethod 'MLE_INPUT', 'Insert', pastetext 

RETURN

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:
    CALL RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
    CALL SysLoadFuncs

    /* Attempt to load RXULS library (used for Unicode clipboard support).
     */
    rxuls = 0
    CALL RxFuncAdd 'ULSLoadFuncs', 'RXULS', 'ULSLoadFuncs'
    CALL ULSLoadFuncs
    IF RxFuncQuery('ULSGetUnicodeClipboard') == 0 THEN rxuls = 1

    /* Hide the VX-REXX console window. 
     */
    CALL VRSet 'Console', 'WindowListTitle', '' 

    /* Set up the user interface defaults.
     */
    CALL LoadPrefs
    CALL UpdateStatus

    window = VRWindow()
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window

    kana  = ''
    state = 0
    smallkana = 0

RETURN

/*:VRX         LoadPrefs
*/
LoadPrefs: PROCEDURE EXPOSE settings.

    os2_ini = VALUE('USER_INI',,'OS2ENVIRONMENT')
    inipath = VRParseFilePath( os2_ini, 'DP')
    IF inipath == '' THEN inipath = SysBootDrive() || '\OS2'

    settings.!ini = inipath'\imerj.ini'
    IF STREAM( settings.!ini, 'C', 'QUERY EXISTS') == '' THEN DO
        CALL VRMethod VRWindow(), 'CenterWindow'
        RETURN
    END

    /* Load position and size settings
     */
    settings.!x      = VRGetIni('Window', 'Left',   settings.!ini, 'NoClose')
    settings.!y      = VRGetIni('Window', 'Top',    settings.!ini, 'NoClose')
    settings.!width  = VRGetIni('Window', 'Width',  settings.!ini, 'NoClose')
    settings.!height = VRGetIni('Window', 'Height', settings.!ini, 'NoClose')
    IF settings.!x      == '' THEN settings.!x      = -1
    IF settings.!y      == '' THEN settings.!y      = -1
    IF settings.!width  == '' THEN settings.!width  = 0
    IF settings.!height == '' THEN settings.!height = 0

    /* Load font and colour settings
     */
    settings.!bgclr   = VRGetIni('Style', 'Background', settings.!ini, 'NoClose')
    settings.!fgclr   = VRGetIni('Style', 'Foreground', settings.!ini, 'NoClose')
    settings.!font    = VRGetIni('Style', 'Font',       settings.!ini )
    IF settings.!bgclr == '' THEN settings.!bgclr = 'EntryField'
    IF settings.!fgclr == '' THEN settings.!fgclr = 'OutputText'
    IF settings.!font  == '' THEN settings.!font  = '10.Times New Roman MT 30'

    /*
     * Now apply the settings
     */
    IF ( settings.!width > 0 ) & ( settings.!height > 0 ) THEN DO
        CALL VRSet VRWindow(), 'Width',  settings.!width
        CALL VRSet VRWindow(), 'Height', settings.!height
    END
    IF ( settings.!x >= 0 ) & ( settings.!y >= 0 ) THEN DO
        CALL VRSet VRWindow(), 'Left', settings.!x
        CALL VRSet VRWindow(), 'Top',  settings.!y
    END
    ELSE 
        CALL VRMethod VRWindow(), 'CenterWindow'

    CALL VRSet 'MLE_INPUT', 'Font',      settings.!font
    CALL VRSet 'MLE_INPUT', 'BackColor', settings.!bgclr
    CALL VRSet 'MLE_INPUT', 'ForeColor', settings.!fgclr

RETURN

/*:VRX         MI_ABOUT_Click
*/
MI_ABOUT_Click: 
    CALL VRLoadSecondary 'SW_ABOUT', 'W'
return

/*:VRX         MI_EXIT_Click
*/
MI_EXIT_Click: 
    CALL Quit
return

/*:VRX         MI_FULLWIDTH_Click
*/
MI_FULLWIDTH_Click: 
    mode = VRGet('MI_FULLWIDTH', 'Checked')
    mode = \mode
    CALL VRSet 'MI_FULLWIDTH', 'Checked', mode
    CALL UpdateStatus
RETURN

/*:VRX         MI_ROMAJI_Click
*/
MI_ROMAJI_Click: 
    CALL ToggleConversion
    CALL UpdateStatus
RETURN

/*:VRX         MLE_INPUT_KeyPress
*/
MLE_INPUT_KeyPress: 

    /* Get the current contents, cursor position and selection attributes.
     * (1 represents the first character; the cursor position is measured
     * from the preceding character boundary.  Note that SetSel and QuerySel
     * actually start from 0, so we have to adjust by one when using either.)
     */
    inputchar  = VRGet('MLE_INPUT', 'KeyString')
    contents   = VRGet('MLE_INPUT', 'Value')
    cursor     = VRMethod('MLE_INPUT', 'QuerySel', 'cursor')  + 1
    markleft   = VRMethod('MLE_INPUT', 'QuerySel', 'minimum') + 1
    markright  = VRMethod('MLE_INPUT', 'QuerySel', 'maximum') + 1
    marklength = markright - markleft

    /* For some reason, alphabetic keyboard accelerators aren't processed
     * when CapsLock is on.  
     */
    IF inputchar == '{Ctrl}F' THEN DO
        CALL MI_FULLWIDTH_Click
        RETURN 
    END

    /* A couple of special characters that require Alt as a modifier.
     */
    IF inputchar == '{Alt}0' THEN inputchar = '~'
    IF inputchar == '{Alt}/' THEN inputchar = '\'

    /* Locate all the character boundaries (since this is variable-width text).
     */
    flags = CharAttr( contents )

    /* Now locate the "correct" cursor position (on a character boundary).
     */
    cursor = AdjustPos( flags, cursor, 0 )

    /* Here we handle control keys that change the text contents.  (The MLE 
     * would normally handle most of these itself, except that we had to make it
     * read-only in order to override the text input behaviour.  So we have to
     * handle all update actions ourselves.)
     */
    IF LEFT( inputchar, 1 ) == '{' THEN DO

        SELECT

            /* Handle cut and paste events.  
             */
            WHEN inputchar == '{Shift}{Ins}' THEN DO
                state = 0
                kana = ''
                CALL DoPaste
            END

            WHEN inputchar == '{Ctrl}{Ins}' THEN DO
                state = 0
                kana = ''

                /* Adjust text selection to match character boundaries.
                 */
                markleft  = AdjustPos( flags, markleft,  0 )
                markright = AdjustPos( flags, markright, 1 )
                IF marklength > 0 THEN 
                    marklength = markright - markleft
                IF marklength > 0 THEN  DO        
                    /* Copy selected text. 
                     */
                    cliptext  = SUBSTR( contents, markleft, marklength )
                    CALL DoCopy cliptext
                END
                ELSE 
                    CALL VRMethod 'Application', 'PutClipboard', ''

                /* Clear the key event to prevent the MLE from doing its default
                 * copy (which would erase the Unicode clipboard contents).
                 */
                CALL VRSet 'MLE_INPUT', 'KeyString', ''
            END

            WHEN inputchar == '{Shift}{Del}' THEN DO
                state = 0
                kana = ''

                /* Adjust text selection to match character boundaries.
                 */
                markleft  = AdjustPos( flags, markleft,  0 )
                markright = AdjustPos( flags, markright, 1 )
                IF marklength > 0 THEN 
                    marklength = markright - markleft
                IF marklength > 0 THEN  DO        
                    /* Cut selected text. 
                     */
                    cliptext  = SUBSTR( contents, markleft, marklength )
                    contents  = DELSTR( contents, markleft, marklength )
                    cursornew = markleft
                    CALL VRSet 'MLE_INPUT', 'Value', contents
                    CALL VRMethod 'MLE_INPUT', 'SetSel', cursornew - 1, cursornew - 1
                    CALL DoCopy cliptext
                END
                ELSE 
                    CALL VRMethod 'Application', 'PutClipboard', ''
            END

            WHEN inputchar == '{Backspace}' THEN DO
                state = 0
                kana = ''

                /* Adjust text selection to match character boundaries.
                 */
                markleft   = AdjustPos( flags, markleft,  0 )
                markright  = AdjustPos( flags, markright, 1 )
                IF marklength > 0 THEN 
                    marklength = markright - markleft
                prior  = AdjustPos( flags, cursor - 1, 0 )
                IF marklength > 0 THEN DO       
                    /* Delete selected text only.
                     */
                    contents  = DELSTR( contents, markleft, marklength )
                    cursornew = markleft
                END
                ELSE IF cursor > cwidth THEN DO 
                    /* Delete single character ahead of cursor position (unless
                     * there isn't a full character in front of it, i.e. we're
                     * at the beginning of the text).
                     */
                    contents  = DELSTR( contents, cursor - cwidth, cwidth )
                    cursornew = prior
                END
                CALL VRSet 'MLE_INPUT', 'Value', contents
                CALL VRMethod 'MLE_INPUT', 'SetSel', cursornew - 1, cursornew - 1
            END

            WHEN inputchar == '{Del}' THEN DO
                state = 0
                kana = ''

                /* Adjust text selection to match character boundaries.
                 */
                markleft   = AdjustPos( flags, markleft,  0 )
                markright  = AdjustPos( flags, markright, 1 )
                IF marklength > 0 THEN 
                    marklength = markright - markleft
                IF marklength > 0 THEN  DO        
                    /* Delete selected text. 
                     */
                    contents  = DELSTR( contents, markleft, marklength )
                    cursornew = markleft
                END
                ELSE DO
                    /* Delete single character at cursor position.
                     */
                    contents  = DELSTR( contents, cursor, cwidth )
                    cursornew = cursor
                END
                CALL VRSet 'MLE_INPUT', 'Value', contents
                CALL VRMethod 'MLE_INPUT', 'SetSel', cursornew - 1, cursornew - 1
            END

            WHEN ( inputchar == '{Enter}') | ( inputchar == '{Newline}') THEN 
                CALL ConvertKana kana

/* Disabled: allowing line breaks seems to cause weird problems.
 *              CALL VRMethod 'MLE_INPUT', 'Insert', '0D'x
 */

            OTHERWISE DO
                state = 0
                kana = ''
            END

        END
        RETURN 0

    END


    /* When entering text, move the the cursor position to the correct character
     * boundary before anything else.
     */
    CALL VRMethod 'MLE_INPUT', 'SetSel', cursor - 1, cursor - 1

    /* If we're not in romaji-to-kana conversion mode...
     */
    IF VRGet('MI_ROMAJI', 'Checked') == 0 THEN DO

        /* Handle fullwidth ASCII characters.
         */
        IF VRGet('MI_FULLWIDTH', 'Checked') THEN 
            CALL VRMethod 'MLE_INPUT', 'Insert', ConvertFullwidth( inputchar )
            
        /* Otherwise, simply output the character verbatim and return. 
         */
        ELSE 
            CALL VRMethod 'MLE_INPUT', 'Insert', inputchar
        RETURN 0
    END

    /* Now handle displayable characters.
     */
    IF ( VERIFY( inputchar, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz') > 0 ) THEN DO
        /* If it's not an alphabetic character, it can't be romaji input.  So
         * try and convert it immediately.  (Some punctuation marks do have 
         * ideographic versions.)
         */
        IF kana \= '' THEN DO
            CALL ConvertKana kana
        END
        /* IF C2X( inputchar ) == '0D' THEN SAY */
        IF ( TRANSLATE( kana ) == 'N' & inputchar == "'") THEN 
            /* (This allows use of ' to force the standalone N syllable.) */
            NOP
        ELSE 
            CALL ConvertKana inputchar
        state = 0
        kana = ''
    END
    ELSE IF state == 0 THEN DO
        /* We're not in the middle of a syllable, so start entering a new one. 
         */
        IF ( VERIFY( inputchar, 'AEIOUaeiou') == 0 ) THEN DO
            CALL ConvertKana inputchar
            kana = ''
        END
        ELSE IF TRANSLATE( inputchar ) == 'X' THEN 
            smallkana = 1
        ELSE DO
            state = 1
            kana = inputchar
        END
    END
    ELSE DO
        /* There's a syllable already in progress, so attempt to continue it.
         */
        IF inputchar == LEFT( kana, 1 ) THEN DO
            /* First, handle the case of "double" consonants.
             */
            IF TRANSLATE( kana ) == 'N' THEN DO
                /* Double N is a special case. 
                 */
                CALL ConvertKana kana
                kana = inputchar
            END
            ELSE DO
                /* Other double consonants must be indicated by prepending the
                 * "small tsu" kana mark.
                 */
                IF VRGet('MI_FULLWIDTH', 'Checked') THEN DO
                    IF VERIFY( inputchar, 'ABCDEFGHIJKLMOPQRSTUVWXYZ') == 0 THEN
                        CALL VRMethod 'MLE_INPUT', 'Insert', 'ƒb'
                    ELSE
                        CALL VRMethod 'MLE_INPUT', 'Insert', '‚Á'
                END
                ELSE
                    CALL VRMethod 'MLE_INPUT', 'Insert', '¯'
            END
        END
        ELSE DO

            /* First, if the "in progress" kana contains only N/M, and the new
             * character is not a valid second character for N- or M-, then we
             * assume we're dealing with the standalone N syllable.  So convert 
             * it and then start a new "in progress" kana using the new letter.
             */
            IF ( TRANSLATE( kana ) == 'N' | TRANSLATE( kana ) == 'M') & ( VERIFY( inputchar, 'AEIOUYaeiouy') > 0 ) THEN DO
                CALL ConvertKana kana
                IF VERIFY( inputchar, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz') == 0 THEN
                    kana = inputchar
                ELSE DO
                    kana = ''
                    state = 0
                END
            END

            /* Otherwise, if this is a valid trailing character, append it to 
             * the current "in progress" kana.
             */
            ELSE IF ( VERIFY( inputchar, 'AEIOUHYSZWaeiouhyszw') == 0 ) THEN DO
                kana = kana || inputchar
                IF ( VERIFY( inputchar, 'HYSZWhyszw') > 0 ) THEN DO
                    CALL ConvertKana kana
                    kana = ''
                    state = 0
                END
            END
        END
    END

RETURN 0

/*:VRX         PB_ABOUTOK_Click
*/
PB_ABOUTOK_Click: 
    CALL SW_ABOUT_Close
return

/*:VRX         Quit
*/
Quit:

    clip = VRMethod('Application', 'GetClipboard')
    text = VRGet('MLE_INPUT', 'Value')
    IF ( text \= '' & text \= clip ) THEN DO
        buttons.0 = 2
        buttons.1 = '~Yes' 
        buttons.2 = '~No'
        id = VRMessage('WN_MAIN',, 
                       'The current text will be lost if you close this window without copying it to the clipboard first.  Close anyway?',,
                       'Confirm Close', 'W', 'buttons.', 2 )
        IF id \= 1 THEN RETURN
    END

    CALL SavePrefs

    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window

    IF rxuls THEN CALL ULSDropFuncs

RETURN

/*:VRX         SavePrefs
*/
SavePrefs: PROCEDURE EXPOSE settings.

    bgclr = VRGet('MLE_INPUT', 'BackColor')
    fgclr = VRGet('MLE_INPUT', 'ForeColor')
    font  = VRGet('MLE_INPUT', 'Font')

    xpos   = VRGet( VRWindow(), 'Left')
    ypos   = VRGet( VRWindow(), 'Top')
    width  = VRGet( VRWindow(), 'Width')
    height = VRGet( VRWindow(), 'Height')

    CALL VRSetIni 'Window', 'Left',   xpos,   settings.!ini, 'NoClose'
    CALL VRSetIni 'Window', 'Top',    ypos,   settings.!ini, 'NoClose'
    CALL VRSetIni 'Window', 'Width',  width,  settings.!ini, 'NoClose'
    CALL VRSetIni 'Window', 'Height', height, settings.!ini, 'NoClose'

    CALL VRSetIni 'Style', 'Background', bgclr, settings.!ini, 'NoClose'
    CALL VRSetIni 'Style', 'Foreground', fgclr, settings.!ini, 'NoClose'
    CALL VRSetIni 'Style', 'Font',       font,  settings.!ini

RETURN

/*:VRX         SW_ABOUT_Close
*/
SW_ABOUT_Close: 
    call SW_ABOUT_Fini
return

/*:VRX         SW_ABOUT_Create
*/
SW_ABOUT_Create: 
    call SW_ABOUT_Init
return

/*:VRX         SW_ABOUT_Fini
*/
SW_ABOUT_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_ABOUT_Init
*/
SW_ABOUT_Init: 

    CALL VRMethod 'MLE_TERMS', 'Insert', 'This program is free software; you can redistribute it and/or modify' ,
                                         'it under the terms of the GNU General Public License as published by' ,
                                         'the Free Software Foundation; either version 2 of the License, or' ,
                                         '(at your option) any later version.'
    CALL VRMethod 'MLE_TERMS', 'Insert', '0d0a0d0a'x
    CALL VRMethod 'MLE_TERMS', 'Insert', 'This program is distributed in the hope that it will be' ,
                                         'useful, but WITHOUT ANY WARRANTY; without even the implied warranty' ,
                                         'of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU' ,
                                         'General Public License for more details.'
    CALL VRMethod 'MLE_TERMS', 'Insert', '0d0a0d0a'x
    CALL VRMethod 'MLE_TERMS', 'Insert', 'You should have received a copy of the GNU General Public' ,
                                         'License along with this program; if not, write to the Free Software' ,
                                         'Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.'
    CALL VRMethod 'MLE_TERMS', 'SetSel', 0, 0

    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         ToggleConversion
*/
ToggleConversion: 
    mode = VRGet('MI_ROMAJI', 'Checked')
    mode = \mode
    CALL VRSet 'MI_ROMAJI', 'Checked', mode
RETURN

/*:VRX         UpdateStatus
*/
UpdateStatus: 
    IF VRGet('MI_ROMAJI', 'Checked') THEN 
        modetext = 'Kana Conversion'
    ELSE
        modetext = 'ASCII/Direct Input'

    IF VRGet('MI_FULLWIDTH', 'Checked') THEN
        widthtext = 'Fullwidth'
    ELSE
        widthtext = 'Halfwidth'

    CALL VRSet 'DT_STATUS', 'Caption', modetext '-' widthtext
RETURN

/*:VRX         WN_MAIN_Close
*/
WN_MAIN_Close:
    call Quit
return


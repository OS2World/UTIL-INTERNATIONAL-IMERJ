IMERJ (IME/REXX for Japanese)

  IMERJ is a very simple input method editor for Japanese text, written in 
  VX-REXX.  It supports kana (hiragana and katakana) only - kanji conversion 
  is not available.

  IMERJ is intended primarily for use on non-Japanese OS/2 systems where no
  better method for typing Japanese is available.  Users of native Japanese 
  versions of OS/2 will probably not find it very useful, as the built-in IME 
  is considerably more sophisticated.


REQUIREMENTS

  IMERJ requires the following to run:
    - VROBJ.DLL version 2.1d or later (available on Hobbes).
    - RXULS.DLL version 0.5.0 or later (available on Hobbes or my website).
    - A Japanese font, or a Unicode font with Japanese support, if you want
      characters to display correctly.  (Times New Roman MT 30 will suffice.)
    - IMERJ has only been tested on OS/2 version 4.5 and up.  In theory, Warp 4
      with FixPak 5 or later should work (and it's possible that Warp 3 with 
      FixPak 32 may as well), but I cannot guarantee it.


USAGE

  Japanese text is generated in Shift_JIS format.  Consequently, IMERJ must be
  run under codepage 932 in order for it to be displayed correctly.  

  To run under codepage 932, make sure that 932 is listed in the CODEPAGE
  setting in CONFIG.SYS (preferably as the second one, unless you're actually
  running Japanese OS/2).  Then do a 'CHCP 932' before running IMERJ, or else
  (on later OS/2 versions) set the codepage to 932 on the 'Language' tab of the
  program object properties.

  Once IMERJ is running, type the desired text in the edit field.  When kana 
  conversion is enabled (as it is by default; see below for more information), 
  any romaji text you enter (using the so-called "wapuro" style convention for 
  romanizing Japanese) will be converted on the fly into Japanese kana.  

  Normally, lowercase romaji text will be converted into hiragana.  If the text
  (or the first character thereof) is uppercase, it will be converted into 
  katakana.  In "halfwidth" mode, however, both upper- and lowercase romaji text
  will be converted into halfwidth katakana.  In all three cases, prefixing the
  text with an upper- or lowercase 'x' will cause the small version of the kana
  to be produced, if one exists.

  To disable kana conversion, deselect the "Kana" item in the Input menu (the 
  ESC key can also be used to toggle this setting on or off).  To switch between
  fullwidth and halfwidth character modes, select the "Fullwidth" item in the 
  Input menu (or toggle it using Ctrl-F).  

  There are therefore four effective input modes, depending on the selections
  in the Input menu:
    1. Normal conversion ("Kana" and "Fullwidth" both selected).
         Whatever you enter will be converted into kana (either hiragana or
         katakana), if possible.  If the text does not correspond to any kana,
         it will be converted either to fullwidth ASCII (if possible) or, 
         failing either of those, entered verbatim.
    2. Halfwidth kana conversion ("Kana" selected, "Fullwidth" not selected).
         Whatever you enter will be converted into halfwidth katakana, if 
         possible.  If the text does not correspond to any kana, it will be
         entered verbatim.
    3. Fullwidth ASCII input ("Kana" not selected, "Fullwidth" selected).
         No kana conversion is performed.  ASCII characters will be converted
         to their fullwidth forms if they exist; other text will be entered
         verbatim.
    4. No conversion (neither "Kana" nor "Fullwidth" selected).
         Whatever you type will be entered verbatim.

  The current mode is displayed in the status line above the edit window.

  Once you've typed the text to your satisfaction, you can copy and paste it to
  wherever it's needed.  (Do note that your target application should either
  support Unicode text and clipboard data, or else be running under codepage 
  932, if you want intelligible results.)

| Note: Some special puncutation characters are converted as follows:
|       | (pipe)           --> ¥ (mid-dot kana)
|       ' (apostrophe)     --> ¢ (left ideographic quote)
|       " (quotation mark) --> £ (right ideographic quote)
| You can type the actual pipe, apostrophe, and quotation characters by
| switching to ASCII input mode.
|
| Also note that single-width tilde and backslash characters do not exist in 
| the Japanese codepage (the Japanese version of ASCII replaces them with the
| yen symbol and the overline, respective).  Furthermore, attempting to enter
| either character on a non-Japanese keyboard will have no effect.  To 
| accomodate this problem, the following key combinations are available:
|    Key Combination      Halfwidth Mode      Fullwidth Mode
|    ---------------      --------------      --------------
|       Alt + /           yen symbol          fullwidth backslash
|       Alt + 0           overline            fullwidth overline


LIMITATIONS
  - Kanji input conversion is not supported.
  - Using mouse actions to paste text is not supported.  You can use the mouse 
    to copy text, but in this case the operation will be handled by the MLE
    control directly; as a result, text will not be copied in Unicode format.
    This is a permanent limitation imposed by VX-REXX.
| - Some of the more esoteric CJK punctuation marks and graphics characters 
|   are not supported by the input conversion logic.  You can, however, use my
    "DBCSMAP" character-map program to paste such characters in.  (DBCSMAP is
    available from my website: the URL is at the bottom of this file.)
  - The edit field only operates in "insert" mode.  Overstrike mode is not 
    implemented at present.
  - The use of line breaks (Enter) in the edit field is not possible.  (I 
    experimented with supporting this, but it seems to play havoc with my
    character-boundary-detection logic.)
  - As a consequence of the above, any multi-line text pasted from the clipboard 
    is truncated at the first line break. 
  - ASCII value 0x5C is always assumed to represent the backslash (rather than 
    the yen sign) when converting to fullwidth.


BUGS

  Almost certainly some bugs exist.  Please report any you find, preferably with
  a description of how to reproduce them.  (My contact information can be found 
  on the web site listed at the end of this file.)


HISTORY

| 0.9  (2010-04-24)
|   - Small 'tsu' is now entered correctly when in halfwidth mode.
|   - The Ctrl+F keyboard shortcut should now work even with CapsLock on.
|   - Added support for additional punctuation, in particular the ideographic
|     quotation marks, and the middle-dot kana.  Some more ASCII fullwidth
|     equivalents (tilde, single-quote) are now also supported.

  0.8  (2008-09-10)
    - Pressing 'x' before entering a kana will produce the small version of
      said kana, if one exists.

  0.7  (2008-01-09)
    - Pressing Backspace or Del will cancel any partially-typed kana.
    - The "text/unicode" clipboard format is now supported (using RXULS.DLL).
      This format will be used in preference to plain text.

  0.6  (2007-12-08)
    - You can now type an apostrophe (') after N to explicitly enter the 
      standalone 'N' kana; the apostrophe in this case will not be entered.
    - Fixed a bug where N before S-, Z-, W- and Y-series kana wasn't working
      properly.
    - IMERJ now prompts for confirmation if you close the window while there
      is (uncopied) text in the edit window.

  0.5  (not released)
    - Added support for clipboard cut and paste.
    - Window size/position, colour and font settings are now saved.

  0.4  (not released)
    - Added support for halfwidth katakana.
    - Various user interface improvements.
    - Support use of 'M' for 'N' when typed immediately before a consonant.

  0.3  (not released)
    - Added support for fullwidth ASCII.

  0.2  (not released)
    - Added menubar and product information dialog.

  0.1  (not released)
    - Initial build.


LICENSE

    IMERJ (IME/REXX for Japanese)
    Copyright (C) 2008, 2010 Alex Taylor

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


AUTHOR

  Alex Taylor 
  http://www.altsan.org

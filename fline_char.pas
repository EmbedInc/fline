module fline_char;
define fline_char;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Function FLINE_CHAR (POS, CH)
*
*   Get the next character on the current line into CH, then advance the
*   position to the next character.
*
*   If there is a current character:
*
*     - The current character is returned in CH.
*
*     - The position is advanced to the next character.
*
*     - The function returns TRUE.
*
*   If the current position is at the end of a line:
*
*     - CH is set to NULL (character code 0).
*
*     - The function returns FALSE.
}
function fline_char (                  {get current character, advance to next}
  in out  pos: fline_pos_t;            {current character position, updated to next}
  out     ch: char)                    {returned character, 0 for none}
  :boolean;                            {TRUE: returning char, FALSE: end of line}
  val_param;

begin
  fline_char := true;                  {init to returning with a valid character}

  if fline_pos_eol (pos) then begin    {at end of line ?}
    ch := chr(0);                      {return NULL character}
    fline_char := false;               {indicate EOL}
    return;
    end;

  ch := pos.line_p^.str_p^.str[pos.ind]; {return the current character}
  pos.ind := pos.ind + 1;              {advance to next character on this line}
  end;

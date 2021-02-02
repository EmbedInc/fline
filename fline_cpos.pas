module fline_cpos;
define fline_cpos_init;
define fline_cpos_coll;
define fline_cpos_line;
define fline_cpos_eol;
define fline_cpos_nextline;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Subroutine FLINE_CPOS_INIT (CPOS)
*
*   Initialize the character position descriptor CPOS to default or benign
*   values.
}
procedure fline_cpos_init (            {init character position to default or benign values}
  in out  cpos: fline_cpos_t);         {character position to initialize}
  val_param;

begin
  cpos.coll_p := nil;
  cpos.line_p := nil;
  cpos.ind := 0;
  end;
{
********************************************************************************
*
*   Subroutine FLINE_CPOS_COLL (CPOS, COLL)
*
*   Set the character position CPOS to before the start of the collection of
*   lines COLL.
}
procedure fline_cpos_coll (            {set char position to start of collection}
  out     cpos: fline_cpos_t;          {updated character position}
  in var  coll: fline_coll_t);         {the collection of lines}
  val_param;

begin
  cpos.coll_p := addr(coll);
  cpos.line_p := nil;
  cpos.ind := 0;
  end;
{
********************************************************************************
*
*   Subroutine FLINE_CPOS_LINE (CPOS, LINE)
*
*   Set the character position CPOS to the start of the line LINE.
}
procedure fline_cpos_line (            {set character position to start of a line}
  in out  cpos: fline_cpos_t;          {character position to set}
  in var  line: fline_line_t);         {line to set char position to start of}
  val_param;

begin
  cpos.coll_p := line.coll_p;          {point to the collection the line is in}
  cpos.line_p := addr(line);           {set pointer to the current line}
  cpos.ind := 1;                       {to first character on the line}
  end;
{
********************************************************************************
*
*   Function FLINE_CPOS_EOL (CPOS)
*
*   Find whether the character position CPOS is at the end of a line.
}
function fline_cpos_eol (              {determine whether at end of line}
  in      cpos: fline_cpos_t)          {character position}
  :boolean;                            {at end of line, includes before start of coll}
  val_param;

begin
  fline_cpos_eol := true;              {init to at end of line}
  if cpos.line_p = nil then return;    {before start of collection ?}
  if cpos.ind <= 0 then return;        {before start is same as after end of previous}
  if cpos.ind > cpos.line_p^.str_p^.len then return; {past end of the current line ?}

  fline_cpos_eol := false;             {not at end of line}
  end;
{
********************************************************************************
*
*   Function FLINE_CPOS_NEXTLINE (CPOS)
*
*   Advance the character position CPOS to the start of the next line.  The
*   function returns TRUE on success, meaning there was a next line to go to.
}
function fline_cpos_nextline (         {advance to next line in collection of lines}
  in out  cpos: fline_cpos_t)          {character position to update}
  :boolean;                            {TRUE: advanced, not hit end of collection}
  val_param;

label
  atline;

begin
  fline_cpos_nextline := true;         {init to not hit end of collection}

  if cpos.line_p = nil then begin      {before start of the whole collection of lines ?}
    if cpos.coll_p^.first_p = nil then begin {collection is empty ?}
      fline_cpos_nextline := false;    {hit end of collection}
      return;
      end;
    cpos.line_p := cpos.coll_p^.first_p; {go to the first line}
    goto atline;
    end;

  if cpos.ind <= 0 then goto atline;   {before the line already pointing to ?}

  if cpos.line_p^.next_p = nil then begin {on last line of collection ?}
    cpos.ind := cpos.line_p^.str_p^.len + 1; {indicate past end of current line}
    fline_cpos_nextline := false;      {hit end of collection}
    return;
    end;

  cpos.line_p := cpos.line_p^.next_p;  {advance to the next line}

atline:                                {POS.LINE_P is pointing to the new line}
  cpos.ind := 1;                       {start at first character on this line}
  end;

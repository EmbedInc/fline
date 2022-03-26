module fline_cpos;
define fline_cpos_init;
define fline_cpos_coll_bef;
define fline_cpos_coll_start;
define fline_cpos_set_line_bef;
define fline_cpos_set_line_at;
define fline_cpos_set_line_aft;
define fline_cpos_eol;
define fline_cpos_nextline;
define fline_cpos_getnext_line;
define fline_cpos_getnext_str;
define fline_cpos_eof;
define fline_cpos_show;
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
  cpos.line_p := nil;
  cpos.ind := 0;
  end;
{
********************************************************************************
*
*   Subroutine FLINE_CPOS_COLL_BEF (CPOS, COLL)
*
*   Set the character position CPOS to before the start of the collection of
*   lines COLL.
}
procedure fline_cpos_coll_bef (        {set char position to before collection}
  out     cpos: fline_cpos_t;          {updated character position}
  in var  coll: fline_coll_t);         {the collection of lines}
  val_param;

begin
  cpos.line_p := coll.first_p;         {first line in collection}
  cpos.ind := 0;                       {to before start of the line}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_CPOS_COLL_START (CPOS, COLL)
*
*   Set the character position COLL to the start of the collection COLL.
}
procedure fline_cpos_coll_start (      {set char position to start of collection}
  out     cpos: fline_cpos_t;          {updated character position}
  in var  coll: fline_coll_t);         {the collection of lines}
  val_param;

begin
  cpos.line_p := coll.first_p;         {first line in collection}
  cpos.ind := 1;                       {to first char of the line}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_CPOS_SET_LINE_BEF (CPOS, LINE)
*
*   Set the character position CPOS to immediately before the start of the line
*   LINE.
}
procedure fline_cpos_set_line_bef (    {set character position to before line}
  in out  cpos: fline_cpos_t;          {character position to set}
  in var  line: fline_line_t);         {line to set position to}
  val_param;

begin
  cpos.line_p := addr(line);           {set pointer to the current line}
  cpos.ind := 0;                       {to before start of the line}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_CPOS_SET_LINE_AT (CPOS, LINE)
*
*   Set the character position CPOS to the start of line LINE.
}
procedure fline_cpos_set_line_at (     {set character position to start of line}
  in out  cpos: fline_cpos_t;          {character position to set}
  in var  line: fline_line_t);         {line to set position to}
  val_param;

begin
  cpos.line_p := addr(line);           {set pointer to the current line}
  cpos.ind := 1;                       {to first character of the line}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_CPOS_SET_LINE_AFT (CPOS, LINE)
*
*   Set the character position CPOS to immediately after the end of the line
*   LINE.
}
procedure fline_cpos_set_line_aft (    {set character position to after end of line}
  in out  cpos: fline_cpos_t;          {character position to set}
  in var  line: fline_line_t);         {line to set position to}
  val_param;

begin
  cpos.line_p := addr(line);           {set pointer to the current line}
  cpos.ind := line.str_p^.len + 1;     {to after end of line}
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
  if cpos.line_p = nil then return;    {at end of the whole collection ?}
  if cpos.ind <= 0 then return;        {before start is same as after end of previous}
  if cpos.ind > cpos.line_p^.str_p^.len then return; {past end of the current line ?}

  fline_cpos_eol := false;             {not at end of line}
  end;
{
********************************************************************************
*
*   Function FLINE_CPOS_EOF (CPOS)
*
*   Find whether the character position CPOS is after the last line in the
*   collection.
}
function fline_cpos_eof (              {determine whether at end of collection}
  in      cpos: fline_cpos_t)          {character position}
  :boolean;                            {after last line of collection}
  val_param;

begin
  fline_cpos_eof :=
    (cpos.line_p = nil) and (cpos.ind >= 1);
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
  fline_cpos_nextline := false;        {init to at end of collection}

  if cpos.line_p = nil then return;    {already at end of collection ?}
  if cpos.ind <= 0 then goto atline;   {before the line already pointing to ?}

  cpos.line_p := cpos.line_p^.next_p;  {advance to the next line}
  if cpos.line_p = nil then return;    {now hit end of collection ?}

atline:                                {POS.LINE_P is pointing to the new line}
  cpos.ind := 1;                       {to first character on this line}
  fline_cpos_nextline := true;         {indicate did advance to a new line}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_CPOS_GETNEXT_LINE (CPOS, LINE_P)
*
*   Advance to the next line in the current collection, and return LINE_P
*   pointing to it.  LINE_P is returned NIL when the end of the collection is
*   reached.
}
procedure fline_cpos_getnext_line (    {advance to next input line in coll, return line}
  in out  cpos: fline_cpos_t;          {character position, updated}
  out     line_p: fline_line_p_t);     {pointer to line, NIL if hit end of collection}
  val_param;

begin
  if not fline_cpos_nextline(cpos) then begin {advance, hit end of collection ?}
    line_p := nil;
    return;
    end;

  line_p := cpos.line_p;               {return pointer to the new line}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_CPOS_GETNEXT_STR (CPOS, STR_P)
*
*   Advance to the next line in the current collection, and return STR_P
*   pointing to its text string.  STR_P is returned NIL when the end of the
*   collection is reached.
}
procedure fline_cpos_getnext_str (     {advance to next input line in coll, return string}
  in out  cpos: fline_cpos_t;          {character position, updated}
  out     str_p: string_var_p_t);      {pointer to string, NIL if hit end of collection}
  val_param;

begin
  str_p := nil;                        {init to hit end of collection}

  if not fline_cpos_nextline(cpos) then begin {advance, hit end of collection ?}
    return;
    end;

  if cpos.line_p = nil then return;    {there is no current line ?}
  str_p := cpos.line_p^.str_p;         {return pointer to the text string}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_CPOS_SHOW (CPOS)
*
*   Show the indicated line and position within the line on standard output.
}
procedure fline_cpos_show (            {show line and pos within line to STDOUT}
  in      cpos: fline_cpos_t);         {position to show}
  val_param;

var
  name_p: string_var_p_t;              {pointer to collection name}
  lnum: sys_int_machine_t;             {line number, 0 = before start of collection}
  shline: boolean;                     {show the source line contents}
  shpnt: boolean;                      {show pointer to the specific character}
  lpos_p: fline_lpos_p_t;              {to current position in logical hierarchy}

begin
  if cpos.line_p = nil then begin      {at end of unknown collection ?}
    writeln ('-- End of data --');
    return;
    end;
{
*   Show the source line info, followed by the source line contents if
*   appropriate.
}
  shpnt := true;                       {init to show pointer to char position}
  if cpos.ind <= 0
    then begin                         {before start of line}
      write ('Before start of line ', cpos.line_p^.lnum);
      shpnt := false;                  {don't try to point to the source char}
      end
    else begin                         {in or after line}
      if cpos.ind > cpos.line_p^.str_p^.len
        then begin                     {after end of line}
          write ('After end of line ', cpos.line_p^.lnum);
          end
        else begin                     {in body of the line}
          write ('Line ', cpos.line_p^.lnum, ' column ', cpos.ind);
          end
        ;
      end
    ;
  shline := cpos.line_p^.str_p^.len > 0; {show line if it has any characters}
  shpnt := shpnt and shline;           {only show pointer if showing line}

  fline_line_name_virt (cpos.line_p^, name_p); {get name of collection to show}
  write (' in "', name_p^.str:name_p^.len, '"');
  if shline
    then begin                         {show the source line contents}
      writeln (':');
      writeln (cpos.line_p^.str_p^.str:cpos.line_p^.str_p^.len);
      end
    else begin                         {don't show the source line contents}
      writeln ('.');
      end
    ;
{
*   Show up-arrow pointing to the specific character, if appropriate.
}
  if shpnt then begin                  {show pointer to specific char in source line ?}
    if cpos.ind <= 1
      then begin                       {no leading spaces}
        writeln ('^');
        end
      else begin                       {one or more spaces before pointer}
        writeln (' ':(cpos.ind-1), '^');
        end
      ;
    end;
{
*   Show position within logical hierarchy, if hierarchy exits.
}
  lpos_p := cpos.line_p^.lpos_p;       {init pointer to next level up}
  if lpos_p <> nil then begin          {will show at least one parent level ?}
    writeln;                           {leave blank line before parent levels}
    end;
  while lpos_p <> nil do begin         {up the logical hierarchy levels}
    lnum := fline_line_lnum_virt (lpos_p^.line_p^); {get line number to show}
    fline_line_name_virt (lpos_p^.line_p^, name_p); {get name this line is within}
    writeln ('From line ', lnum, ' of "', name_p^.str:name_p^.len, '"');
    lpos_p := lpos_p^.prev_p;          {to next higher level in hierarchy}
    end;
  end;

module fline_pos;
define fline_pos_start;
define fline_pos_eol;
define fline_pos_nextline;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Subroutine FLINE_POS_START (COLL, POS)
*
*   Set the position POS to the start of the collection of lines COLL.
}
procedure fline_pos_start (            {set position to start of collection}
  in var  coll: fline_coll_t;          {the collection of lines}
  out     pos: fline_pos_t);           {returned position}
  val_param;

begin
  pos.coll_p := addr(coll);
  pos.line_p := nil;
  pos.ind := 0;
  end;
{
********************************************************************************
*
*   Function FLINE_POS_EOL (POS)
*
*   Find whether the position POS is at the end of a line.
}
function fline_pos_eol (               {determine whether at end of line}
  in      pos: fline_pos_t)            {the position within a collection of lines}
  :boolean;                            {at end of line, includes before start of coll}
  val_param;

begin
  fline_pos_eol := true;               {init to at end of line}
  if pos.line_p = nil then return;     {before start of collection ?}
  if pos.ind <= 0 then return;         {before start is same as after end of previous}
  if pos.ind > pos.line_p^.str_p^.len then return; {past end of the current line ?}

  fline_pos_eol := false;              {not at end of line}
  end;
{
********************************************************************************
*
*   Function FLINE_POS_NEXTLINE (POS)
*
*   Advance the position POS to the start of the next line.  The function
*   returns TRUE on success, meaning there was a next line to go to.
}
function fline_pos_nextline (          {advance to next line in collection of lines}
  in out  pos: fline_pos_t)            {position to update}
  :boolean;                            {TRUE: advance, not hit end of collection}
  val_param;

label
  atline;

begin
  fline_pos_nextline := true;          {init to not hit end of collection}

  if pos.line_p = nil then begin       {before start of the whole collection of lines ?}
    if pos.coll_p^.first_p = nil then begin {collection is empty ?}
      fline_pos_nextline := false;     {hit end of collection}
      return;
      end;
    pos.line_p := pos.coll_p^.first_p; {go to the first line}
    goto atline;
    end;

  if pos.ind <= 0 then goto atline;    {before the line already pointing to ?}

  if pos.line_p^.next_p = nil then begin {on last line of collection ?}
    pos.ind := pos.line_p^.str_p^.len + 1; {indicate past end of current line}
    fline_pos_nextline := false;       {hit end of collection}
    return;
    end;

  pos.line_p := pos.line_p^.next_p;    {advance to the next line}

atline:                                {POS.LINE_P is pointing to the new line}
  pos.ind := 1;                        {start at first character on this line}
  end;

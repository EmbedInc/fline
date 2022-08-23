{   Routines to set or modify the standard completion status.
}
module fline_stat;
define fline_stat_lnum_fnam;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Subroutine FLINE_STAT_LNUM_FNAM (STAT, CPOS)
*
*   Add the information about the position into a collection of lines to STAT.
*   Specifically, two parameters are added to STAT:
*
*     1 - Line number, integer.
*
*     2 - File name, string.
*
*   The parameters are added indicating the virtual position, when available.
*   When unknown, the line number is set to 0 and the file name to the empty
*   string.
}
procedure fline_stat_lnum_fnam (       {add line number and file name parms to STAT}
  in out  stat: sys_err_t;             {status to add line number and file name to}
  in      cpos: fline_cpos_t);         {position within collection of lines}
  val_param;

var
  lnum: sys_int_machine_t;             {line number}
  fnam_p: string_var_p_t;              {pointer to file name string}
  line_p: fline_line_p_t;              {points to source line}
  coll_p: fline_coll_p_t;              {points to source collection}

label
  have_parms;

begin
  lnum := 0;                           {init parameters to unknown}
  fnam_p := nil;

  line_p := cpos.line_p;               {get pointer to the source line}
  if line_p = nil then goto have_parms; {no source line information ?}

  if line_p^.virt_p <> nil then begin  {virtual position exists ?}
    coll_p := line_p^.virt_p^.coll_p;  {get pointer to virtual source collection}
    if coll_p <> nil then begin        {virtual source collection exists ?}
      lnum := line_p^.virt_p^.lnum;
      fnam_p := coll_p^.name_p;
      goto have_parms;
      end;
    end;

  coll_p := line_p^.coll_p;
  if coll_p = nil then goto have_parms; {no collection (shouldn't happen) ?}

  lnum := line_p^.lnum;                {get real line number}
  fnam_p := coll_p^.name_p;            {get real source file name}

have_parms:                            {LNUM and FNAM_P all set}
  sys_stat_parm_int (lnum, stat);      {add line number parameter}
  if fnam_p = nil
    then begin                         {no file name ?}
      sys_stat_parm_vstr (string_v(''(0)), stat);
      end
    else begin                         {file name is available}
      sys_stat_parm_vstr (fnam_p^, stat);
      end
    ;
  end;

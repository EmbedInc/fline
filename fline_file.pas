module fline_file;
define fline_file_get;
define fline_file_get_suff;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Subroutine FLINE_FILE_GET (FL, FNAM, COLL_P, STAT)
*
*   Return COLL_P pointing to the text lines collection that is the content of
*   the file FNAM.  The collection is created if it does not already exist.
}
procedure fline_file_get (             {find or create contents of a text file}
  in out  fl: fline_t;                 {FLINE library use state}
  in      fnam: univ string_var_arg_t; {file name}
  out     coll_p: fline_coll_p_t;      {returned pointer to the text lines collection}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  tnam: string_treename_t;             {full absolute pathname of the file}
  conn: file_conn_t;                   {connection to the file}
  buf: string_var8192_t;               {one line buffer}

label
  abort;

begin
  tnam.max := size_char(tnam.str);     {init local var strings}
  buf.max := size_char(buf.str);
  sys_error_none (stat);               {init to no error encountered}

  string_treename (fnam, tnam);        {make absolute pathname from file name}

  fline_coll_find_file (               {look for existing collection for this file}
    fl, tnam, coll_p);
  if coll_p <> nil then begin          {found it ?}
    return;
    end;
{
*   No collection for this file currently exists.
}
  file_open_read_text (tnam, '', conn, stat); {open the file for reading}
  if sys_error(stat) then return;

  fline_coll_new_file (fl, tnam, coll_p); {create new empty collection for this file}

  while true do begin                  {back here each new line from the file}
    file_read_text (conn, buf, stat);  {try to read new line from file}
    if file_eof(stat) then exit;       {hit end of file ?}
    if sys_error(stat) then goto abort;
    fline_line_add_end (fl, coll_p^, buf); {add this line to end of the collection}
    end;                               {back to get next line from file}

abort:                                 {skip to here on error with file open, STAT set}
  file_close (conn);                   {close the file}
  end;
{
********************************************************************************
*
*   Subroutine FLINE_FILE_GET_SUFF (FL, FNAM, SUFF, COLL_P, STAT)
*
*   Like FLINE_FILE_GET except that a list of possible file name suffixes can be
*   supplied.
}
procedure fline_file_get_suff (        {find or create contents of a text file, fnam suffixex}
  in out  fl: fline_t;                 {FLINE library use state}
  in      fnam: univ string_var_arg_t; {file name}
  in      suff: string;                {file name suffixes, blank separated}
  out     coll_p: fline_coll_p_t;      {returned pointer to the text lines collection}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  vsuff: string_var80_t;               {vstring file name suffixes list}
  conn: file_conn_t;                   {connection to the file}
  buf: string_var8192_t;               {one line buffer}

label
  leave_open;

begin
  vsuff.max := size_char(vsuff.str);   {init local var strings}
  buf.max := size_char(buf.str);

  string_vstring (vsuff, suff, size_char(suff)); {make var string suffixes list}
  if vsuff.len = 0 then begin          {no suffixes ?}
    fline_file_get (fl, fnam, coll_p, stat); {use simpler no-suffixes routine}
    return;
    end;

  file_open_read_text (fnam, suff, conn, stat); {open the file for reading}
  if sys_error(stat) then return;

  fline_coll_find_file (               {look for existing collection for this file}
    fl, conn.tnam, coll_p);
  if coll_p <> nil then goto leave_open; {found it ?}
{
*   No collection for this file currently exists.
}
  fline_coll_new_file (                {create new empty collection for this file}
    fl, conn.tnam, coll_p);

  while true do begin                  {back here each new line from the file}
    file_read_text (conn, buf, stat);  {try to read new line from file}
    if file_eof(stat) then exit;       {hit end of file ?}
    if sys_error(stat) then goto leave_open; {hard error ?}
    fline_line_add_end (fl, coll_p^, buf); {add this line to end of the collection}
    end;                               {back to get next line from file}

leave_open:                            {leave, CONN open, STAT all set}
  file_close (conn);                   {close the file}
  end;

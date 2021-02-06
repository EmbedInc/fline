module fline_file;
define fline_file_get;
define fline_file_get_suff;
%include 'fline2.ins.pas';
{
********************************************************************************
*
*   Subroutine FLINE_FILE_ADD_CONN (FL, CONN, COLL, STAT)
*
*   Add all the text lines that can be read from CONN to the end of the
*   collection COLL.  CONN will be read until end of file, but will not be
*   closed.
}
procedure fline_file_add_conn (        {add lines from open I/O connection}
  in out  fl: fline_t;                 {FLINE library use state}
  in out  conn: file_conn_t;           {I/O connection open for reading text lines}
  in out  coll: fline_coll_t;          {collection to add lines to the end of}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  buf: string_var8192_t;               {one line buffer}

begin
  buf.max := size_char(buf.str);       {init local var string}

  while true do begin                  {back here each new text line}
    file_read_text (conn, buf, stat);  {try to read another line}
    if file_eof(stat) then exit;       {hit end of file ?}
    if sys_error(stat) then return;    {hard error}
    fline_line_add_end (fl, coll, buf); {add this line to end of the collection}
    end;                               {back to get next line from file}
  end;
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

begin
  tnam.max := size_char(tnam.str);     {init local var string}
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
  fline_file_add_conn (fl, conn, coll_p^, stat); {add file lines to the collection}
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

label
  leave_open;

begin
  vsuff.max := size_char(vsuff.str);   {init local var string}

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
  fline_file_add_conn (fl, conn, coll_p^, stat); {add file lines to the collection}

leave_open:                            {leave, CONN open, STAT all set}
  file_close (conn);                   {close the file}
  end;

--
-- PKG_DOCUMENTS  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OLIVER.pkg_documents as

  procedure write_to_file(p_file_name varchar2, p_directory varchar2, p_content blob) is
    l_file utl_file.file_type;
    l_buffer raw(32000);
    l_amount binary_integer := 32000;
    l_pos integer := 1;
    --l_blob blob;
    l_blob_left number;
    l_blob_length number;
  begin
    l_blob_length := dbms_lob.getlength(p_content);
    l_blob_left   := l_blob_length;
    -- open the destination file.
    l_file := utl_file.fopen(p_directory, p_file_name, 'WB', 32760);
    -- read chunks of the blob and write them to the file
    -- until complete.
    -- if small enough for a single write
    if l_blob_length < 32760 then
      utl_file.put_raw(l_file, p_content);
      utl_file.fflush(l_file);
    else
      -- write in pieces
      l_pos := 1;
      while l_pos < l_blob_length loop
        dbms_lob.read(p_content, l_amount, l_pos, l_buffer);
        utl_file.put_raw(l_file, l_buffer);
        utl_file.fflush(l_file);
        -- set the start position for the next cut
        l_pos := l_pos + l_amount;
        -- set the end position if less than 32000 bytes
        l_blob_left := l_blob_left - l_amount;
        if l_blob_left < 32000 then
          l_amount := l_blob_left;
        end if;
      end loop;
    end if;
    utl_file.fclose(l_file);
  exception
    when others then
      -- close the file if something goes wrong.
      if utl_file.is_open(l_file) then
        utl_file.fclose(l_file);
      end if;
      raise;
  end write_to_file;

  procedure upload_doc(p_file_name varchar2, p_description varchar2) is
    l_doc_id oliver_documents_tmp.id%type;
    l_file blob;
    l_mime_type apex_application_files.mime_type%type;
    l_name apex_application_files.name%type;
    l_file_ext varchar2(255) := regexp_substr(p_file_name, '\..*$');
  begin
    -- get file from apex files
    select name, mime_type, blob_content
      into l_name, l_mime_type, l_file
      from apex_application_files
     where name = p_file_name;
    -- insert record into images table
    insert into oliver_documents_tmp (
      file_name, mime_type, description
    ) values (
      l_name, l_mime_type, p_description
    ) returning id into l_doc_id;
    -- insert file to os, use table pk as file name
    write_to_file(l_doc_id || l_file_ext, 'IMAGES', l_file);
    -- delete file from apex files when done
    delete from apex_application_files where name = p_file_name;
  end upload_doc;

  procedure test is
    l_file blob;
    l_content clob := 'This is soon to be a blob';
    l_src_offset integer := 1;
    l_dest_offset integer := 1;
    l_lang_ctx integer := dbms_lob.default_lang_ctx;
    l_warn integer;
  begin
    dbms_lob.createtemporary(l_file, false);
    dbms_lob.converttoblob(l_file, l_content, dbms_lob.getlength(l_content), l_dest_offset, l_src_offset, 1, l_lang_ctx, l_warn);
    write_to_file('testfile.txt', 'OLIVER_DOCUMENTS', l_file);
    dbms_lob.freetemporary(l_file);
  exception
    when others then
      dbms_lob.freetemporary(l_file);
      raise;
  end test;

end pkg_documents;

/


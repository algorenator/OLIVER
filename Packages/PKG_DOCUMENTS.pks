--
-- PKG_DOCUMENTS  (Package) 
--
CREATE OR REPLACE PACKAGE OLIVER.pkg_documents as
  procedure write_to_file(p_file_name varchar2, p_directory varchar2, p_content blob);
  procedure upload_doc(p_file_name varchar2, p_description varchar2);
  procedure test;
end pkg_documents;

/


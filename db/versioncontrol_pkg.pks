create or replace package versioncontrol_pkg as
/****************************************************************************
* This package contains a few functions to check version numbers of database objects
*
*
  v1.00  04-05-2017 MHO  creation
****************************************************************************/

  package_name VARCHAR2(20)  := 'versioncontrol_pkg';
  version_no   VARCHAR2(20)  := 'v1.00' ;

  function rate_version_number(
    p_version_nr in varchar2
  ) return number;

  function check_object_version (
    p_version_nr    varchar2
  , p_object_name   varchar2
  , p_object_type   varchar2
  , p_var_name      varchar2
  , p_owner         varchar2  default user
  ) return number;

end versioncontrol_pkg;
/


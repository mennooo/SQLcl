create or replace package #PACKAGE_NAME# as
/****************************************************************************
* Please replace this text with your information
*
*
  v1.00  #DATE# #INITIALS#  creation
****************************************************************************/

  package_name VARCHAR2(20)  := '#PACKAGE_NAME#';
  version_no   VARCHAR2(20)  := 'v1.00' ;

  ------------------------------------------------------------------------------
  -- function dummy
  ------------------------------------------------------------------------------
  function dummy (
    p_dummy in varchar2
  ) return number;

  ------------------------------------------------------------------------------
  -- procedure dummy
  ------------------------------------------------------------------------------
  procedure dummy (
    p_dummy in varchar2
  );

end #PACKAGE_NAME#;
/

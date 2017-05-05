create or replace package body #PACKAGE_NAME# as

  ------------------------------------------------------------------------------
  -- function dummy
  ------------------------------------------------------------------------------
  function dummy (
    p_dummy in varchar2
  ) return number
  is
  begin

    return null;

  end dummy;

  ------------------------------------------------------------------------------
  -- procedure dummy
  ------------------------------------------------------------------------------
  procedure dummy (
    p_dummy in varchar2
  )
  is
  begin

    null;

  end dummy;

end #PACKAGE_NAME#;
/

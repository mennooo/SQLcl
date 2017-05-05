
  CREATE OR REPLACE PACKAGE "ALG_APP_SETTINGS" as
/*
  v1.00 09-06-2016 mho   Creatie
  v1.01 21-04-2017 mho   App settings niet alleen voor toplevel Apex (iframes)
*/

  package_name     varchar2(20)  := 'alg_app_settings';
  package_versie   varchar2(20)  := 'v1.00' ;

  ------------------------------------------------------------------------------
  -- procedure print_settings
  ------------------------------------------------------------------------------
  procedure print_settings;

end alg_app_settings;
/


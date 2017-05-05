
  CREATE OR REPLACE PACKAGE "ALG_APEX_PLUGIN_UTILS" is

  /*

  Deze package is aangemaakt om het werken met apex plugins eenvoudiger te maken
  1.00  13-09-2016 MHO  Creatie
  1.01  09-02-2017 MHO  get_query_columns in APEX 5.1 dbms_sql.desc_tab3 gebruiken

  */

  package_name     varchar2(30)  := 'alg_apex_plugin_utils';
  package_versie   VARCHAR2(20)  := 'v1.01' ;

  subtype column_name      is varchar2(30);
  subtype column_data_type is varchar2(20);

  -- Plugins gebruiken statische kolomnamen in pl/sql render / ajax functies (plugins met query source en column mapping)
  type column_mappings is table of column_name index by column_name;

  -- Bruikbaar bij plugins met query source en column mapping
  type query_column is record (
    position    number(1)
  , data_type   column_data_type
  , value_list  apex_plugin_util.t_value_list
  );
  type query_columns is table of query_column index by column_name;

  ----------------------------------------------------------
  -- function get_query_columns
  ----------------------------------------------------------
  function get_query_columns (
    p_column_mappings in column_mappings
  , p_source          in varchar2
  , p_min_columns     in number default 2
  , p_max_columns     in number default 20
  ) return query_columns;

  ----------------------------------------------------------
  -- function get_varchar2_value
  ----------------------------------------------------------
  function get_varchar2_value (
      p_query_columns   in out nocopy query_columns
    , p_column_name     column_name
    , p_idx             number
  ) return varchar2;

  ----------------------------------------------------------
  -- function get_number_value
  ----------------------------------------------------------
  function get_number_value (
      p_query_columns   in out nocopy query_columns
    , p_column_name     column_name
    , p_idx             number
  ) return number;

  ----------------------------------------------------------
  -- function get_date_value
  ----------------------------------------------------------
  function get_date_value (
      p_query_columns   in out nocopy query_columns
    , p_column_name     column_name
    , p_idx             number
  ) return date;

  ----------------------------------------------------------
  -- function get_position_by_column_name
  ----------------------------------------------------------
  function get_position_by_column_name (
    p_columns   apex_plugin_util.t_column_list
  , p_name      varchar2
  ) return number;

end alg_apex_plugin_utils;
/


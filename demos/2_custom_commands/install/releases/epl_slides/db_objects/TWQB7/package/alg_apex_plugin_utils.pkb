
  CREATE OR REPLACE PACKAGE BODY "ALG_APEX_PLUGIN_UTILS" is

  ----------------------------------------------------------
  -- function get_static_column_name
  ----------------------------------------------------------
  function get_static_column_name (
    p_column_mappings   in column_mappings
  , p_user_column_name  in column_name
  ) return column_name
  is

    l_static_column   column_name;

  begin

    l_static_column := p_column_mappings.first;

    while l_static_column is not null loop

      if p_column_mappings(l_static_column) = p_user_column_name then
        exit;
      end if;

      l_static_column := p_column_mappings.next(l_static_column);

    end loop;

    return l_static_column;

  end get_static_column_name;

  ----------------------------------------------------------
  -- function get_query_columns
  ----------------------------------------------------------
  function get_query_columns (
    p_column_mappings in column_mappings
  , p_source          in varchar2
  , p_min_columns     in number default 2
  , p_max_columns     in number default 20
  ) return query_columns
  is

    -- table van columns van query
    l_source_columns  dbms_sql.desc_tab3;

    -- Resultaat van source query
    l_source_result   apex_plugin_util.t_column_value_list2;

    l_static_column   column_name;
    l_query_column    query_column;
    l_query_columns   query_columns;

    e_no_columns      exception;

  begin

    -- Pre checks
    if p_column_mappings.count = 0 then
      raise e_no_columns;
    end if;

    -- Vind kolommen van user query
    l_source_columns := p_apex_utils.get_columns_from_query2(
        p_query       => p_source
      , p_min_columns => p_min_columns
      , p_max_columns => p_max_columns
    );

    -- Vind per gemapte column de juiste column uit de user query

    l_static_column := p_column_mappings.first;

    while l_static_column is not null loop

      for idx in 1..l_source_columns.count loop

        if l_source_columns(idx).col_name = p_column_mappings(l_static_column) then

          -- Er is een user kolom gevonden die overeenkomt met de statische kolom
          l_query_column.position   := idx;
          l_query_column.data_type  := l_source_columns(idx).col_type;

          l_query_columns(l_static_column) := l_query_column;

        end if;

      end loop;

      l_static_column := p_column_mappings.next(l_static_column);

    end loop;

    -- Haal nu bijbehorende data op
    l_source_result := apex_plugin_util.get_data2 (
        p_sql_statement     => p_source
      , p_min_columns       => p_min_columns
      , p_max_columns       => p_max_columns
      , p_component_name    => null
    );

    -- Voeg per gemapte kolom de data toe
    for idx in 1..l_source_result.count loop

      l_static_column := get_static_column_name(
        p_column_mappings => p_column_mappings
      , p_user_column_name => l_source_result(idx).name
      );

      if l_static_column is not null then

        l_query_columns(l_static_column).value_list := l_source_result(idx).value_list;

      end if;

    end loop;

    return l_query_columns;

  exception
    when e_no_columns then
      return l_query_columns;

  end get_query_columns;

  ----------------------------------------------------------
  -- function get_varchar2_value
  ----------------------------------------------------------
  function get_varchar2_value (
      p_query_columns   in out nocopy query_columns
    , p_column_name     column_name
    , p_idx             number
  ) return varchar2
  is

    l_val   varchar2(4000);

  begin

    /*

      Soms is een varchar2 kolom gevuld met numbers

    */

    if p_query_columns(p_column_name).value_list(p_idx).varchar2_value is not null then
      l_val := p_query_columns(p_column_name).value_list(p_idx).varchar2_value;
    elsif p_query_columns(p_column_name).value_list(p_idx).number_value is not null then
      l_val := p_query_columns(p_column_name).value_list(p_idx).number_value;
    end if;

    return l_val;

  exception
    when no_data_found then
      return null;

  end get_varchar2_value;

  ----------------------------------------------------------
  -- function get_number_value
  ----------------------------------------------------------
  function get_number_value (
      p_query_columns   in out nocopy query_columns
    , p_column_name     column_name
    , p_idx             number
  ) return number
  is
  begin

    return p_query_columns(p_column_name).value_list(p_idx).number_value;

  exception
    when no_data_found then
      return null;

  end get_number_value;

  ----------------------------------------------------------
  -- function get_date_value
  ----------------------------------------------------------
  function get_date_value (
      p_query_columns   in out nocopy query_columns
    , p_column_name     column_name
    , p_idx             number
  ) return date
  is
  begin

    return p_query_columns(p_column_name).value_list(p_idx).date_value;

  exception
    when no_data_found then
      return null;

  end get_date_value;

  ----------------------------------------------------------
  -- function get_position_by_column_name
  ----------------------------------------------------------
  function get_position_by_column_name (
    p_columns   apex_plugin_util.t_column_list
  , p_name      varchar2
  ) return number 
  is
  
  begin
  
    for idx in 1..p_columns.count loop
    
      if p_columns(idx).name = p_name then
        
        return idx;
        
      end if;
    
    end loop;
  
  end get_position_by_column_name;


end alg_apex_plugin_utils;
/


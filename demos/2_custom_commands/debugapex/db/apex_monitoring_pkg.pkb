create or replace package body apex_monitoring_pkg as

  gc_message_prefix     varchar2(30) := 'apexmon_';
  gc_pageview_prefix    varchar2(30) := 'sqlcl:pageviewid=';
  
  g_current_session_id  number := v('APP_SESSION');

  ------------------------------------------------------------------------------
  -- procedure get_max_page_view_id
  ------------------------------------------------------------------------------
  function get_max_page_view_id
  return number is

    l_id number;

  begin

    select max(page_view_id) into l_id
      from apex_debug_messages
     where session_id = g_current_session_id;

    return l_id;

  end get_max_page_view_id;

  ------------------------------------------------------------------------------
  -- procedure send
  ------------------------------------------------------------------------------
  procedure send(
    p_text        in varchar2
  , p_session_id  in number
  ) is

    l_status integer;

  begin

    dbms_pipe.pack_message(p_text);

    l_status := dbms_pipe.send_message(gc_message_prefix || p_session_id);
    
    commit;

  end send;

  ------------------------------------------------------------------------------
  -- function receive
  ------------------------------------------------------------------------------
  function receive(
    p_session_id  number
  ) return varchar2
  is

    l_result  integer;
    l_text    varchar2(32767);

  begin

    l_result := dbms_pipe.receive_message(gc_message_prefix || p_session_id);

    if l_result = 0 then

      dbms_pipe.unpack_message(l_text);

    end if;

    return l_text;

  end receive;

  ------------------------------------------------------------------------------
  -- procedure enable_debug
  ------------------------------------------------------------------------------
  procedure enable_debug(
    p_session_id    number
  , p_debug_level   apex_debug.t_log_level default apex_debug.c_log_level_info
  )
  is

  begin

    apex_session.set_debug(p_session_id, p_debug_level);
    send('Waiting for output..', p_session_id);
    send(gc_pageview_prefix || get_max_page_view_id, p_session_id);
    
    
    commit;
    
  end enable_debug;

  ------------------------------------------------------------------------------
  -- procedure disable_debug
  ------------------------------------------------------------------------------
  procedure disable_debug(
    p_session_id    number
  ) is
  begin
  
    apex_session.set_debug(p_session_id, null);
    commit;
  
  end disable_debug;

  ------------------------------------------------------------------------------
  -- procedure send_debug
  ------------------------------------------------------------------------------
  procedure send_debug
  is

    cursor c_debug(b_page_view_id in number) is
      select *
        from apex_debug_messages
       where session_id = g_current_session_id
         and page_view_id = b_page_view_id
       order by message_timestamp;

    e_no_debug  exception;
    
    l_max_page_view number;    

  begin 
  
    commit;
  
    -- only when debug is enabled
    if not apex_application.g_debug then
      raise e_no_debug;
    end if;
    
    l_max_page_view := get_max_page_view_id;

    send(gc_pageview_prefix || l_max_page_view, g_current_session_id);    

    for rec in c_debug(l_max_page_view) loop
      
      send(rec.message, g_current_session_id);

    end loop;

  exception
    when e_no_debug then
      null;

  end send_debug;
  
  ------------------------------------------------------------------------------
  -- procedure init
  ------------------------------------------------------------------------------
  procedure init
  is
  begin 
  
    apex_debug.remove_session_messages(g_current_session_id);
    commit;
    
    -- A hack beacause de debug log is not written to the database until the very end
    -- Execute this as sysdba: grant execute on apex_050100.wwv_flow_debug to demo;
    apex_050100.wwv_flow_debug.configure_cache(false);

  end init; 

end apex_monitoring_pkg;
/

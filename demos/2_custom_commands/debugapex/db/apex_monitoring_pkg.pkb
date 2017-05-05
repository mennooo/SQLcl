create or replace package body apex_monitoring_pkg as

  gc_message_prefix     varchar2(30) := 'apexmon_';
  gc_collection_name    varchar2(30) := 'LAST_DEBUG_ID';
  g_session_id          varchar2(4000) := v('SESSION');

  ------------------------------------------------------------------------------
  -- procedure get_max_page_view_id
  ------------------------------------------------------------------------------
  function get_max_page_view_id
  return number is

    l_id number;

  begin

    select max(page_view_id) into l_id
      from apex_debug_messages
     where session_id = g_session_id;

    return l_id;

  end get_max_page_view_id;

  ------------------------------------------------------------------------------
  -- procedure send
  ------------------------------------------------------------------------------
  procedure send(
    p_text in varchar2
  ) is

    l_status integer;

  begin

    dbms_pipe.pack_message(p_text);

    l_status := dbms_pipe.send_message(gc_message_prefix || g_session_id);

  end send;

  ------------------------------------------------------------------------------
  -- function receive
  ------------------------------------------------------------------------------
  function receive(
    p_workspace   varchar2
  , p_session_id  number
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
  procedure enable_debug
  is

  begin

    apex_debug.enable;


  end enable_debug;

  ------------------------------------------------------------------------------
  -- procedure send_debug
  ------------------------------------------------------------------------------
  procedure send_debug
  is

    cursor c_debug(b_page_view_id in number) is
      select *
        from apex_debug_messages
       where session_id = g_session_id
         and page_view_id = b_page_view_id
       order by message_timestamp;

  begin

    for rec in c_debug(get_max_page_view_id) loop

      send(rec.message);

    end loop;

  exception
    when others then
      null;

  end send_debug;

end apex_monitoring_pkg;
/

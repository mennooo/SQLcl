
  CREATE OR REPLACE PACKAGE BODY "ALG_APP_SETTINGS" as

  ------------------------------------------------------------------------------
  -- function get_websocket_tokens
  ------------------------------------------------------------------------------
  function get_websocket_tokens
  return json_list is

    cursor c_wstk(p_sessie in alg_websocket_tokens.sessie_id%type) is
      select *
        from alg_v_websocket_tokens
       where sessie_id = p_sessie;

    l_token  json;
    l_tokens json_list  := json_list();

  begin

    for rec in c_wstk(v('APP_SESSION')) loop

      l_token := json();
      l_token.put('room', rec.room);
      l_token.put('token', rec.token);

      l_tokens.append(l_token.to_json_value);

    end loop;

    return l_tokens;

  end get_websocket_tokens;

  ------------------------------------------------------------------------------
  -- procedure print_settings
  ------------------------------------------------------------------------------
  procedure print_settings is

    l_js           varchar2(32000);
    l_settings     json := json();
    l_app_items    json := json();
    l_websockets   json := json();
    l_result       apex_plugin.t_dynamic_action_render_result;

    cursor c_items is
      select item_name
        from apex_application_items
       where application_id = v('APP_ID');

  begin



    l_websockets.put('tokens', get_websocket_tokens);
    l_websockets.put('host', p_prfl.get_char('WEBSOCKET_API_URL_EXT'));


    for rec in c_items loop
      l_app_items.put(rec.item_name, v(rec.item_name));
    end loop;

    l_settings.put('appName', v('APP_NAME'));
    l_settings.put('appGroup', v('APP_GROUP'));
    l_settings.put('sessionId', v('APP_SESSION_ID'));
    l_settings.put('relaCtxUrl', utl_url.escape(apex_page.get_url(p_application => 600, p_page => 1000)));
    l_settings.put('websockets', l_websockets);
    l_settings.put('appItems', l_app_items);
    l_settings.put('bevatRelaties', alg_gbrk.bevat_relaties(v('AI_GBRK_NR')));

    --l_js := 'window.top.twinq.settings = $.extend(window.top.twinq.settings, #SETTINGS#); window.top.$(document).trigger("twinq:settings-loaded");';
    l_js := 'twinq.settings = $.extend(twinq.settings, #SETTINGS#); $(document).trigger("twinq:settings-loaded");';

    l_js := replace(l_js,'#SETTINGS#',l_settings.to_char);

    apex_javascript.add_onload_code(l_js);

  end print_settings;

end alg_app_settings;
/


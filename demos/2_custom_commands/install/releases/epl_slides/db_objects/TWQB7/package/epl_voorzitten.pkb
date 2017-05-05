
  CREATE OR REPLACE PACKAGE BODY "EPL_VOORZITTEN" is
  /*****************************************************************************
  * versie       datum      door    wat
  * ------------ ---------- ------- ----------------------------------
  * v1.1         31-05-2016 SR      p_ind_log vervangen door p_package_naam
  * v1.01        13-02-2017 MHO     room_prefix_verg toegevoegd
  * v1.02        26-04-2017 MHO     vergaderApp + voorzitterApp: slides aangepast dus moet verversen hier aangepast worden
  *****************************************************************************/
  c_package_naam constant varchar2(30) := 'epl_voorzitten';
  c_versie       constant varchar2(15) := '1.02';

  ------------------------------------------------------------------------------
  -- procedure del_oude_sessies
  ------------------------------------------------------------------------------
  procedure del_oude_sessies (
    p_room_prefix  in alg_websockets.room
  )
  is

    cursor c_wstk (p_room_prefix in varchar2) is
      select *
        from twq_v_wstk_vapi
       where room like p_room_prefix || '%';

  begin

    delete
      from twq_v_wstk_vapi
     where room like p_room_prefix || '%'
       and sessie_id = v('APP_SESSION');

  end del_oude_sessies;

  ------------------------------------------------------------------------------
  -- function is_actieve_voorzitter
  ------------------------------------------------------------------------------
  function is_actieve_voorzitter (
    p_verg_nr in  twq_vergaderingen.nr%type
  ) return boolean
  is
  begin

    return epl_verg.get(p_verg_nr).actieve_voorzitter_gbrk_nr = epl_context.get_gbrk_nr;

  end is_actieve_voorzitter;

  ------------------------------------------------------------------------------
  -- procedure registreer_ws_sessie
  ------------------------------------------------------------------------------
  procedure registreer_ws_sessie (
    p_room          in alg_websockets.room
  , p_room_postfix  in varchar2
  ) is
    l_token   alg_websockets.token;
  begin

    del_oude_sessies(p_room);

    alg_websockets.register_session (
      p_room          => p_room || p_room_postfix
    -- out
    , p_token         => l_token
    );

  end registreer_ws_sessie;

  ------------------------------------------------------------------------------
  -- procedure registreer_ws_sessie_bslv
  ------------------------------------------------------------------------------
  procedure registreer_ws_sessie_bslv (
    p_bslv_nr   in twq_besluitvoorstellen.nr%type
  ) is

  begin

    registreer_ws_sessie (
      p_room          => gc_ws_room_prefix_bslv
    , p_room_postfix  => p_bslv_nr
    );

  end registreer_ws_sessie_bslv;

  ------------------------------------------------------------------------------
  -- procedure registreer_ws_sessie_verg
  ------------------------------------------------------------------------------
  procedure registreer_ws_sessie_verg (
    p_verg_nr   in twq_vergaderingen.nr%type
  ) is

  begin

    registreer_ws_sessie (
      p_room          => gc_ws_room_prefix_verg
    , p_room_postfix  => p_verg_nr
    );

  end registreer_ws_sessie_verg;

  ------------------------------------------------------------------------------
  -- procedure volg_voorzitter
  ------------------------------------------------------------------------------
  procedure volg_voorzitter (
    p_verg_nr in twq_vergaderingen.nr%type
  , p_notl_nr in twq_notulen.nr%type
  ) is

    l_agnd_nr  twq_agendas.nr%type;

    l_data     json := json();

    e_geen_actieve_voorzitter   exception;

  begin

    if not is_actieve_voorzitter(p_verg_nr) then
      raise e_geen_actieve_voorzitter;
    end if;

    select agnd_nr into l_agnd_nr
      from twq_v_notl_vapi
     where nr = p_notl_nr;

    l_data.put('itemName', 'P2000_AGND_NR');
    l_data.put('itemValue', l_agnd_nr);
    l_data.put('slideType', 'agendapunt');

    alg_websockets.emit_to_room(
      p_room  => epl_vergaderen.gc_ws_room_prefix_verg || p_verg_nr
    , p_event => 'twinq:volgvoorzitter'
    , p_data  => l_data.to_char
    );

  exception
    when e_geen_actieve_voorzitter then
      null; -- doe niets

  end volg_voorzitter;

  ------------------------------------------------------------------------------
  -- procedure volg_voorzitter
  ------------------------------------------------------------------------------
  procedure volg_voorzitter (
    p_verg_nr in twq_vergaderingen.nr%type
  , p_bslv_nr in twq_besluitvoorstellen.nr%type
  ) is

    l_agnd_nr  twq_agendas.nr%type;

    l_data     json := json();

    e_geen_actieve_voorzitter   exception;

  begin

    if not is_actieve_voorzitter(p_verg_nr) then
      raise e_geen_actieve_voorzitter;
    end if;

    l_data.put('itemName', 'P2000_BSLV_NR');
    l_data.put('itemValue', p_bslv_nr);
    l_data.put('slideType', 'besluitvoorstel');

    alg_websockets.emit_to_room(
      p_room  => epl_vergaderen.gc_ws_room_prefix_verg || p_verg_nr
    , p_event => 'twinq:volgvoorzitter'
    , p_data  => l_data.to_char
    );

  exception
    when e_geen_actieve_voorzitter then
      null; --

  end volg_voorzitter;

  ------------------------------------------------------------------------------
  -- procedure volg_voorzitter_naar_finish
  ------------------------------------------------------------------------------
  procedure volg_voorzitter_naar_finish (
    p_verg_nr in twq_vergaderingen.nr%type
  ) is

    l_agnd_nr  twq_agendas.nr%type;

    l_data     json := json();

    e_geen_actieve_voorzitter   exception;

  begin

    if not is_actieve_voorzitter(p_verg_nr) then
      raise e_geen_actieve_voorzitter;
    end if;

    l_data.put('itemName', 'finish');
    l_data.put('itemValue', 'finish');

    alg_websockets.emit_to_room(
      p_room  => epl_vergaderen.gc_ws_room_prefix_verg || p_verg_nr
    , p_event => 'twinq:volgvoorzitter'
    , p_data  => l_data.to_char
    );

  exception
    when e_geen_actieve_voorzitter then
      null; --

  end volg_voorzitter_naar_finish;

  ------------------------------------------------------------------------------
  -- procedure ververs_agenda
  ------------------------------------------------------------------------------
  procedure ververs_agenda (
    p_verg_nr in twq_vergaderingen.nr%type
  , p_oorzaak in varchar2
  ) is

    l_data     json := json();

  begin

    l_data.put('oorzaak', p_oorzaak);

    alg_websockets.emit_to_room(
      p_room  => epl_vergaderen.gc_ws_room_prefix_verg || p_verg_nr
    , p_event => 'twinq:verversagenda'
    , p_data  => l_data.to_char
    );

  end ververs_agenda;

  ------------------------------------------------------------------------------
  -- procedure ververs_besluitvoorstel
  ------------------------------------------------------------------------------
  procedure ververs_besluitvoorstel (
    p_verg_nr in twq_vergaderingen.nr%type
  , p_bslv_nr in twq_besluitvoorstellen.nr%type
  , p_oorzaak in varchar2
  ) is

    l_data     json := json();

  begin

    l_data.put('oorzaak', p_oorzaak);
    l_data.put('id', 'BSLV' || p_bslv_nr);

    alg_websockets.emit_to_room(
      p_room  => epl_vergaderen.gc_ws_room_prefix_verg || p_verg_nr
    , p_event => 'twinq:verversbesluitvoorstel'
    , p_data  => l_data.to_char
    );

  end ververs_besluitvoorstel;

  ------------------------------------------------------------------------------
  -- function room_prefix_verg
  ------------------------------------------------------------------------------
  function room_prefix_verg
  return alg_websockets.room
  is
  begin
    return gc_ws_room_prefix_verg;
  end room_prefix_verg;


  ------------------------------------------------------------------------------
  -- procedure maak_voorzitter_actief
  ------------------------------------------------------------------------------
  procedure maak_voorzitter_actief (
    p_verg_nr in  twq_vergaderingen.nr%type
  , p_gbrk_nr in  twq_gebruikers.nr%type
  ) is
  begin

    update twq_v_verg_vapi
       set actieve_voorzitter_gbrk_nr = p_gbrk_nr
     where nr = p_verg_nr;

    -- Indien je iemand anders voorzitter maakt, dan die gebruiker daarover informeren
    if tpl_context.get_gbrk_nr <> p_gbrk_nr then

      alg_websockets.emit_to_gbrk(
        p_gbrk_nr => p_gbrk_nr
      , p_event   => 'twinq:informeeranderevoorzitter'
      );

    end if;


  end maak_voorzitter_actief;


  ------------------------------------------------------------------------------
  -- procedure reset_actieve_voorzitter
  ------------------------------------------------------------------------------
  procedure reset_actieve_voorzitter (
    p_verg_nr in  twq_vergaderingen.nr%type
 -- , p_gbrk_nr in  twq_gebruikers.nr%type
  ) is

  begin

    /*

      Wanneer een sessie niet meer actief is dan ook de tabel bijwerken

    */

    update twq_v_verg_vapi verg
       set verg.actieve_voorzitter_gbrk_nr = null
     where verg.nr = p_verg_nr
       and not exists (select 1
                         from table(alg_websockets.get_users_in_room(p_room => gc_ws_room_prefix_verg || p_verg_nr)) wstk
                        where wstk.gbrk_nr = verg.actieve_voorzitter_gbrk_nr);

  end reset_actieve_voorzitter;



end epl_voorzitten;
/



  CREATE OR REPLACE PACKAGE "EPL_VOORZITTEN" is

  gc_ws_room_prefix_bslv  constant alg_websockets.room := 'voorzitten:bslv:';
  gc_ws_room_prefix_verg  constant alg_websockets.room := 'voorzitten:verg:';

  ------------------------------------------------------------------------------
  -- procedure registreer_ws_sessie_bslv
  ------------------------------------------------------------------------------
  procedure registreer_ws_sessie_bslv (
    p_bslv_nr   in twq_besluitvoorstellen.nr%type
  );

  ------------------------------------------------------------------------------
  -- procedure registreer_ws_sessie_verg
  ------------------------------------------------------------------------------
  procedure registreer_ws_sessie_verg (
    p_verg_nr   in twq_vergaderingen.nr%type
  );

  ------------------------------------------------------------------------------
  -- procedure volg_voorzitter
  ------------------------------------------------------------------------------
  procedure volg_voorzitter (
    p_verg_nr in twq_vergaderingen.nr%type
  , p_notl_nr in twq_notulen.nr%type
  );

  ------------------------------------------------------------------------------
  -- procedure volg_voorzitter
  ------------------------------------------------------------------------------
  procedure volg_voorzitter (
    p_verg_nr in twq_vergaderingen.nr%type
  , p_bslv_nr in twq_besluitvoorstellen.nr%type
  );

  ------------------------------------------------------------------------------
  -- procedure volg_voorzitter_naar_finish
  ------------------------------------------------------------------------------
  procedure volg_voorzitter_naar_finish (
    p_verg_nr in twq_vergaderingen.nr%type
  );

  ------------------------------------------------------------------------------
  -- procedure ververs_agenda
  ------------------------------------------------------------------------------
  procedure ververs_agenda (
    p_verg_nr in twq_vergaderingen.nr%type
  , p_oorzaak in varchar2
  );

  ------------------------------------------------------------------------------
  -- procedure ververs_besluitvoorstel
  ------------------------------------------------------------------------------
  procedure ververs_besluitvoorstel (
    p_verg_nr in twq_vergaderingen.nr%type
  , p_bslv_nr in twq_besluitvoorstellen.nr%type
  , p_oorzaak in varchar2
  );

  ------------------------------------------------------------------------------
  -- function room_prefix_verg
  ------------------------------------------------------------------------------
  function room_prefix_verg
  return alg_websockets.room;


  ------------------------------------------------------------------------------
  -- procedure maak_voorzitter_actief
  ------------------------------------------------------------------------------
  procedure maak_voorzitter_actief (
    p_verg_nr in  twq_vergaderingen.nr%type
  , p_gbrk_nr in  twq_gebruikers.nr%type
  );


  ------------------------------------------------------------------------------
  -- procedure reset_actieve_voorzitter
  ------------------------------------------------------------------------------
  procedure reset_actieve_voorzitter (
    p_verg_nr in  twq_vergaderingen.nr%type
 -- , p_gbrk_nr in  twq_gebruikers.nr%type
  );

end epl_voorzitten;
/


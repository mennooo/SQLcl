
  CREATE OR REPLACE PACKAGE BODY "EPL_STEM" is
  /*****************************************************************************
  * versie       datum      door    wat
  * ------------ ---------- ------- ----------------------------------
  * 1.00         08-06-2016 mho package aangemaakt
  * 1.01         23-02-2017 mho verstuur_samenvatting: code aangesterd
  * 1.02         10-04-2017 mho stem_per_acclamatie verhuisd naar epl_bslv
  * 1.03         21-04-2017 mho update_voorzitter_chart: andere APEX pagina
  *****************************************************************************/
  c_package_naam constant varchar2(30) := 'epl_stem';
  c_versie       constant varchar2(15) := '1.03';
  g_ind_log      boolean;dfs

  --------------------------------------------------------------
  -- function is_stemgerechtigd
  --------------------------------------------------------------
  function is_stemgerechtigd(
    p_sopt_nr   in twq_stemopties.nr%type
  , p_rela_nr   in twq_relaties.nr%type
  ) return boolean is

    l_vves_nr   twq_verenigingen.nr%type;

  begin

    -- Haal de vve op via het sopt_nr
    select verg.vves_nr into l_vves_nr
      from twq_v_sopt_vapi sopt
      join twq_v_bslv_vapi bslv
        on bslv.nr = sopt.bslv_nr
      join twq_v_agnd_vapi agnd
        on agnd.nr = bslv.agnd_nr
      join twq_v_verg_vapi verg
        on verg.nr = agnd.verg_nr
     where sopt.nr = p_sopt_nr;

    -- Bepaal of gbrk een eigenaar is in de vve
    return epl_vves.is_eigenaar(l_vves_nr, p_rela_nr);

  end is_stemgerechtigd;


  --------------------------------------------------------------
  -- function get_via_stmr_nr
  --------------------------------------------------------------
  function get_via_stmr_nr (
    p_stmr_nr twq_stemmen.stmr_nr%type
  ) return stem_rec
  is

    l_rec stem_rec;

  begin

    select * into l_rec
      from twq_v_stem_vapi
     where stmr_nr = p_stmr_nr;

    return l_rec;

  end get_via_stmr_nr;

  --------------------------------------------------------------
  -- procedure update_voorzitter_chart
  --------------------------------------------------------------
  procedure update_voorzitter_chart (
    p_stem_nr   in twq_stemmen.nr%type
  ) is

    l_verg_nr       twq_vergaderingen.nr%type;
    l_bslv_nr       twq_besluitvoorstellen.nr%type;
    l_chart_data    chart_data;

  begin

    /*

      We gaan een bericht via websockets naar de (eventuele) voorzitter verzenden

      Omdat we niet zeker weten wie voorzitter is doen verzenden we het bericht naar:
      iedereen in de room van de voorzitterapp die deze vergadering heeft gekozen.

    */

    select agnd.verg_nr, bslv.nr into l_verg_nr, l_bslv_nr
      from twq_v_stem_vapi stem
      join twq_v_sopt_vapi sopt
        on coalesce(stem.sopt_nr_definitief, stem.sopt_nr_voorlopig) = sopt.nr
      join twq_v_bslv_vapi bslv
        on bslv.nr = sopt.bslv_nr
      join twq_v_agnd_vapi agnd
        on agnd.nr = bslv.agnd_nr
     where stem.nr = p_stem_nr;

    l_chart_data := epl_bslv.get_chart_data(l_verg_nr, l_bslv_nr);

    -- Voor voorzitten & notuleren
    alg_websockets.emit_to_room(
      p_room  => epl_voorzitten.gc_ws_room_prefix_bslv || l_bslv_nr
    , p_event => 'twinq:p1200:updatechart'
    , p_data  => l_chart_data
    );

    -- Voor alleen voorzitten
    alg_websockets.emit_to_room(
      p_room  => epl_voorzitten.gc_ws_room_prefix_bslv || l_bslv_nr
    , p_event => 'twinq:p4001:updatechart'
    , p_data  => l_chart_data
    );

  end update_voorzitter_chart;

  --------------------------------------------------------------
  -- procedure breng_voorlopige_stem_uit
  --------------------------------------------------------------
  procedure breng_voorlopige_stem_uit (
    p_sopt_nr             in twq_stemopties.nr%type
  , p_rela_nr             in twq_relaties.nr%type
  , p_update_vrzt_chart   in boolean default true
  ) is

    l_stem_nr           twq_stemmen.nr%type;
    l_stmr_nr           twq_stemmen.stmr_nr%type;
    l_bslv_nr           twq_besluitvoorstellen.nr%type;
    l_bslv_rec          epl_bslv.bslv_rec_t;
    l_aantal_stemmen    twq_stemmen.aantal_stemmen%type;

    e_niet_stemgerechtigd exception;
    e_stemming_gesloten   exception;

  begin

    if not is_stemgerechtigd(p_sopt_nr, p_rela_nr) then
      raise e_niet_stemgerechtigd;
    end if;

    l_bslv_nr := epl_sopt.get(p_sopt_nr).bslv_nr;

    l_bslv_rec := epl_bslv.get(l_bslv_nr);

    if p_bslv.is_gesloten(p_datum_gesloten => l_bslv_rec.datum_gesloten) then
      raise e_stemming_gesloten;
    end if;

    -- De gebruiker die een stem wil uitbrengen moet bekend zijn als stemmer
    epl_stmr.registreer_stemmer(
        p_rela_nr           => p_rela_nr
      , p_bslv_nr           => l_bslv_nr
      -- out
      , p_nr                => l_stmr_nr
      , p_aantal_stemmen    => l_aantal_stemmen
    );

    p_stem.leg_stem_vast (
      p_stmr_nr             => l_stmr_nr
    , p_sopt_nr_voorlopig   => p_sopt_nr
    , p_aantal_stemmen      => l_aantal_stemmen
      -- out
    , p_nr                  => l_stem_nr
    );

    if p_update_vrzt_chart then

      update_voorzitter_chart(l_stem_nr);

    end if;

  exception
    when e_niet_stemgerechtigd then
      alg_error.toon_melding(p_package_naam => c_package_naam, p_code => 'EPL-00004');
    when e_stemming_gesloten then
      alg_error.toon_melding(p_package_naam => c_package_naam, p_code => 'EPL-00005');


  end breng_voorlopige_stem_uit;

  --------------------------------------------------------------
  -- procedure breng_voorlopige_stemmen_uit
  --------------------------------------------------------------
  procedure breng_voorlopige_stemmen_uit (
    p_sopt_nr   in twq_stemopties.nr%type
  , p_rela_nrs  in varchar2
  ) is

    l_rela_nrs  apex_application_global.vc_arr2;

  begin

    l_rela_nrs := apex_util.string_to_table(p_rela_nrs);

    for idx in 1..l_rela_nrs.count loop

      breng_voorlopige_stem_uit(
        p_sopt_nr   => p_sopt_nr
      , p_rela_nr   => l_rela_nrs(idx)
      );

    end loop;

  end breng_voorlopige_stemmen_uit;

  --------------------------------------------------------------
  -- procedure verstuur_samenvatting
  --------------------------------------------------------------
  procedure verstuur_samenvatting (
    p_verg_nr   in twq_vergaderingen.nr%type
  , p_mail      in varchar2
  ) is

    l_ok              number(1);
    l_msg_nr          varchar2(15);
    l_msg_txt         varchar2(2000);
    l_bvbr_nr         number(12);  -- nummer berichtenreeks
    l_oubr_nr         number;

    stop_error        exception;

  begin

    update twq_v_rela_vapi
       set mail = p_mail
     where nr = epl_context.get_rela_nr;

    --
    -- maak bericht naar vergaderzaak o.b.v. Flexbrief
    --
    l_OK := p_flx_bericht.verg_stem_brief(
      rela_ipar        => epl_context.get_rela_nr
    , verg_ipar        => p_verg_nr
    , gbrk_ipar        => epl_context.get_gbrk_nr
      -- parameters voor elke bericht
    , bvbr_opar        => l_bvbr_nr
    , msg_nr_opar      => l_msg_nr
    , msg_txt_opar     => l_msg_txt
    );

    if l_ok <> 0 then
      raise stop_error;
    end if;

    update twq_bvz_berichten
       set type_bericht = 'EMAIL'
     where bvbr_nr = l_bvbr_nr;

    p_bvzp.g_email_direct_verzenden := true;

    l_OK := p_bvzp.bvz_totaal_verzenden
      ( l_bvbr_nr                         -- nr van berichtenreeks
      , 1                                 -- indicator berichten bewaren in brievenregister
      , 0                                 -- indicator gewijzigde mailadressen bewaren
      , 1                                 -- indicator afzender wijzigen in noreply@......
      -- out
      , l_oubr_nr                         -- nr van reeks outbrief
      , l_msg_txt
      );

    if l_ok <> 0 then
      raise stop_error;
    end if;

  exception
    when stop_error then
      raise_application_error(-20001, l_msg_txt);

  end verstuur_samenvatting;

end epl_stem;

/


  CREATE OR REPLACE PACKAGE BODY "EPL_BSLV" is
  /*****************************************************************************
  * versie       datum      door    wat
  * ------------ ---------- ------- ----------------------------------
  * 1.00         08-06-2016 mho     package aangemaakt
  * v1.1         12-08-2016 SR      p_ind_log vervangen door p_package_naam
  * v1.2         29-03-2017 mho     definitieve_stemming_table toegevoegd
  * v1.3         07-04-2017 mho     get_quorum_tekst: nooit meer meerderheid tonen
  * v1.4         10-04-2017 mho     stem_per_acclamatie toegevoegd
  * v1.5         24-04-2017 mho     ververs_besluitvoorstel ipv ververs_agenda
  *****************************************************************************/
  c_package_naam constant varchar2(30) := 'epl_bslv';
  c_versie       constant varchar2(15) := '1.5';

  --------------------------------------------------------------
  -- function get_uitgebrachte_stem
  --------------------------------------------------------------
  function get_uitgebrachte_stem (
    p_bslv_nr   in twq_besluitvoorstellen.nr%type
  , p_rela_nr   in twq_relaties.nr%type
  ) return twq_stemopties.nr%type
  is

    l_stemregistratie       epl_stmr.registratie_rec;

    l_stem                  epl_stem.stem_rec;
    e_geen_stemregistratie  exception;

  begin

    -- Bepaal stemregistratie
    l_stemregistratie := epl_stmr.get_registratie(p_rela_nr, p_bslv_nr);

    if l_stemregistratie.nr is null then
      raise e_geen_stemregistratie;
    end if;

    -- haal uitgebrachte stemming op
    l_stem := epl_stem.get_via_stmr_nr(l_stemregistratie.nr);

    -- Geef stemoptie terug
    return coalesce(l_stem.sopt_nr_definitief, l_stem.sopt_nr_voorlopig);

  exception
    when e_geen_stemregistratie then
      return null;

  end get_uitgebrachte_stem;

  --------------------------------------------------------------
  -- function get
  --------------------------------------------------------------
  function get (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return bslv_rec_t is

    l_rec  bslv_rec_t;

  begin

    select * into l_rec
      from twq_v_bslv_vapi
     where nr = p_nr;

    return l_rec;

  end get;

  --------------------------------------------------------------
  -- function get_verg_nr
  --------------------------------------------------------------
  function get_verg_nr (
    p_nr in twq_besluitvoorstellen.nr%type
  ) return twq_vergaderingen.nr%type is

    l_nr   twq_vergaderingen.nr%type;

  begin

    select verg.nr verg_nr into l_nr
      from twq_v_bslv_vapi bslv
      join twq_v_agnd_vapi agnd
        on agnd.nr = bslv.agnd_nr
      join twq_v_verg_vapi verg
        on agnd.verg_nr = verg.nr
     where bslv.nr = p_nr;

    return l_nr;

  end get_verg_nr;

  --------------------------------------------------------------
  -- function voorlopige_stemming_table
  --------------------------------------------------------------
  function voorlopige_stemming_table (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return p_bslv.voorlopige_stemming_tt pipelined is

    cursor c_sopt(p_bslv_nr in twq_besluitvoorstellen.nr%type) is
      select stem.*
        from table(p_bslv.voorlopige_stemming_table(p_nr)) stem
        join twq_v_bslv_vapi bslv
          on stem.bslv_nr = bslv.nr
       where bslv.nr = p_nr;

  begin

    -- return in volgorde van stemopties
    for rec  in c_sopt(p_nr) loop

      pipe row (rec);

    end loop;

    return;

  end voorlopige_stemming_table;

  --------------------------------------------------------------
  -- function definitieve_stemming_table
  --------------------------------------------------------------
  function definitieve_stemming_table (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return p_bslv.definitieve_stemming_tt pipelined is

    cursor c_sopt(p_bslv_nr in twq_besluitvoorstellen.nr%type) is
      select stem.*
        from table(p_bslv.definitieve_stemming_table(p_nr)) stem
        join twq_v_bslv_vapi bslv
          on stem.bslv_nr = bslv.nr
       where bslv.nr = p_nr;

  begin

    -- return in volgorde van stemopties
    for rec  in c_sopt(p_nr) loop

      pipe row (rec);

    end loop;

    return;

  end definitieve_stemming_table;

  --------------------------------------------------------------
  -- function get_chart_data
  --------------------------------------------------------------
  function get_chart_data (
    p_verg_nr   in twq_vergaderingen.nr%type
  , p_bslv_nr   in twq_besluitvoorstellen.nr%type
  ) return chart_data is

    l_json         json := json();

  begin
  
    l_json.put('bslvNr', p_bslv_nr);

    return l_json.to_char;

  end get_chart_data;

  --------------------------------------------------------------
  -- procedure open_stemming
  --------------------------------------------------------------
  procedure open_stemming (
    p_bslv_nr   in twq_besluitvoorstellen.nr%type
  ) is
  begin

    if p_bslv.stemming_openen_toegestaan(p_bslv_nr) then

      p_bslv.open_stemming(p_bslv_nr);

      epl_voorzitten.ververs_besluitvoorstel(
        p_verg_nr => get_verg_nr(p_bslv_nr)
      , p_bslv_nr => p_bslv_nr
      , p_oorzaak => 'Het besluitvoorstel "' || apex_escape.html(get(p_bslv_nr).basistekst_voorstel) || '" is geopend'
      );

    end if;

  end open_stemming;

  --------------------------------------------------------------
  -- procedure sluit_voorstel
  --------------------------------------------------------------
  procedure sluit_voorstel (
    p_bslv_nr   in twq_besluitvoorstellen.nr%type
  ) is
  begin

    p_bslv.sluit_voorstel(p_bslv_nr);

    epl_voorzitten.ververs_besluitvoorstel(
        p_verg_nr => get_verg_nr(p_bslv_nr)
      , p_bslv_nr => p_bslv_nr
    , p_oorzaak => 'Het besluitvoorstel "' || apex_escape.html(get(p_bslv_nr).basistekst_voorstel) || '" is gesloten.'
    );

    p_apex_utils.set_success_message('Het voorstel is gesloten.');

  end sluit_voorstel;

  --------------------------------------------------------------
  -- procedure sluit_stemming
  --------------------------------------------------------------
  procedure sluit_stemming (
    p_bslv_nr   in twq_besluitvoorstellen.nr%type
  ) is
  begin

    p_bslv.sluit_stemming(p_bslv_nr);

    epl_voorzitten.ververs_besluitvoorstel(
        p_verg_nr => get_verg_nr(p_bslv_nr)
      , p_bslv_nr => p_bslv_nr
    , p_oorzaak => 'Het besluitvoorstel "' || apex_escape.html(get(p_bslv_nr).basistekst_voorstel) || '" is gesloten.'
    );

    p_apex_utils.set_success_message('De stemming is gesloten.');

  end sluit_stemming;

  --------------------------------------------------------------
  -- function is_gesloten
  --------------------------------------------------------------
  function is_gesloten (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return boolean is

    l_rec bslv_rec_t;

  begin

    l_rec := get(p_nr);

    return p_bslv.is_gesloten(p_datum_gesloten => l_rec.datum_gesloten);

  end is_gesloten;

  --------------------------------------------------------------
  -- function ind_gesloten
  --------------------------------------------------------------
  function ind_gesloten (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return number is
  begin

    return p_apex_utils.boolean_to_ind(is_gesloten(p_nr));

  end ind_gesloten;

  --------------------------------------------------------------
  -- function is_geopend
  --------------------------------------------------------------
  function is_geopend (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return boolean is

    l_rec bslv_rec_t;

    l_verg_rec  twq_v_verg_vapi%rowtype;

    l_verg_datum_stemming_open date;

  begin

    l_rec := get(p_nr);

    l_verg_rec := twq_verg_capi.vapi_get(get_verg_nr(p_nr));

    l_verg_datum_stemming_open := epl_verg.get_stemming_open_datum(l_verg_rec.nr);

    return p_bslv.is_geopend(
      p_verg_stemming_datum_open  => l_verg_datum_stemming_open
    , p_periode_stemming          => l_verg_rec.periode_stemming
    , p_datum_open                => l_rec.datum_open
    , p_datum_gesloten            => l_rec.datum_gesloten
    );

  end is_geopend;

  ------------------------------------------------------------
  -- function is_quorum_behaald
  ------------------------------------------------------------
  function is_quorum_behaald(
    p_nr twq_besluitvoorstellen.nr%type
  ) return boolean is

  begin

    return p_bslv.is_quorum_behaald(p_nr);

  end is_quorum_behaald;

  ------------------------------------------------------------
  -- function ind_quorum_behaald
  ------------------------------------------------------------
  function ind_quorum_behaald(
    p_nr twq_besluitvoorstellen.nr%type
  ) return number is

  begin

    return p_apex_utils.boolean_to_ind(is_quorum_behaald(p_nr));

  end ind_quorum_behaald;

  --------------------------------------------------------------
  -- function get_next_volg_nr
  --------------------------------------------------------------
  function get_next_volg_nr (
    p_agnd_nr in  twq_besluitvoorstellen.nr%type
  ) return number is

    l_volg_nr   number;

  begin

    select max(volg_nr) + 1 into l_volg_nr
      from twq_v_bslv_vapi
     where agnd_nr = p_agnd_nr;

    return nvl(l_volg_nr,1);

  end get_next_volg_nr;

  --------------------------------------------------------------
  -- procedure set_aantal_keuzeopties
  --------------------------------------------------------------
  procedure set_aantal_keuzeopties(
    p_aantal number
  ) is
  begin

    p_bslv.g_aantal_keuze_opties := p_aantal;

  end set_aantal_keuzeopties;

  --------------------------------------------------------------
  -- procedure voeg_extra_keuzeoptie_toe
  --------------------------------------------------------------
  procedure voeg_extra_keuzeoptie_toe (
    p_nr in twq_besluitvoorstellen.nr%type
  ) is
  begin

    p_bslv.voeg_extra_keuzeoptie_toe(p_nr);

  end voeg_extra_keuzeoptie_toe;

  --------------------------------------------------------------
  -- procedure heropen
  --------------------------------------------------------------
  procedure heropen (
    p_nr in twq_besluitvoorstellen.nr%type
  ) is
  begin

    p_bslv.heropen(p_nr);
    
    epl_voorzitten.ververs_besluitvoorstel(
      p_verg_nr => get_verg_nr(p_nr)
    , p_bslv_nr => p_nr
    , p_oorzaak => 'Het besluitvoorstel "' || apex_escape.html(get(p_nr).basistekst_voorstel) || '" is heropend');

  end heropen;

  --------------------------------------------------------------
  -- function scenario_teksten
  --------------------------------------------------------------
  function scenario_teksten(
    p_nr   twq_besluitvoorstellen.nr%type
  ) return scenario_tekst_tt pipelined
  is

    l_rec scenario_tekst_rt;

    cursor c_bsvt(p_bslv_nr twq_besluitvoorstellen.nr%type) is
      select bvsc.nr bvsc_nr
           , p_bslv_nr bslv_nr
           , nvl(bsvt.tekst, 'Geen tekst opgegeven') tekst
           , bvsc.omschrijving scenario
           , bvsc.volg_nr
           , case when bsvt.tekst is null then 'text-danger' end tekst_style
        from twq_besluitvoorstel_scenarios bvsc
        left join twq_v_bsvt_vapi bsvt
          on bvsc.nr = bsvt.bvsc_nr
         and bsvt.bslv_nr = p_bslv_nr
       where bvsc.ind_besluit = 1
         and bvsc.voorstel_type = (select voorstel_type from twq_v_bsvt_vapi where nr = p_bslv_nr);

  begin

    for rec in c_bsvt(p_nr) loop

      pipe row(rec);

    end loop;

    return;

  end scenario_teksten;

  --------------------------------------------------------------
  -- procedure kopieer_besluitvoorstel
  --------------------------------------------------------------
  procedure kopieer_besluitvoorstel (
    p_bslv_nr             in twq_besluitvoorstellen.nr%type
  , p_agnd_nr             in twq_besluitvoorstellen.agnd_nr%type
  , p_voorstel_type       in twq_besluitvoorstellen.voorstel_type%type
  , p_basistekst_voorstel in twq_besluitvoorstellen.basistekst_voorstel%type
  , p_mdef_nr             in twq_besluitvoorstellen.mdef_nr%type
  , p_opties              in varchar2
  ) is

    l_bslv_nr   twq_besluitvoorstellen.nr%type;
    l_vc_arr2   apex_application_global.vc_arr2;

    ---------------------------------------
    -- procedure ins_bslv
    ---------------------------------------
    procedure ins_bslv(
      p_agnd_nr             in twq_besluitvoorstellen.agnd_nr%type
    , p_voorstel_type       in twq_besluitvoorstellen.voorstel_type%type
    , p_basistekst_voorstel in twq_besluitvoorstellen.basistekst_voorstel%type
    , p_mdef_nr             in twq_besluitvoorstellen.mdef_nr%type
    -- out
    , p_nr                  out twq_besluitvoorstellen.nr%type
    ) is
    begin

      -- Stemopties niet via trigger toevoegen maar via wizard
      p_bslv.g_standaard_opties_toevoegen := false;

      p_nr := twq_bslv_capi.get_seq_nextval;

      insert into twq_v_bslv_vapi (
        nr
      , agnd_nr
      , mdef_nr
      , volg_nr
      , basistekst_voorstel
      , voorstel_type)
      values (
        p_nr
      , p_agnd_nr
      , p_mdef_nr
      , get_next_volg_nr(p_agnd_nr)
      , p_basistekst_voorstel
      , p_voorstel_type
      );

    end ins_bslv;

    ---------------------------------------
    -- procedure ins_sopt
    ---------------------------------------
    procedure ins_sopt(
      p_bslv_nr_bron  in twq_besluitvoorstellen.nr%type
    , p_bslv_nr_doel  in twq_besluitvoorstellen.nr%type
    ) is

      cursor c_sopt(p_bslv_nr twq_besluitvoorstellen.nr%type) is
        select sopt.*
          from twq_v_sopt_vapi sopt
         where sopt.bslv_nr = p_bslv_nr;

    begin

      for rec in c_sopt(p_bslv_nr_bron) loop

        insert into twq_v_sopt_vapi (
          nr
        , bslv_nr
        , volg_nr
        , code
        , tekst_optie
        ) values (
          twq_sopt_capi.get_seq_nextval
        , p_bslv_nr_doel
        , rec.volg_nr
        , rec.code
        , rec.tekst_optie
        );

      end loop;

    end ins_sopt;

    ---------------------------------------
    -- procedure ins_bsla
    ---------------------------------------
    procedure ins_bsla(
      p_bslv_nr_bron  in twq_besluitvoorstellen.nr%type
    , p_bslv_nr_doel  in twq_besluitvoorstellen.nr%type
    ) is

      cursor c_bsla(p_bslv_nr twq_besluitvoorstellen.nr%type) is
        select *
          from twq_v_bsla_vapi
         where bslv_nr = p_bslv_nr;

    begin

      for rec in c_bsla(p_bslv_nr_bron) loop

        insert into twq_v_bsla_vapi (
          nr
        , bslv_nr
        , bhdl_type
        , bhdl_nr_code
        , datum_planning
        , tekst
        , toelichting
        ) values (
          twq_bsla_capi.get_seq_nextval
        , p_bslv_nr_doel
        , rec.bhdl_type
        , rec.bhdl_nr_code
        , rec.datum_planning
        , rec.tekst
        , rec.toelichting
        );

      end loop;

    end ins_bsla;

    ---------------------------------------
    -- procedure ins_bsvt
    ---------------------------------------
    procedure ins_bsvt(
      p_bslv_nr_bron  in twq_besluitvoorstellen.nr%type
    , p_bslv_nr_doel  in twq_besluitvoorstellen.nr%type
    ) is

      cursor c_bsvt(p_bslv_nr twq_besluitvoorstellen.nr%type) is
        select *
          from twq_v_bsvt_vapi
         where bslv_nr = p_bslv_nr;

    begin

      for rec in c_bsvt(p_bslv_nr_bron) loop

        insert into twq_v_bsvt_vapi (
          bslv_nr
        , bvsc_nr
        , tekst
        ) values (
          p_bslv_nr_doel
        , rec.bvsc_nr
        , rec.tekst
        );

      end loop;

    end ins_bsvt;

  begin

    ins_bslv(
      p_agnd_nr             => p_agnd_nr
    , p_voorstel_type       => p_voorstel_type
    , p_basistekst_voorstel => p_basistekst_voorstel
    , p_mdef_nr             => p_mdef_nr
    -- out
    , p_nr                  => l_bslv_nr
    );

    l_vc_arr2 := apex_util.string_to_table(p_opties);

    for idx in 1..l_vc_arr2.count loop

      if l_vc_arr2(idx) = 'SOPT' then

        ins_sopt(
          p_bslv_nr_bron  => p_bslv_nr
        , p_bslv_nr_doel  => l_bslv_nr
        );

      elsif l_vc_arr2(idx) = 'BSLA' then

        ins_bsla(
          p_bslv_nr_bron  => p_bslv_nr
        , p_bslv_nr_doel  => l_bslv_nr
        );

      elsif l_vc_arr2(idx) = 'BSVT' then

        ins_bsvt(
          p_bslv_nr_bron  => p_bslv_nr
        , p_bslv_nr_doel  => l_bslv_nr
        );

      end if;

    end loop;

  end kopieer_besluitvoorstel;

  --------------------------------------------------------------
  -- function get_situatie
  --------------------------------------------------------------
  function get_situatie (
    p_nr      in twq_besluitvoorstellen.nr%type
  , p_rela_nr in twq_relaties.nr%type
  ) return bslv_situatie
  is

    l_verg_nr                   twq_vergaderingen.nr%type;
    l_verg_rec                  twq_v_verg_vapi%rowtype;
    l_status                    p_bslv.status_type;
    l_situatie                  bslv_situatie;
    l_beschikbaarheid_stemmen   p_verg.beschikbaarheid_stemmen_rt;

    e_exit                      exception;

  begin

    /*

      Er zijn op twee niveaus zaken om rekening mee te houden:

      1. Mag er op vergaderniveau digitaal gestemd worden, zoja, tijdens welke periode
      2. Mag er op besluitvoorstelniveau gestemd worden

    */

    select agnd.verg_nr into l_verg_nr
      from twq_v_agnd_vapi agnd
      join twq_v_bslv_vapi bslv
        on agnd.nr = bslv.agnd_nr
     where bslv.nr = p_nr;

    l_verg_rec := epl_verg.get(l_verg_nr);

    l_beschikbaarheid_stemmen := p_verg.beschikbaarheid_digi_stemmen(
      p_periode_stemming        => l_verg_rec.periode_stemming
    , p_datumtijd               => l_verg_rec.vc_datumtijd
    , p_status_notulen          => l_verg_rec.status_notulen
    , p_stemming_open_aantal    => l_verg_rec.stemming_open_aantal
    , p_stemming_open_eenheid   => l_verg_rec.stemming_open_eenheid
    );


    if not l_beschikbaarheid_stemmen.beschikbaar then

      l_situatie.code := epl_bslv.gc_bslv_tonen;
      l_situatie.omschrijving := l_beschikbaarheid_stemmen.opmerking;
      raise e_exit;

    end if;

    l_status := p_bslv.get_status(p_nr);
      p_ac('Kokosmakronen', l_status);

    if l_status in (p_bslv.gc_status_vooraf_nnb, p_bslv.gc_status_nnb) then

      l_situatie.code := epl_bslv.gc_bslv_tonen;
      l_situatie.omschrijving := 'De stemming is nog niet geopend.';

    elsif l_status in (p_bslv.gc_status_vooraf_b, p_bslv.gc_status_in_stemming) then

      if epl_vprs.is_aanwezig(l_verg_nr, p_rela_nr) then

        if epl_vves.is_eigenaar(epl_context.get_vves_nr, p_rela_nr) then

          l_situatie.code := epl_bslv.gc_bslv_stemmen;

        else

          l_situatie.code := epl_bslv.gc_bslv_tonen;
          l_situatie.omschrijving := 'U heeft geen stemrecht.';

        end if;

      else

          l_situatie.code := epl_bslv.gc_bslv_tonen;
          l_situatie.omschrijving := 'U staat niet als aanwezige op de presentielijst.';

      end if;

    elsif l_status = p_bslv.gc_status_gesloten then

      l_situatie.code := epl_bslv.gc_bslv_gesloten;
      l_situatie.omschrijving := 'De stemming is gesloten.';

    end if;




    return l_situatie;

  exception
    when e_exit then
      return l_situatie;

  end get_situatie;

  --------------------------------------------------------------
  -- function get_quorum_tekst
  --------------------------------------------------------------
  function get_quorum_tekst(
    p_nr                in twq_besluitvoorstellen.nr%type
  , p_incl_meerderheid  boolean default false
  ) return varchar2 is

    l_info  p_bslv.quorum_info;

    type html_tab is table of varchar2(4000) index by pls_integer;

    l_html apex_application_global.vc_arr2;

    function tekst_eenheid (p_aantal number)
    return varchar2 is
    begin

      if nvl(p_aantal, 0) = 1 then
        return 'stem';
      else
        return 'stemmen';
      end if;

    end tekst_eenheid;

  begin

    l_info := p_bslv.get_quorum_info(p_nr);

    l_html(l_html.count + 1) := '<table>';
    l_html(l_html.count + 1) := '<tr><td>&nbsp;</td></tr>';
    l_html(l_html.count + 1) := '<tr><td>Type: </td><td>' || l_info.meerderheidsnaam || '</td></tr>';
    l_html(l_html.count + 1) := '<tr><td>Omschrijving: </td><td>' || l_info.meerderheidsdefinitie || '</td></tr>';
    l_html(l_html.count + 1) := '<tr><td>&nbsp;</td></tr>';
    l_html(l_html.count + 1) := '<tr><td>Benodigd quorum vooraf</td></tr>';
    l_html(l_html.count + 1) := '<tr><td>Aantal stemmen aanwezig: </td><td>' || l_info.stemmen_aanwezig || ' ' || tekst_eenheid(l_info.stemmen_aanwezig) || '</td></tr>';
    l_html(l_html.count + 1) := '<tr><td>Aantal aanwezige stemmen nodig om quorum te halen: </td><td>' || l_info.stemmen_benodigd || ' ' || tekst_eenheid(l_info.stemmen_benodigd) || '</td></tr>';
    l_html(l_html.count + 1) := '<tr><td>Resultaat quorum: </td><td>' || l_info.omschrijving || '</td></tr>';

    -- v1.3: nooit meer meerderheid tonen (kan niet bepaald worden omdat Blanco Stemmen het benodigde aantal beinvloed.
    
    /*if p_incl_meerderheid then
      l_html(l_html.count + 1) := '<tr><td>&nbsp;</td></tr>';
      l_html(l_html.count + 1) := '<tr><td>Benodigde meerderheid na stemming</tr>';
      l_html(l_html.count + 1) := '<tr><td>Benodigde meerderheid voor rechtsgeldig besluit: </td><td>' || case when l_info.gekwalificeerd then l_info.stemmen_meerderheid || ' ' || tekst_eenheid(l_info.stemmen_meerderheid) else 'De meerderheid is niet gekwalificeerd (verschil van 1 stem is voldoende)' end || '</td></tr>';
    end if;*/
    
    -- v1.3: einde

    l_html(l_html.count + 1) := '</table>';

    return apex_util.table_to_string(l_html, chr(10));

  end get_quorum_tekst;

  --------------------------------------------------------------
  -- function get_status
  --------------------------------------------------------------
  function get_status (
    p_nr in twq_besluitvoorstellen.nr%type
  ) return p_bslv.status_type is

  begin

    return p_bslv.get_status(p_nr);

  end get_status;

  --------------------------------------------------------------
  -- function get_status_omschrijving
  --------------------------------------------------------------
  function get_status_omschrijving (
    p_nr in twq_besluitvoorstellen.nr%type
  ) return p_bslv.status_type is

    l_status_omschrijving   varchar2(100);
    l_verg_rec      twq_v_verg_vapi%rowtype;
    l_datum date;

  begin

    l_verg_rec := epl_verg.get(get_verg_nr(p_nr));

    l_datum :=
      p_verg.get_stemming_open_datum(
        p_verg_datum  => l_verg_rec.vc_datumtijd
      , p_aantal      => l_verg_rec.stemming_open_aantal
      , p_eenheid     => l_verg_rec.stemming_open_eenheid
      );

    return replace(p_twq_algemeen.refc_meaning('STATUS_BESLUITVOORSTEL', get_status(p_nr)), '#DATUMTIJD#', to_char(l_datum));

  end get_status_omschrijving;

  --------------------------------------------------------------
  -- function ind_kan_gestemd_worden
  --------------------------------------------------------------
  function ind_kan_gestemd_worden (
    p_bslv_status in p_bslv.status_type
  ) return number deterministic is

  begin

    return p_apex_utils.boolean_to_ind(p_bslv.kan_gestemd_worden(p_bslv_status));

  end ind_kan_gestemd_worden;
  
  --------------------------------------------------------------
  -- procedure stem_per_acclamatie
  --------------------------------------------------------------
  procedure stem_per_acclamatie (
    p_nr        in twq_besluitvoorstellen.nr%type
  , p_sopt_nr   in twq_stemopties.nr%type
  ) is
  
    cursor c_vprs(b_bslv_nr in twq_besluitvoorstellen.nr%type) is
      select vprs.rela_nr
        from twq_v_vprs_vapi vprs
        join twq_v_agnd_vapi agnd
          on vprs.verg_nr = agnd.verg_nr
        join twq_v_bslv_vapi bslv
          on bslv.agnd_nr = agnd.nr
       where bslv.nr = b_bslv_nr
         and not exists (select 1
                           from twq_v_stmr_vapi stmr
                          where stmr.bslv_nr = bslv.nr
                            and vprs.ind_digitaal = 1)
       union 
      select ctps.rela_nr
        from twq_v_vprs_vapi vprs
        join twq_v_ctps_vapi ctps
          on vprs.ctps_nr = ctps.nr
        join twq_v_agnd_vapi agnd
          on vprs.verg_nr = agnd.verg_nr
        join twq_v_bslv_vapi bslv
          on bslv.agnd_nr = agnd.nr
       where bslv.nr = b_bslv_nr
         and not exists (select 1
                           from twq_v_stmr_vapi stmr
                          where stmr.bslv_nr = bslv.nr
                            and vprs.ind_digitaal = 1);
  
  begin
  
    for rec in c_vprs(p_nr) loop

      epl_stem.breng_voorlopige_stem_uit(
        p_sopt_nr             => p_sopt_nr
      , p_rela_nr             => rec.rela_nr
      , p_update_vrzt_chart   => false
      );

    end loop;

    p_bslv.sluit_stemming(
      p_bslv_nr         => p_nr
    , p_per_acclamatie  => true
    );
  
  end stem_per_acclamatie;

  --------------------------------------------------------------
  -- function is_gekwalificeerd
  --------------------------------------------------------------
  function is_gekwalificeerd (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return boolean is
  begin
    return p_bslv.get_quorum_info(p_nr).gekwalificeerd;
  end is_gekwalificeerd;

  --------------------------------------------------------------
  -- function gekwalificeerde_meerderheid
  --------------------------------------------------------------
  function gekwalificeerde_meerderheid (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return number is
  begin
    return p_bslv.get_quorum_info(p_nr).stemmen_meerderheid;
  end gekwalificeerde_meerderheid;
  

end epl_bslv;
/


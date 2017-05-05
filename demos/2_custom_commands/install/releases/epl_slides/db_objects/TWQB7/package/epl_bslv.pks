
  CREATE OR REPLACE PACKAGE "EPL_BSLV" is

  gc_status_in_stemming   constant p_bslv.status_type := p_bslv.gc_status_in_stemming;
  gc_status_gesloten      constant p_bslv.status_type := p_bslv.gc_status_gesloten;

  subtype bslv_rec_t is twq_v_bslv_vapi%rowtype;

  subtype chart_data is varchar2(32000);

  gc_type_voortegen   constant p_bslv.voorstel_type := p_bslv.gc_type_voortegen;
  gc_type_keuze       constant p_bslv.voorstel_type := p_bslv.gc_type_keuze;

  type scenario_tekst_rt is record (
    bvsc_nr       twq_bslv_besluitteksten.bvsc_nr%type
  , bslv_nr       twq_bslv_besluitteksten.bslv_nr%type
  , tekst         twq_bslv_besluitteksten.tekst%type
  , scenario      twq_besluitvoorstel_scenarios.omschrijving%type
  , volg_nr       twq_besluitvoorstel_scenarios.volg_nr%type
  , tekst_style   varchar2(30)
  );

  type scenario_tekst_tt is table of scenario_tekst_rt;

  subtype bslv_situatie_code is varchar2(30);

  gc_bslv_tonen     constant bslv_situatie_code := 'BESLUITVOORSTEL_TONEN';
  gc_bslv_stemmen   constant bslv_situatie_code := 'BESLUITVOORSTEL_STEMMEN';
  gc_bslv_gesloten  constant bslv_situatie_code := 'BESLUITVOORSTEL_GESLOTEN';

  type bslv_situatie is record (
    code          bslv_situatie_code
  , omschrijving  varchar2(4000)
  );

  --------------------------------------------------------------
  -- function get_uitgebrachte_stem
  --------------------------------------------------------------
  function get_uitgebrachte_stem (
    p_bslv_nr   in twq_besluitvoorstellen.nr%type
  , p_rela_nr   in twq_relaties.nr%type
  ) return twq_stemopties.nr%type;

  --------------------------------------------------------------
  -- function get
  --------------------------------------------------------------
  function get (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return bslv_rec_t;
  
  --------------------------------------------------------------
  -- function get_verg_nr
  --------------------------------------------------------------
  function get_verg_nr (
    p_nr in twq_besluitvoorstellen.nr%type
  ) return twq_vergaderingen.nr%type;

  --------------------------------------------------------------
  -- function voorlopige_stemming_table
  --------------------------------------------------------------
  function voorlopige_stemming_table (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return p_bslv.voorlopige_stemming_tt pipelined;

  --------------------------------------------------------------
  -- function definitieve_stemming_table
  --------------------------------------------------------------
  function definitieve_stemming_table (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return p_bslv.definitieve_stemming_tt pipelined;

  --------------------------------------------------------------
  -- function get_chart_data
  --------------------------------------------------------------
  function get_chart_data (
    p_verg_nr   in twq_vergaderingen.nr%type
  , p_bslv_nr   in twq_besluitvoorstellen.nr%type
  ) return chart_data ;

  --------------------------------------------------------------
  -- procedure open_stemming
  --------------------------------------------------------------
  procedure open_stemming (
    p_bslv_nr   in twq_besluitvoorstellen.nr%type
  );

  --------------------------------------------------------------
  -- procedure sluit_voorstel
  --------------------------------------------------------------
  procedure sluit_voorstel (
    p_bslv_nr   in twq_besluitvoorstellen.nr%type
  );

  --------------------------------------------------------------
  -- procedure sluit_stemming
  --------------------------------------------------------------
  procedure sluit_stemming (
    p_bslv_nr   in twq_besluitvoorstellen.nr%type
  );

  --------------------------------------------------------------
  -- function is_gesloten
  --------------------------------------------------------------
  function is_gesloten (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return boolean;

  --------------------------------------------------------------
  -- function ind_gesloten
  --------------------------------------------------------------
  function ind_gesloten (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return number;

  --------------------------------------------------------------
  -- function is_geopend
  --------------------------------------------------------------
  function is_geopend (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return boolean;

  ------------------------------------------------------------
  -- function is_quorum_behaald
  ------------------------------------------------------------
  function is_quorum_behaald(
    p_nr twq_besluitvoorstellen.nr%type
  ) return boolean;

  ------------------------------------------------------------
  -- function ind_quorum_behaald
  ------------------------------------------------------------
  function ind_quorum_behaald(
    p_nr twq_besluitvoorstellen.nr%type
  ) return number;

  --------------------------------------------------------------
  -- function get_next_volg_nr
  --------------------------------------------------------------
  function get_next_volg_nr (
    p_agnd_nr in  twq_besluitvoorstellen.nr%type
  ) return number;

  --------------------------------------------------------------
  -- procedure set_aantal_keuzeopties
  --------------------------------------------------------------
  procedure set_aantal_keuzeopties(
    p_aantal number
  );

  --------------------------------------------------------------
  -- procedure voeg_extra_keuzeoptie_toe
  --------------------------------------------------------------
  procedure voeg_extra_keuzeoptie_toe (
    p_nr in twq_besluitvoorstellen.nr%type
  );

  --------------------------------------------------------------
  -- procedure heropen
  --------------------------------------------------------------
  procedure heropen (
    p_nr in twq_besluitvoorstellen.nr%type
  );

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
  );

  --------------------------------------------------------------
  -- function get_situatie
  --------------------------------------------------------------
  function get_situatie (
    p_nr      in twq_besluitvoorstellen.nr%type
  , p_rela_nr in twq_relaties.nr%type
  ) return bslv_situatie;

  --------------------------------------------------------------
  -- function get_quorum_tekst
  --------------------------------------------------------------
  function get_quorum_tekst(
    p_nr                in twq_besluitvoorstellen.nr%type
  , p_incl_meerderheid  boolean default false
  ) return varchar2;

  --------------------------------------------------------------
  -- function get_status
  --------------------------------------------------------------
  function get_status (
    p_nr in twq_besluitvoorstellen.nr%type
  ) return p_bslv.status_type;

  --------------------------------------------------------------
  -- function get_status_omschrijving
  --------------------------------------------------------------
  function get_status_omschrijving (
    p_nr in twq_besluitvoorstellen.nr%type
  ) return p_bslv.status_type;

  --------------------------------------------------------------
  -- function ind_kan_gestemd_worden
  --------------------------------------------------------------
  function ind_kan_gestemd_worden (
    p_bslv_status in p_bslv.status_type
  ) return number deterministic;

  --------------------------------------------------------------
  -- procedure stem_per_acclamatie
  --------------------------------------------------------------
  procedure stem_per_acclamatie (
    p_nr        in twq_besluitvoorstellen.nr%type
  , p_sopt_nr   in twq_stemopties.nr%type
  );

  --------------------------------------------------------------
  -- function is_gekwalificeerd
  --------------------------------------------------------------
  function is_gekwalificeerd (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return boolean;
  
  --------------------------------------------------------------
  -- function gekwalificeerde_meerderheid
  --------------------------------------------------------------
  function gekwalificeerde_meerderheid (
    p_nr   in twq_besluitvoorstellen.nr%type
  ) return number;

end epl_bslv;
/


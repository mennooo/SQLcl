
  CREATE OR REPLACE PACKAGE "EPL_STEM" is

  subtype stem_rec is twq_v_stem_vapi%rowtype;

  subtype chart_data is varchar2(32000);

  --------------------------------------------------------------
  -- function get_via_stmr_nr
  --------------------------------------------------------------
  function get_via_stmr_nr (
    p_stmr_nr twq_stemmen.stmr_nr%type
  ) return stem_rec;

  --------------------------------------------------------------
  -- procedure update_voorzitter_chart
  --------------------------------------------------------------
  procedure update_voorzitter_chart (
    p_stem_nr   in twq_stemmen.nr%type
  );

  --------------------------------------------------------------
  -- procedure breng_voorlopige_stem_uit
  --------------------------------------------------------------
  procedure breng_voorlopige_stem_uit (
    p_sopt_nr             in twq_stemopties.nr%type
  , p_rela_nr             in twq_relaties.nr%type
  , p_update_vrzt_chart   in boolean default true
  );

  --------------------------------------------------------------
  -- procedure breng_voorlopige_stemmen_uit
  --------------------------------------------------------------
  procedure breng_voorlopige_stemmen_uit (
    p_sopt_nr   in twq_stemopties.nr%type
  , p_rela_nrs  in varchar2
  );

  --------------------------------------------------------------
  -- procedure verstuur_samenvatting
  --------------------------------------------------------------
  procedure verstuur_samenvatting (
    p_verg_nr   in twq_vergaderingen.nr%type
  , p_mail      in varchar2
  );

end epl_stem;
/


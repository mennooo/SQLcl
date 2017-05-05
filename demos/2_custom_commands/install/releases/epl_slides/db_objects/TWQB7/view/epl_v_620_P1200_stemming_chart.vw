create or replace view epl_v_620_p1200_stemming_chart as
select stem.code
     , stem.tekst_optie
     , stem.aantal_stemmen
     , stem.aantal_stemmen_mmm
     , stem.aantal_stemmen || case stem.aantal_stemmen when 1 then ' stem' else ' stemmen' end custom_tooltip
     , stem.aantal_stemmen_mmm || case stem.aantal_stemmen_mmm when 1 then ' meerderheidsstem' else ' meerderheidsstemmen' end custom_tooltip_mmm
  from table(epl_bslv.voorlopige_stemming_table(v('P1200_BSLV_NR'))) stem;


/
/
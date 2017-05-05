create or replace view epl_v_620_P4001_stemming as
  select /* [{#} 17-03-2017 11:08:17 {#}] */  tekst_optie
     , nvl(aantal_stemmen,0) + nvl(aantal_stemmen_mmm,0) aantal_stemmen
  from table(epl_bslv.voorlopige_stemming_table(v('P4001_BSLV_NR')));


/
/
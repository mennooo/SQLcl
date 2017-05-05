create or replace view epl_v_620_p1300_stemming as
select stem.code
     , stem.tekst_optie
     , stem.aantal_stemmen
     , stem.aantal_stemmen || case stem.aantal_stemmen when 1 then ' stem' else ' stemmen' end custom_tooltip
  from table(epl_bslv.definitieve_stemming_table(v('P1300_BSLV_NR'))) stem;


/
/
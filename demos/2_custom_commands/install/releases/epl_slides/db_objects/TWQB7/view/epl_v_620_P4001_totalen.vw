create or replace view epl_v_620_P4001_totalen as
  select /* [{#} 17-03-2017 11:08:17 {#}] */  attribuut
     , waarde
     , volg_nr
  from table(epl_620_4001_totalen.totalen(v('P0_VERG_NR'),v('P4001_BSLV_NR')));


/
/
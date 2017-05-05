create or replace view epl_v_620_P2000_agnd_list as
select level niveau
     , title
     , nr
     , case when v('P2000_SLIDE_ID') = value then 1 else 0 end is_current_list_entry
     , image
     , connect_by_isleaf isleaf
     , 'P2000_SLIDE_ID' item
     , value
  from (select agnd.nr
             , null parent_nr
             , agnd.punt || agnd.sub_punt || ' ' || agnd.tekst title
             , row_number() over (partition by agnd.verg_nr order by punt, sub_punt) sorteer_nr
             , null image
             , 'AGND' || agnd.nr value
          from twq_v_agnd_vapi agnd
         where verg_nr = v('AI_VERG_NR')
         union all
        select bslv.nr
             , agnd.nr
             , bslv.basistekst_voorstel
             , bslv.volg_nr
             , 'fa-legal'
             , 'BSLV' || bslv.nr value
          from twq_v_agnd_vapi agnd
          join twq_v_bslv_vapi bslv
            on bslv.agnd_nr = agnd.nr
         where verg_nr = v('AI_VERG_NR'))
 start with parent_nr is null
connect by prior nr = parent_nr
  order siblings by sorteer_nr;
/
/
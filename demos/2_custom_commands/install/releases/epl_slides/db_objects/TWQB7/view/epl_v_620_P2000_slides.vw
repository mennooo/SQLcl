create or replace view epl_v_620_p2000_slides as 
select slide_id
     , url
     , tekst
  from (select agnd.nr
             , null parent_nr
             , 'AGND' || agnd.nr slide_id
             , apex_page.get_url(p_page => 4000, p_items => 'P4001_BSLV_NR', p_values => agnd.nr) url
             , agnd.punt || agnd.sub_punt || ' ' || agnd.tekst tekst
             , row_number() over (partition by agnd.verg_nr order by punt, sub_punt) sorteer_nr
          from twq_v_agnd_vapi agnd
         where verg_nr = v('AI_VERG_NR')
         union all
        select bslv.nr
             , agnd.nr
             , 'BSLV' || bslv.nr 
             , apex_page.get_url(p_page => 4001, p_items => 'P4001_BSLV_NR', p_values => bslv.nr) url
             , 'Besluitvoorstel: ' || bslv.basistekst_voorstel tekst
             , bslv.volg_nr
          from twq_v_agnd_vapi agnd
          join twq_v_bslv_vapi bslv
            on bslv.agnd_nr = agnd.nr
         where verg_nr = v('AI_VERG_NR'))
 start with parent_nr is null
connect by prior nr = parent_nr
  order siblings by sorteer_nr;


/
/
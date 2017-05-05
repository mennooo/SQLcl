
  CREATE OR REPLACE PACKAGE "ALG_ERROR" as

  type info_rectype is record( melding      varchar2(8000)
                             , proc_schema  all_objects.owner%TYPE
                             , proc_naam    all_objects.object_name%TYPE
                             , regelnr      pls_integer);

  g_ind_test     boolean := false;
  e_handled_exception exception;
  pragma exception_init(e_handled_exception, -20000);

  gc_toon_error_nr  constant number := -20999;

  function package_naam_versie return varchar2;

  /*****************************************************************************
  * Afwijkende scope zetten. Bijvoorbeeld om te koppelen aan de queue
  *****************************************************************************/
  procedure set_scope(p_scope in varchar2);

  /******************************************************************************
  * Functie die als Error Handling Function wordt gebruikt in de Application
  * definition in de Apex applicatie(s)
  ******************************************************************************/
  function apex_error_handling(p_error  in apex_error.t_error
                              ,p_prefix in varchar2 default null) return apex_error.t_error_result;

  /******************************************************************************
  * Rollback uitvoeren en fout_afhandelen aanroepen met de jusite parameters
  ******************************************************************************/
  function get_ajax_melding(p_ora_sqlcode varchar2
                           ,p_ora_sqlerrm varchar2) return varchar2;

  /******************************************************************************
  * Procedure aangeroepen wordt bij exception handling van bekende foutmeldingen
  ******************************************************************************/
  procedure toon_melding(p_package_naam in varchar2
                        ,p_code         in alg_meldingen.code%type
                        ,p_param1       in varchar2 default null
                        ,p_param2       in varchar2 default null
                        ,p_param3       in varchar2 default null
                        ,p_param4       in varchar2 default null
                        ,p_param5       in varchar2 default null
                        ,p_scope        in varchar2 default null
                        ,p_params       in logger.tab_param default logger.gc_empty_tab_param);

  /*****************************************************************************
  * Override functie van de toon_melding voor het geval geen gebruik gemaakt
  * wordt van de meldingen functionaliteit van VGB
  * Hierdoor kunnen we er later altijd nog voor kiezen iets met deze meldingen
  * te doen.
  *****************************************************************************/
  procedure toon_melding(p_sqlcode in varchar2
                        ,p_sqlerrm in varchar2);

  /*****************************************************************************
  * wrapper rond dbms_utility.format_error_stack
  *****************************************************************************/
  function err_melding return varchar2;

  /*****************************************************************************
	* wrapper rond dbms_utility.format_error_backtrace
	*****************************************************************************/
	function err_melding_stack return varchar2;
	
  /*****************************************************************************
  * Deze functie geeft een leesbare foutmelding van dbms_utility.format_error_backtrace
  *****************************************************************************/
	function toon_info(p_toon_schema in boolean := false) return varchar2;

end alg_error;
/


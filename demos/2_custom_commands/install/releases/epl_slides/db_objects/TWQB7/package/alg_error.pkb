
  CREATE OR REPLACE PACKAGE BODY "ALG_ERROR" as
   /*****************************************************************************
  * v1.0 ??-??-2015 HvK creatie
  * v1.1 ??-??-2015 SR  uitbreiding
  * v1.2 17-08-2015 HvK documentatie, functie get_ind_log vervangen door initialisatie
  * v1.3 21-08-2015 SR  errorcode toevoegen in testmodus op juiste plek gezet en alleen eerste regel van handmatige foutmeldingen in apex tonen
  * v1.4 04-11-2015 SR  log_error function aangemaakt en loggen voordat een fout geraised wordt bij toon_melding
  * v1.5 14-03-2016 HvK foutmeldingsprocedures/functies toegevoegd voor foutafhandeling in packages
  * v1.6 12-08-2016 SR  logging aanroep aangepast
	* v1.7 15-08-2016 HvK e_handled_exception toegevoegd (in spec) voor foutafhandeling in packages
  * v1.8 22-08-2016 SR  get_enkelvoud en get_meervoud functie aangemaakt en gegenereerde_meldingstekst aangepast naar get tapi functies ipv bra tabel
  * v1.9 30-09-2016 SR  gegenereerde_meldingstekst obv user_constraints tabel
  * v1.10 22-12-2016 SR algemene errorafhandeling aangepast ivm nieuwe alg_meldingen_beheer
  * v1.11 23-01-2017 SR raise_application_errors niet loggen
  * v1.12 03-02-2017 sr not is_common_runtime_error ook loggen en params ook loggen bij bekende errors
  * v1.13 17-02-2017 sr help_tekst bij toon_error ook meegeven met bij de error door g_help_tekst
  * v1.14 22-03-2017 mho apex_error_handling: meer structuur om type foutmelding te bepalen
  * v1.15 06-04-2017 mho get_ajax_melding ook langs apex_error_handling sturen
  * v1.16 10-04-2017 sr  g_tekst vullen bij foutmeldingen voor het geval apex later nog een keer een raise doet
  * v1.17 25-04-2017 mho apex_error_handling -> log_params: gebruik in out parameter
	*****************************************************************************/

  c_package_naam    constant varchar2(30) := 'alg_error';
  c_versie          constant varchar2(15) := '1.17';
  g_scope           varchar2(1000);
  g_log_alle_errors boolean := false;
  g_tekst           alg_meldingteksten.tekst%type;
  g_help_tekst      alg_meldingteksten.help_tekst%type;
  --
  type vmldg_tekst_type is record(code            alg_meldingen.code%type
                                 ,soort           alg_meldingen.soort%type
                                 ,ind_logging     alg_meldingen.ind_logging%type
                                 ,tekst           alg_meldingteksten.tekst%type
                                 ,help_tekst      alg_meldingteksten.help_tekst%type);

  type dmnw_pk_type is record(nr alg_domeinwaarden.nr%type);

  subtype error_type is varchar2(30);

  gc_err_apex_internal_apex   constant error_type := 'apex_internal_error';
  gc_err_apex_common_runtime  constant error_type := 'apex_common_runtime_error';
  gc_err_apex_other           constant error_type := 'gc_err_apex_other';
  gc_err_plsql_predefined     constant error_type := 'plsql_predefined_error';
  gc_err_plsql_constraint     constant error_type := 'plsql_constraint_error';
  gc_err_plsql_user_defined   constant error_type := 'plsql_user_defined_error';
  gc_err_plsql_non_predefined constant error_type := 'plsql_non_predefined_error';

  function package_naam_versie return varchar2
  is
  begin
    return c_package_naam||'-'||c_versie;
  end package_naam_versie;

  procedure set_scope(p_scope in varchar2)
  /*****************************************************************************
  * Afwijkende scope zetten. Bijvoorbeeld om te koppelen aan de queue
  *****************************************************************************/
  is
    l_scope  constant varchar2(256) := c_package_naam||'.set_scope';
    l_params logger.tab_param;
  begin
    alg_log.append_param(p_params => l_params, p_name => 'p_scope', p_val => p_scope);
    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'Start', p_scope => l_scope, p_params => l_params);
    g_scope := p_scope;
    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'End', p_scope => l_scope);
  end set_scope;

  function is_display_inline(p_component_id in number) return boolean
  /*****************************************************************************
  *
  *****************************************************************************/
  is
    cursor c_region(b_component_id number)
    is
      select 1
        from apex_application_page_regions aapr
       where aapr.region_id                   = b_component_id
         and substr(aapr.source_type_code,-5) = 'QUERY';

    l_scope  constant varchar2(256) := c_package_naam||'.is_display_inline';
    l_params logger.tab_param;
    l_found  pls_integer;
    l_result boolean;
  begin
    alg_log.append_param(p_params => l_params, p_name => 'p_component_id', p_val => p_component_id);
    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'Start', p_scope => l_scope, p_params => l_params);
    open c_region(b_component_id => p_component_id);
    fetch c_region into l_found;
    close c_region;
    l_result := nvl(l_found,0) = 1;
    alg_log.append_param(p_params => l_params, p_name => 'l_result', p_val => l_result);
    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'End', p_scope => l_scope, p_params => l_params);
    return l_result;
  end is_display_inline;

  function strip_ora_code(p_tekst in varchar2) return varchar2
  /*****************************************************************************
  *
  *****************************************************************************/
  is
  begin
    if substr(p_tekst,1,4) = 'ORA-' then
      return substr(p_tekst,12);
    else
      return p_tekst;
    end if;
  end strip_ora_code;


  function is_predefined_error(p_ora_code in number) return boolean
  /*****************************************************************************
  * Alle predefined errors staan in sys.standard
  *****************************************************************************/
  is

  begin

    execute immediate
      'declare
        predefined_error exception;
        pragma exception_init(predefined_error, ' || to_char(p_ora_code) || ');
       begin
        raise predefined_error;
       end;';

  exception
    when CURSOR_ALREADY_OPEN
        or DUP_VAL_ON_INDEX
        or TIMEOUT_ON_RESOURCE
        or INVALID_CURSOR
        or NOT_LOGGED_ON
        or LOGIN_DENIED
        or NO_DATA_FOUND
        or ZERO_DIVIDE
        or INVALID_NUMBER
        or TOO_MANY_ROWS
        or STORAGE_ERROR
        or PROGRAM_ERROR
        or VALUE_ERROR
        or ACCESS_INTO_NULL
        or COLLECTION_IS_NULL
        or SUBSCRIPT_OUTSIDE_LIMIT
        or SUBSCRIPT_BEYOND_COUNT
        or ROWTYPE_MISMATCH
        or SYS_INVALID_ROWID
        or SELF_IS_NULL
        or CASE_NOT_FOUND
        or USERENV_COMMITSCN_ERROR
        or NO_DATA_NEEDED
      then return true;
    when others
      then return false;


  /**/

  end is_predefined_error;

  function is_constraint_error(p_ora_code in number) return boolean
  /*****************************************************************************
  * Alle predefined errors staan in sys.standard
  *****************************************************************************/
  is

  begin

    return p_ora_code in (-1, -2091, -2290, -2291, -2292);

  end is_constraint_error;

  function is_user_defined_error(p_ora_code in number) return boolean
  /*****************************************************************************
  * Alle predefined errors staan in sys.standard
  *****************************************************************************/
  is

  begin

    return p_ora_code between -20999 and -20000;

  end is_user_defined_error;


  function get_error_type(p_error apex_error.t_error) return error_type
  /*****************************************************************************
  * Er zijn 6 type foutmeldingen die allen op hun eigen manier gelogd en vertaald moeten worden
  *****************************************************************************/
  is

    l_error_type    error_type;
    e_stop          exception;

  begin

    if p_error.is_internal_error and not p_error.is_common_runtime_error and p_error.ora_sqlcode is null then

      l_error_type := gc_err_apex_internal_apex;
      raise e_stop;

    end if;

    if p_error.is_common_runtime_error then

      l_error_type := gc_err_apex_common_runtime;
      raise e_stop;

    end if;

    if p_error.ora_sqlcode is not null then

      if is_constraint_error(p_error.ora_sqlcode) then

        l_error_type := gc_err_plsql_constraint;

      elsif is_predefined_error(p_error.ora_sqlcode) then

        l_error_type := gc_err_plsql_predefined;

      elsif is_user_defined_error(p_error.ora_sqlcode) then

        l_error_type := gc_err_plsql_user_defined;

      else

        l_error_type := gc_err_plsql_non_predefined;

      end if;

      raise e_stop;

    end if;

    if l_error_type is null then

      l_error_type := gc_err_apex_other;

    end if;

    return l_error_type;

  exception
    when e_stop then
      return l_error_type;

  end get_error_type;

  function get_ora_code(p_ora_sqlcode number) return alg_meldingen.ora_code%type
  /*****************************************************************************
  * Formatteer foutnr als tekst
  *****************************************************************************/
  is
  begin

    return 'ORA-'||lpad(abs(p_ora_sqlcode),5,0);

  end get_ora_code;

  function apex_error_handling(p_error  in apex_error.t_error
                              ,p_prefix in varchar2 default null) return apex_error.t_error_result
  /******************************************************************************
  * Functie die als Error Handling Function wordt gebruikt in de Application
  * definition in de Apex applicatie(s)
  ******************************************************************************/
  is
    l_scope           constant varchar2(61) := c_package_naam||'.apex_error_handling';
    l_params          logger.tab_param;
    l_result          apex_error.t_error_result;

    l_error_type      error_type;

    l_tekst           alg_meldingteksten.tekst%type;
    l_help_tekst      alg_meldingteksten.help_tekst%type;
    l_reference_id    number;
    l_constraint_name varchar2(255);
    l_ora_code        alg_meldingen.ora_code%type;
    l_log_id          varchar2(256);

    procedure log_params(
      p_error   in apex_error.t_error
    , p_scope   in varchar2
    -- out
    , p_params  in out logger.tab_param
    )  is
    begin
      alg_log.append_param(p_params => p_params, p_name => 'p_error.message', p_val => p_error.message);
      alg_log.append_param(p_params => p_params, p_name => 'p_error.apex_error_code', p_val => p_error.apex_error_code);
      alg_log.append_param(p_params => p_params, p_name => 'p_error.is_internal_error', p_val => p_error.is_internal_error);
      alg_log.append_param(p_params => p_params, p_name => 'p_error.is_common_runtime_error', p_val => p_error.is_common_runtime_error);
      alg_log.append_param(p_params => p_params, p_name => 'p_error.display_location', p_val => p_error.display_location);
      alg_log.append_param(p_params => p_params, p_name => 'p_error.ora_sqlcode', p_val => p_error.ora_sqlcode);
      alg_log.append_param(p_params => p_params, p_name => 'p_error.ora_sqlerrm', p_val => p_error.ora_sqlerrm);
      alg_log.append_param(p_params => p_params, p_name => 'p_error.additional_info', p_val => p_error.additional_info);
      alg_log.append_param(p_params => p_params, p_name => 'p_error.region_id', p_val => p_error.region_id);
      alg_log.append_param(p_params => p_params, p_name => 'p_error.page_item_name', p_val => p_error.page_item_name);
      alg_log.append_param(p_params => p_params, p_name => 'p_error.error_backtrace', p_val => substr(p_error.error_backtrace,1, 200));
      alg_log.append_param(p_params => p_params, p_name => 'p_error.error_statement', p_val => substr(p_error.error_statement,1, 200));
      alg_log.append_param(p_params => p_params, p_name => 'p_error.component.id', p_val => p_error.component.id);
      alg_log.append_param(p_params => p_params, p_name => 'p_error.component.name', p_val => p_error.component.name);
      alg_log.log_information(p_package_naam => c_package_naam, p_text => 'Start', p_scope => l_scope, p_params => p_params);
    end log_params;

    procedure zet_display_location(
      p_error_type  in error_type
      --
    , p_result      in out apex_error.t_error_result
    ) is

      e_verkeerde_type  exception;

    begin

      if p_error_type in (gc_err_apex_internal_apex, gc_err_apex_common_runtime) then
        raise e_verkeerde_type;
      end if;

      if l_result.display_location = apex_error.c_on_error_page then

        l_result.display_location := apex_error.c_inline_in_notification;

      end if;

    exception
      when e_verkeerde_type then
        null;

    end zet_display_location;

  begin

    log_params(p_error, l_scope, l_params);

    -- Initaliseer de output
    l_result  := apex_error.init_error_result(p_error => p_error);

    -- Wat voor foutmelding betreft het?
    l_error_type := get_error_type(p_error);
    l_ora_code := get_ora_code(p_error.ora_sqlcode);

    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'type_error = ' || l_error_type, p_scope => l_scope);

    -- Bepaal welke melding uiteindelijk aan de gebruiker getoond moet worden (tekst en helptekst)
    if l_error_type = gc_err_apex_internal_apex then

      -- Normaal gesproken alleen loggen, behalve uitgezonderde apex_error_codes en uitgezonderde ora_sqlcodes
      l_result.message :=
        case p_error.apex_error_code
             when 'APEX.PAGE.DUPLICATE_SUBMIT' then 'Er is een fout opgetreden. Waarschijnlijk is dit ontstaan door een dubbelklik.'
             else 'Er is een onbekende fout opgetreden. Raadpleeg eventueel de servicedesk en vermeld de foutcode.'
         end;

      l_result.additional_info := null;
      
      alg_meldingen_beheer.log_melding(
        p_package_naam => c_package_naam
      , p_params       => l_params
      , p_soort        => alg_meldingen_beheer.gc_soort_error
      , p_tekst        => l_result.message
      );

    elsif l_error_type = gc_err_apex_common_runtime then

      -- Dit soort fouten wel tonen aan gebruiker en ook loggen
      alg_meldingen_beheer.log_melding(
        p_package_naam => c_package_naam
      , p_params       => l_params
      , p_soort        => alg_meldingen_beheer.gc_soort_error
      , p_tekst        => l_result.message
      );

    elsif l_error_type = gc_err_plsql_predefined then

      -- Dit soort meldingen hebben een vaste tekst, voor deze ora-code kan een melding bestaan
      alg_meldingen_beheer.bepaal_melding(
        p_ora_code        => l_ora_code
      , p_constraint_naam => null
      , p_melding_orig    => p_error.message
      , p_params          => l_params
      -- out
      , p_tekst           => l_result.message
      , p_help_tekst      => l_result.additional_info
      );

    elsif l_error_type = gc_err_plsql_constraint then

      -- Bepaal de melding op basis van de constraint name
      alg_meldingen_beheer.bepaal_melding(
        p_ora_code        => l_ora_code
      , p_constraint_naam => apex_error.extract_constraint_name(p_error => p_error)
      , p_melding_orig    => strip_ora_code(apex_error.get_first_ora_error_text(p_error => p_error))
      , p_params          => l_params
      -- out
      , p_tekst           => l_result.message
      , p_help_tekst      => l_result.additional_info
      );

    elsif l_error_type = gc_err_plsql_user_defined then

      -- User defined wil zeggen dat de melding via raise_application_error al een gebruiksvriendelijke melding heeft
      l_result.message := strip_ora_code(apex_error.get_first_ora_error_text(p_error => p_error));
      l_result.additional_info := g_help_tekst;

    elsif l_error_type = gc_err_plsql_non_predefined then

      -- Dit soort fouten alleen teruggeven aan gebruikers als ze bestaan, en altijd loggen
      alg_meldingen_beheer.bepaal_melding(
        p_ora_code       => l_ora_code
      , p_constraint_naam => null
      , p_melding_orig    => p_error.message
      , p_params          => l_params
      -- out
      , p_tekst           => l_result.message
      , p_help_tekst      => l_result.additional_info
      );


    end if;


    -- Waar en hoe tonen we de foutmelding?
    -- Er zijn 5 varianten:
    -- 1. error_page (c_on_error_page)
    -- 2. page notification (c_inline_in_notification)
    -- 3. bij page item (c_inline_with_field)
    -- 4. zowel page notification als page item (c_inline_with_field_and_notif)
    -- 5. Inline in region (display_location null)

    zet_display_location(
      p_error_type  => l_error_type
    , p_result      => l_result
    );

    -- Als de melding eerder al is bepaald en gezet in de globale variabele gaan we deze gebruiken
    if g_tekst is not null then
      l_result.message := g_tekst;
    else
      -- Als de g_tekst nog niet gezet is kan het handig zijn om hem te bewaren in het geval dat de foutmelding
      -- vervolgens weer door Apex afgehandeld wordt. Dit komt voor in het geval van een AJAX server error
      g_tekst := l_result.message;
    end if;

    -- Alleen bij page notification de additional info ook toevoegen
    if l_result.display_location = apex_error.c_inline_in_notification then

      l_result.message := '<message>'||l_result.message||'</message> <info>'||l_result.additional_info||'</info>';

      -- Verwijder voor de zekerheid de additional_info zodat het ook in toekomstige versies geen probleem oplevert.
      l_result.additional_info := null;

    end if;

    -- Vervang substitution strings
    l_result.message := replace(l_result.message, '#LOG_ID#', 1);

    alg_log.append_param(p_params => l_params, p_name => 'l_result.message', p_val => l_result.message);
    alg_log.append_param(p_params => l_params, p_name => 'l_result.additional_info', p_val => l_result.additional_info);
    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'End', p_scope => l_scope, p_params => l_params);

    return l_result;

  end apex_error_handling;

  procedure toon_melding(p_package_naam in varchar2
                        ,p_code         in alg_meldingen.code%type
                        ,p_param1       in varchar2 default null
                        ,p_param2       in varchar2 default null
                        ,p_param3       in varchar2 default null
                        ,p_param4       in varchar2 default null
                        ,p_param5       in varchar2 default null
                        ,p_scope        in varchar2 default null
                        ,p_params       in logger.tab_param default logger.gc_empty_tab_param)
  /******************************************************************************
  * Procedure aangeroepen wordt bij exception handling van bekende foutmeldingen
  ******************************************************************************/
  is
    l_scope      constant varchar2(61) := c_package_naam||'.toon_melding';
    l_params     logger.tab_param;
    l_tekst      alg_meldingteksten.tekst%type;
  begin
    alg_log.append_param(p_params => l_params, p_name => 'p_package_naam', p_val => p_package_naam);
    alg_log.append_param(p_params => l_params, p_name => 'p_code', p_val => p_code);
    alg_log.append_param(p_params => l_params, p_name => 'p_param1', p_val => p_param1);
    alg_log.append_param(p_params => l_params, p_name => 'p_param2', p_val => p_param2);
    alg_log.append_param(p_params => l_params, p_name => 'p_param3', p_val => p_param3);
    alg_log.append_param(p_params => l_params, p_name => 'p_param4', p_val => p_param4);
    alg_log.append_param(p_params => l_params, p_name => 'p_param5', p_val => p_param5);
    alg_log.append_param(p_params => l_params, p_name => 'p_scope', p_val => p_scope);
    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'Start', p_scope => l_scope, p_params => l_params);

    alg_meldingen_beheer.bepaal_melding(p_code         => p_code
                                       ,p_package_naam => p_package_naam
                                       ,p_scope        => nvl(g_scope,p_scope)
                                       ,p_params       => p_params
                                       ,p_param1       => p_param1
                                       ,p_param2       => p_param2
                                       ,p_param3       => p_param3
                                       ,p_param4       => p_param4
                                       ,p_param5       => p_param5
                                       ,p_tekst        => l_tekst
                                       ,p_help_tekst   => g_help_tekst);
    g_tekst := l_tekst;

    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'End', p_scope => l_scope);

    -- De foutmelding moet geraised worden maar de melding zelf hoeft niet opnieuw bepaald te worden
    raise_application_error(gc_toon_error_nr, nvl(l_tekst,'Er is een onbekende fout opgetreden: '||p_code));

  end toon_melding;

  /*****************************************************************************
  * Override functie van de toon_melding voor het geval geen gebruik gemaakt
  * wordt van de meldingen functionaliteit van VGB
  * Hierdoor kunnen we er later altijd nog voor kiezen iets met deze meldingen
  * te doen.
  *****************************************************************************/
  procedure toon_melding(p_sqlcode in varchar2
                        ,p_sqlerrm in varchar2)
  is
    l_scope  constant varchar2(256) := c_package_naam||'.toon_melding';
    l_params logger.tab_param;
  begin
    alg_log.append_param(p_params => l_params, p_name => 'p_sqlcode', p_val => p_sqlcode);
    alg_log.append_param(p_params => l_params, p_name => 'p_sqlerrm', p_val => p_sqlerrm);
    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'Start', p_scope => l_scope, p_params => l_params);
    raise_application_error(p_sqlcode, p_sqlerrm);
    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'End', p_scope => l_scope);
  end toon_melding;

  function get_constraint_name(p_sqlerrm varchar2) return varchar2
  /******************************************************************************
  * Naam van de constraint ophalen uit de error melding
  ******************************************************************************/
  is
    l_constraint_name varchar2(255);
  begin
    l_constraint_name := ltrim(rtrim(regexp_substr(p_sqlerrm, '\(([^).]+\.[^).]+)\)'), ')'), '(');
    return substr(l_constraint_name,instr(l_constraint_name,'.')+1);
  exception
    when others
    then
      return null;
  end get_constraint_name;

  function get_ajax_melding(p_ora_sqlcode varchar2
                           ,p_ora_sqlerrm varchar2) return varchar2
  /******************************************************************************
  * Rollback uitvoeren en fout_afhandelen aanroepen met de jusite parameters
  * Aanroep in exception: htp.prn(alg_err.get_ajax_melding(sqlcode,sqlerrm));
  ******************************************************************************/
  is
    l_scope           constant varchar2(61) := c_package_naam||'.get_ajax_melding';
    l_params          logger.tab_param;

    l_error           apex_error.t_error;
    l_error_result    apex_error.t_error_result;

    l_constraint_name varchar2(255);
    l_tekst           alg_meldingteksten.tekst%type;
    l_help_tekst      alg_meldingteksten.help_tekst%type;
  begin
    alg_log.append_param(p_params => l_params, p_name => 'p_ora_sqlcode', p_val => p_ora_sqlcode);
    alg_log.append_param(p_params => l_params, p_name => 'p_ora_sqlerrm', p_val => p_ora_sqlerrm);
    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'Start', p_scope => l_scope, p_params => l_params);

    rollback;

    -- Bouw apex error
    l_error.message                  := p_ora_sqlerrm;
    l_error.additional_info          := 'Foutmelding vanuit een AJAX process (opgevangen door alg_error.get_ajax_melding)';
    l_error.display_location         := apex_error.c_inline_in_notification;
    l_error.is_internal_error        := false;
    l_error.is_common_runtime_error  := false;
    l_error.ora_sqlcode              := p_ora_sqlcode;
    l_error.ora_sqlerrm              := p_ora_sqlerrm;

    l_error_result := apex_error_handling(p_error => l_error);

    alg_log.append_param(p_params => l_params, p_name => 'l_error_result.message', p_val => l_error_result.message);
    alg_log.append_param(p_params => l_params, p_name => 'l_error_result.additional_info', p_val => l_error_result.additional_info);
    alg_log.append_param(p_params => l_params, p_name => 'l_error_result.display_location', p_val => l_error_result.display_location);
    alg_log.append_param(p_params => l_params, p_name => 'l_error_result.page_item_name', p_val => l_error_result.page_item_name);
    alg_log.append_param(p_params => l_params, p_name => 'l_error_result.column_alias', p_val => l_error_result.column_alias);
    alg_log.log_information(p_package_naam => c_package_naam, p_text => 'End', p_scope => l_scope, p_params => l_params);


    -- als een melding is afgevangen en gegereraised dan kan er een ora-code voor de melding staan
    -- in dat geval halen we die eraf
    return strip_ora_code(l_error_result.message);

  end get_ajax_melding;

/*******************************************************************************
 De volgende procedures en functies zijn voor de foutafhandeling in packages:
 err_melding: wrapper van dbms_utility.format_error_stack
 err_melding_stack: wrapper rond format_error_backtrace foutmelding inclusief regelnrs
 err_info: levert gestructureerde informatie van een foutmelding via type info_rectype
 toon_info: overloaded functie die informatie toont adhv de meegegeven backtrace-info
********************************************************************************/
  function err_melding return varchar2
  is
  begin
    return dbms_utility.format_error_stack;
  end err_melding;

 function err_melding_stack return varchar2
  is
  begin
    return dbms_utility.format_error_backtrace;
  end err_melding_stack;

  function err_info (p_backtrace in varchar2) return info_rectype
  is
    r_info    info_rectype;
    l_start   pls_integer;
    l_eind    pls_integer;
    l_lengte  pls_integer;
  begin
    r_info.melding     := err_melding;
    -- de schemanaam staat tussen de eerste dubbel-quote(") en de punt(.)
    l_start := instr(p_backtrace,'"') + 1;
    l_eind  := instr(p_backtrace,'.');
    l_lengte := l_eind - l_start;
    r_info.proc_schema := substr(p_backtrace,l_start, l_lengte);
    --
    -- de naam van de procedure of functie staat tussen de punt en een dubbele quote
    l_start := instr(p_backtrace,'.') + 1;
    l_eind  := instr(p_backtrace,'"',l_start);
    l_lengte := l_eind - l_start;
    r_info.proc_naam   := substr(p_backtrace,l_start, l_lengte);
    --
    -- het regelnummer staat vlak voor het einde van de regel
    -- de regexp-match-parameters betekenen het volgende: m = multiline, i = case-insensitive
    -- multiline is nodig om de "$" het eind van een regel te laten betekenen, anders is het het eind van de tekst
    r_info.regelnr := to_number(regexp_substr(p_backtrace, '[[:digit:]]+$',1,1,'mi'));
-- alle regelnummers:
--    i := 1;
--		l_regelnrs := regexp_substr(p_backtrace, '[[:digit:]]+$',1,i,'mi');
--		while l_regelnrs is not null
--		loop
--		  i := i + 1;
--		  l_regelnrs := rtrim(l_regel_nr||', '||regexp_substr(p_backtrace, '[[:digit:]]+$',1,i,'mi'),', ');
--		end loop;
		--
    return r_info;
  end err_info;

  function toon_info (p_info in info_rectype, p_toon_schema in boolean := false) return varchar2
  is
    l_melding varchar2(4000);
  begin
    if p_toon_schema
    then
      return 'Het programma '||p_info.proc_naam||' in het schema '||p_info.proc_schema||
             ' ging mis bij regel '||p_info.regelnr||' met de volgende foutmelding: '||chr(10)||
             p_info.melding;
    else
      return 'Het programma '||p_info.proc_naam||' ging mis bij regel '||p_info.regelnr||
             ' met de volgende foutmelding: '||chr(10)||p_info.melding;
    end if;
  end toon_info;

  function toon_info (p_backtrace in varchar2, p_toon_schema in boolean := false) return varchar2
  is
    l_info info_rectype;
  begin
    l_info := err_info(p_backtrace);
    return toon_info(l_info, p_toon_schema);
  end toon_info;

  function info2string(p_info info_rectype) return varchar2
  /*****************************************************************************
	* Deze functie levert op xml-achtige wijze informatie over de foutmelding
	*****************************************************************************/
	is
    -- formaat string: "<regelnrs>nr,nr,nr</regelnrs>,<schema>naam</schema>,<proc>naam</proc>msg
    l_string varchar2(4000);
    l_regelnrs varchar2(100);
  begin
    l_regelnrs := ltrim(rtrim(regexp_substr(p_info.melding,'<regelnrs>[[:digit:]]+[,[[:digit:]]+]*</regelnrs>'),'</regelnrs>'),'<regelnrs>');
    l_string := '<regelnrs>'||ltrim(l_regelnrs||',',',')||p_info.regelnr||'</regelnrs>';
    if l_regelnrs is null -- diepste "raise" eerste regelnummer wordt hier gevonden
    then
      l_string := l_string||'<schema>'||p_info.proc_schema||'</schema>'||'<proc>'||p_info.proc_naam||'</proc>'||p_info.melding;
    else
      l_string := l_string||substr(p_info.melding, instr(p_info.melding,'<schema>'));
    end if;
    return l_string;
  end info2string;

  function toon_info(p_toon_schema in boolean := false) return varchar2
  is
  begin
		--return info2string(err_info(err_melding_stack));
    return toon_info(err_melding_stack, p_toon_schema);
  end toon_info;

end alg_error;
/


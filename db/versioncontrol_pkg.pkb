create or replace package body versioncontrol_pkg is

  type version_no_attributes_rt is record (
    main_version number
  , sub_version number
  , postfix varchar2(20)
  );
  
  ------------------------------------------------------------------------------
  -- function decode_version_no
  ------------------------------------------------------------------------------
  function decode_version_no(
    p_version_nr in varchar2
  ) return version_no_attributes_rt
  is

    l_version_attributes  version_no_attributes_rt;

  begin

    /*

      The version is always in spec and has this form

      v1.1
      V1.01
      v1.01a

      We can devide the version into 3 attributes (wikipedia):
      - main version: 1 (to_number function)
      - sub version: 1 (to_number function)
      - postfix: a (always alpha chars)

    */

    l_version_attributes.main_version := regexp_substr(p_version_nr, '(\d+)');
    l_version_attributes.sub_version := regexp_substr(p_version_nr, '(\d+)',1, 2);
    l_version_attributes.postfix := regexp_substr(p_version_nr, '\D+',1, 3);

    return l_version_attributes;

  end decode_version_no;
  


  ------------------------------------------------------------------------------
  -- function get_user_object
  ------------------------------------------------------------------------------  
  function get_user_object (
    p_object_name   varchar2
  , p_object_type   varchar2
  , p_owner         varchar2  default user  
  ) return user_objects%rowtype 
  is
  
    l_rec user_objects%rowtype;
  
  begin
  
    select * into l_rec
      from user_objects
     where object_name = upper(p_object_name)
       and object_type like '%' || upper(p_object_type) || '%'
       and rownum = 1;
       
    return l_rec;
  
  end get_user_object;

  ------------------------------------------------------------------------------
  -- function rate_version_number
  ------------------------------------------------------------------------------
  function rate_version_number(
    p_version_nr in varchar2
  )  return number
  is

    l_version_attributes  version_no_attributes_rt;
    l_rating  number;

  begin

    l_version_attributes := decode_version_no(p_version_nr);

    l_rating := nvl((l_version_attributes.main_version * 1000),0);
    l_rating := l_rating + nvl((l_version_attributes.sub_version * 100),0);
    l_rating := l_rating + nvl((ascii(l_version_attributes.postfix) / 100),0);

    return l_rating;

  end rate_version_number;

  ------------------------------------------------------------------------------
  -- function check_object_version
  ------------------------------------------------------------------------------
  function check_object_version (
    p_version_nr    varchar2
  , p_object_name   varchar2
  , p_object_type   varchar2
  , p_var_name      varchar2
  , p_owner         varchar2  default user
  ) return number is

    l_version_nr varchar2(20);
    
    l_user_obj  user_objects%rowtype;

    l_curr      number;
    l_new       number;

    l_ind       number;

  begin
  
    begin
      l_user_obj := get_user_object(p_object_name, p_object_type, p_owner);
    exception
      when no_data_found then
        return -1;
    end;

    select trim( both '''' from regexp_substr(text, '''(.*)''')) version_nr into l_version_nr
      from user_source
     where name = l_user_obj.object_name
       and type like '%' || upper(p_object_type) || '%'
       and lower(text) like '%' || lower(p_var_name) || '%:=%';
       
    l_curr := rate_version_number(l_version_nr);
    l_new := rate_version_number(p_version_nr);
    
    dbms_output.put_line(rate_version_number(p_version_nr));

    if l_curr <= l_new then
      l_ind := 1;
    else
      l_ind := 0;
    end if;

    return l_ind;

  exception
    when no_data_found then
      return null;

  end check_object_version;

end versioncontrol_pkg;
/


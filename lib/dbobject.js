/*

 Library to work with Oracle Database objects

 */

(function(){

  var DriverManager = Java.type("java.sql.DriverManager"),
      ScriptExecutor = Java.type("oracle.dbtools.raptor.newscriptrunner.ScriptExecutor"),
      DBUtil = Java.type("oracle.dbtools.db.DBUtil"),
      jdbc = conn.getMetaData().getURL(),
      Thread = Java.type("java.lang.Thread");

  var file = load(config.baseDir + "lib/file.js"),
      output = load(config.baseDir + "lib/output.js");

  var gChecks = [],
      gValidExtensions = [],
      gErrors = [],
      gLogDir = config.releaseLogDir,
      gLogFile = "log.txt",
      gByteOutputStream,
      gOutputMethod = output.outputMethods.string,
      gOutputMethods = {};

  // Load valid extensions
  for (idx in config.objectTypes) {
    gValidExtensions.push(config.objectTypes[idx].extension);
  }

  // Add all checks to be executed
  _addCheck({
    name: "Check name of file against db object",
    run: function(options){
      var err = false;
      options.subObjects.forEach(function(object){

        var createLine = object.content.filter(function(line){
          var re = /(create).*(package|view|type|synonym|function|procedure|trigger)/
          return re.test(line.toLowerCase());
        })[0];

        if (!createLine) {

          err = object.name + ' has wrong format of create object statement.';
          return;
        }
        if (createLine.toLowerCase().indexOf(object.name.toLowerCase()) == -1) {
        print(createLine.toLowerCase());
        print(object.name.toLowerCase());
          err = object.name + ' has different object name. check ' + object.file.fullPath;
        }
      });
      return err;
    }
  });

  _addCheck({
    name: "New versionNo >= current versionNo",
    run: function(options){

      // Objects always one or two objects (spec & body)
      var versionNo;
      options.subObjects.forEach(function(object){
        if (object.versionNo) {
          versionNo = object.versionNo;
        }
      });

      if (options.uniqueObject.versioning) {

        if (!versionNo) {
          return options.uniqueObject.type + ' ' + options.uniqueObject.name + ' has no versionNo.';
        }

        var indGeldig = options.connection.util.executeReturnOneCol('select versioncontrol_pkg.check_object_version(p_version_nr => :versionNo, p_object_name => :objectName, p_object_type=> :objectType) from dual', {
          "versionNo": versionNo,
          "objectName": options.uniqueObject.name,
          "objectType": options.uniqueObject.type
        });

        if (!indGeldig) {
          return 'Object : ' + options.uniqueObject.name + ' has invalid versionNo: ' + versionNo;
        }
      }

      return false;
    }
  });

  // Set different outputMethods
  _addOutputMethod({
    method: output.outputMethods.default,
    setOutput: function(sqlcl2) {
      output.setDefaultOutput(sqlcl2);
    }
  });

  _addOutputMethod({
    method: output.outputMethods.file,
    setOutput: function(sqlcl2) {
      output.setFileOutput(sqlcl2, gLogFile);
    }
  });

  _addOutputMethod({
    method: output.outputMethods.string,
    setOutput: function(sqlcl2) {
      gByteOutputStream = output.setStringOutput(sqlcl2);
    }
  });

  function _addCheck(check){
    gChecks.push(check);
  };

  function _addOutputMethod(outputMethod){
    gOutputMethods[outputMethod.method] = outputMethod.setOutput;
  };

  function _runCheck(check, options) {
    var err = check.run(options);

    if (err) {

      gErrors.push(err);
      ctx.write('\n');
      sqlcl.setStmt('prompt @|bg_red Error: ' + check.name + '|@');
      sqlcl.run();
      sqlcl.setStmt('prompt @|bg_red ' + err + '|@');
      sqlcl.run();
    }
  };

  function _getObjectTypeByExtension(extension) {
    for (idx in config.objectTypes) {
      if (config.objectTypes[idx].extension == extension) {
        return config.objectTypes[idx];
      }
    }
  };

  function _getVersionNo(content){

    var versionLine = content.filter(function(line){
      return (line.toLowerCase().indexOf('version_no') > -1);
    })[0];

    var re = /'(.*)'/;
    var result = re.exec(versionLine);

    if (result instanceof Array) {
      return result[1];
    }

    return false;

  };

  function _fileToDBObject(inputFile) {
    var content = inputFile.getContent(),
        objectType = _getObjectTypeByExtension(inputFile.extension),
        schema = inputFile.fileParts[inputFile.fileParts.length - 2],
        versionNo = false;

    if (objectType.versioning) {
      versionNo = _getVersionNo(content);
    }

    return {
      file: inputFile,
      schema: schema,
      name: inputFile.name,
      type: objectType.dbType,
      content: content,
      versioning: objectType.versioning,
      versionNo: versionNo,
      runStatement: function(connection){
        connection.ctx.write('\nExecuting ' + inputFile.fullPath + '\n');
        connection.sqlcl.setStmt('cd ' + inputFile.path);
        connection.sqlcl.run();
        connection.sqlcl.setStmt('@ "' + inputFile.fileNameWithExtension + '";');
        connection.sqlcl.run();
      }
    };
  };

  function _getDistinctSchemas(DBObjects){
    var schemas = [];
    var currentSchema;

    DBObjects.forEach(function(object) {
      if (currentSchema !== object.schema) {
        schemas.push(object.schema);
        currentSchema = object.schema;
      }
    });

    return schemas;
  };

  function _getDBObjectsPerSchema(DBObjects, schema){
    return DBObjects.filter(function(object){
      return object.schema === schema;
    });
  };

  function _setOutputMethod(sqlcl2){
    gOutputMethods[gOutputMethod](sqlcl2);
  };

  function _newConnection(schema, showInfo) {
    var user = schema.toLowerCase();
    var pass = user;
    var conn2 = DriverManager.getConnection(jdbc, user, pass);
    var sqlcl2 = new ScriptExecutor(conn2);
    var util2 = DBUtil.getInstance(conn2);

    _setOutputMethod(sqlcl2);
    //output.setFileOutput(sqlcl2, gLogFile);

    //var gByteOutputStream = output.setStringOutput(sqlcl2);

    ctx2 = sqlcl2.getScriptRunnerContext();

    sqlcl2.setStmt('set define off');
    sqlcl2.run();
    sqlcl2.setStmt('set scan off');
    sqlcl2.run();
    sqlcl2.setStmt('set sqlblanklines on');
    sqlcl2.run();
    /*sqlcl2.setStmt('whenever sqlerror exit');
    sqlcl2.run();*/

    if (showInfo) {
      ctx2.write('\n############################################\n');
      ctx2.write('\nChanging current schema to ' + schema + '\n');
      ctx2.write('\n############################################\n');
    }

    return {
      sqlcl: sqlcl2,
      util: util2,
      ctx: ctx2
    };
  };

  function _addForwardSlash(object){
    var forwardSlash = object.content.filter(function(line){
      // trim all spaces
      trimmedLine = line.replace(/\s/g,'');
      return trimmedLine === "/";
    })[0];

    if (!forwardSlash) {
      file.appendText(object.file.fullPath, "/")
    }
  };

  function _checkSchemaObjects(schema, DBObjects) {

    gErrors = [];

    // Create new connection for each schema
    var connection = _newConnection(schema, false),
        allObjects,
        uniqueObjects = [],
        subObjects,
        occurences;

    // Add missing trailing forward slash
    DBObjects.forEach(function(object){
      _addForwardSlash(object);
    });

    // Some objects belong together as specification and body
    allObjects = DBObjects.map(function(object){
      return {
        name: object.name,
        type: object.type,
        versioning: object.versioning
      };
    });

    allObjects.forEach(function(value, index, self){
      occurences = 0;
      for (idx in uniqueObjects) {
        if (uniqueObjects[idx].name ==  value.name && uniqueObjects[idx].type == value.type) {
          occurences++;
        }
      };

      if (occurences === 0) {
        uniqueObjects.push(value);
      }

    });

    // run all checks
    uniqueObjects.forEach(function(uniqueObject){

      subObjects = DBObjects.filter(function(object){
        return (object.name === uniqueObject.name && object.type === uniqueObject.type);
      });

      gChecks.forEach(function(check){
        _runCheck(check, {
          uniqueObject: uniqueObject,
          subObjects: subObjects,
          connection: connection
        });
      });
    });

  };

  function isDbObject(file){
    return (gValidExtensions.indexOf(file.extension) > - 1);
  };

  function checkObjects(dbObjectFiles){

    var dbObjects = dbObjectFiles.map(_fileToDBObject);

    // Get distinct schemas from all scripts
    var schemas = _getDistinctSchemas(dbObjects);

    // Checks objects first
    schemas.forEach(function(schema){

      var schemaObjects = _getDBObjectsPerSchema(dbObjects, schema);

      _checkSchemaObjects(schema, schemaObjects);

    });

    if (gErrors.length === 0) {
      ctx.write('\n');
      sqlcl.setStmt('prompt @|bg_green Check has completed succesfully|@');
      sqlcl.run();
    }

  };

  function installObjects(dbObjectFiles) {
    var dbObjects = dbObjectFiles.map(_fileToDBObject),
        schemas = _getDistinctSchemas(dbObjects),
        schemaObjects,
        connection,
        result = [];

    // Checks objects first
    schemas.forEach(function(schema){

      schemaObjects = _getDBObjectsPerSchema(dbObjects, schema);

      _checkSchemaObjects(schema, schemaObjects);

    });

    if (gErrors.length === 0) {

      // Run installation
      schemas.forEach(function(schema){

        schemaObjects = _getDBObjectsPerSchema(dbObjects, schema);

        // Create new connection for each schema
        connection = _newConnection(schema, true);

        // Run all scripts per schema
        schemaObjects.forEach(function(object){

          object.runStatement(connection);

        });

        if (gOutputMethod === output.outputMethods.string){
          result.push(output.getStringOutput(connection.sqlcl, gByteOutputStream));
        }

      });

      if (gOutputMethod === output.outputMethods.string){
        print(result.join('\n'));
        print("Writing output to logfile:", gLogFile);
        file.createFile(gLogFile, result.join('\n'));
      }


    }
  };

  function setLogFile(file) {
    gLogFile = gLogDir + file;
  };

  function getLogFile() {
    return gLogFile;
  };

  function setOutputMethod(outputMethod) {
    gOutputMethod = outputMethod;
  };

  return {
    isDbObject: isDbObject,
    checkObjects: checkObjects,
    installObjects: installObjects,
    setLogFile: setLogFile,
    getLogFile: getLogFile,
    setOutputMethod: setOutputMethod
  };

})();

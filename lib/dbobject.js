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
      output = load(config.baseDir + "lib/output.js"),
      server = load(config.baseDir + "lib/server.js"),
      application = load(config.baseDir + "lib/application.js");

  var gChecks = [],
      gValidExtensions = [],
      gErrors = [],
      gLogDir = config.releaseLogDir,
      gLogFile = "log.txt",
      gOutputMethod = config.releases.defaultOutputMethod,
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
          var regularExpression = /(create).*(package|view|type|synonym|function|procedure|trigger)/
          return regularExpression.test(line.toLowerCase());
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
      var version;
      options.subObjects.forEach(function(object){
        if (object.version) {
          version = object.version;
        }
      });

      if (options.uniqueObject.versioning) {

        if (!version) {
          return options.uniqueObject.type + ' ' + options.uniqueObject.name + ' has no versionNo.';
        }

        var valid = options.connection.util.executeReturnOneCol('select versioncontrol_pkg.check_object_version(p_version_nr => :versionNo, p_object_name => :objectName, p_object_type=> :objectType, p_var_name=> :variableName) from dual', {
          "versionNo": version.versionNo,
          "objectName": options.uniqueObject.name,
          "objectType": options.uniqueObject.type,
          "variableName": version.variableName
        });

        if (!valid || valid == 0) {
          return 'Object : ' + options.uniqueObject.name + ' has invalid versionNo: ' + version.versionNo;
        }
      }

      return false;
    }
  });

  // Set different outputMethods
  _addOutputMethod({
    method: output.outputMethods.default,
    setOutput: function(connection) {
      output.setDefaultOutput(connection.sqlcl);
    }
  });

  _addOutputMethod({
    method: output.outputMethods.file,
    setOutput: function(connection) {
      output.setFileOutput(connection.sqlcl, gLogFile);
    }
  });

  _addOutputMethod({
    method: output.outputMethods.string,
    setOutput: function(connection) {
      connection.byteOutputStream = output.setStringOutput(connection.sqlcl);
    }
  });

  _addOutputMethod({
    method: output.outputMethods.web,
    setOutput: function(connection) {
      connection.byteOutputStream = output.setWebOutput(connection.sqlcl);
    },
    init: function() {
      server.websocket.start(function() {

      });
    }
  });

  function _addCheck(check){
    gChecks.push(check);
  };

  function _addOutputMethod(outputMethod){
    gOutputMethods[outputMethod.method] = {};
    gOutputMethods[outputMethod.method].run = outputMethod.setOutput;

    gOutputMethods[outputMethod.method].init = function() {
      if (outputMethod.init){
        outputMethod.init();
      }

    };

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

  function _getVersion(content){

    var versionLine,
        regularExpression = /'(.*)'/,
        result,
        variableName;

    versionLine = content.filter(function(line){
      for (idx in config.releases.variableNames) {
        if (line.toLowerCase().indexOf(config.releases.variableNames[idx]) > -1) {
          variableName = config.releases.variableNames[idx];
          return true;
        }
      }
      return false;
    })[0];

    result = regularExpression.exec(versionLine);

    if (result instanceof Array) {

      return {
        versionNo: result[1],
        variableName: variableName
      };

    }
    return false;
  };

  function _fileToDBObject(inputFile) {
    var content = inputFile.getContent(),
        objectType = _getObjectTypeByExtension(inputFile.extension),
        schema = inputFile.fileParts[inputFile.fileParts.length - 2],
        version = false;

    if (objectType.versioning) {
      version = _getVersion(content);
    }

    return {
      file: inputFile,
      schema: schema,
      name: inputFile.name,
      type: objectType.dbType,
      content: content,
      versioning: objectType.versioning,
      version: version,
      runStatement: function(connection){
        connection.ctx.write('\nExecuting ' + inputFile.fullPath + '\n');
        connection.ctx.write('\nName ' + inputFile.name + '\n');
        connection.sqlcl.setStmt('cd ' + inputFile.path);
        connection.sqlcl.run();
        connection.sqlcl.setStmt('@ "' + inputFile.fileNameWithExtension + '";');
        connection.sqlcl.run();

        if (objectType.formalType) {
          var errors = connection.util.executeReturnList("select text from user_errors where name = upper(:name) and type = upper(:type) order by sequence", {
            name: inputFile.name,
            type: objectType.formalType
          });
          if (errors.length > 0) {
            connection.ctx.write('\nErrors: \n');
            errors.forEach(function(error){
              connection.ctx.write(error.TEXT + '\n');
            });
          }
        }
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

  function _setOutputMethod(connection){
    gOutputMethods[gOutputMethod].run(connection);
  };

  function _newConnection(schema, showInfo) {
    var user = schema.toLowerCase(),
        pass = user,
        conn2 = DriverManager.getConnection(jdbc, user, pass),
        sqlcl2 = new ScriptExecutor(conn2),
        util2 = DBUtil.getInstance(conn2);

    var connection = {
      sqlcl: sqlcl2,
      util: util2
    };

    _setOutputMethod(connection);

    connection.ctx = connection.sqlcl.getScriptRunnerContext();

    connection.sqlcl.setStmt('set define off');
    connection.sqlcl.run();
    connection.sqlcl.setStmt('set scan off');
    connection.sqlcl.run();
    connection.sqlcl.setStmt('set sqlblanklines on');
    connection.sqlcl.run();

    if (showInfo) {
      connection.ctx.write('\n############################################\n');
      connection.ctx.write('\nChanging current schema to ' + schema + '\n');
      connection.ctx.write('\n############################################\n');
    }

    return connection;
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
          result.push(output.getStringOutput(connection.sqlcl, connection.byteOutputStream));
        }

        if (gOutputMethod === output.outputMethods.web){
          result.push(output.getWebOutput(connection.sqlcl, connection.byteOutputStream));
        }

      });

      if (gOutputMethod === output.outputMethods.string){
        print(result.join('\n'));
        print("Writing output to logfile:", gLogFile);
        file.createFile(gLogFile, result.join('\n'));
        application.run('file', gLogFile);
      }

      if (gOutputMethod === output.outputMethods.web){
        print(result.join('\n'));
        print("Writing output to webpage");
        server.websocket.send(result.join('\n'));
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
    gOutputMethods[gOutputMethod].init();
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

/*

  Create new Database objects on the fly

*/
(function() {

  var utils = load(config.baseDir + "lib/utils.js"),
      file = load(config.baseDir + "lib/file.js"),
      application = load(config.baseDir + "lib/application.js");

  var gTemplatesFiles = {
    packageSpecification: {
      path: config.templateDir + "package_specification.sql",
      substitutions: function(data){
        return [
          {
            string: '#PACKAGE_NAME#',
            value: data.packageName
          },
          {
            string: '#DATE#',
            value: utils.dateString(new Date())
          },
          {
            string: '#INITIALS#',
            value: java.lang.System.getProperty("user.name")
          }
        ];
      }
    },
    packageBody: {
      path: config.templateDir + "package_body.sql",
      substitutions: function(data){
        return [
          {
            string: '#PACKAGE_NAME#',
            value: data.packageName
          }
        ];
      }
    }
  }



  function _getObjectByFormalType(formalType){

    for (idx in config.objectTypes) {
      if (config.objectTypes[idx].formalType && config.objectTypes[idx].formalType === formalType) {
        return config.objectTypes[idx];
      }
    };

  };

  function _nameIsValid(name) {
    return (typeof name === "string" && name.length <= config.addObjects.nameMaxLength);
  };

  function _fillTemplate(template, data) {

    var lines = file.getFileContent(template.path),
        substitutions = template.substitutions(data),
        content;

    content = lines.join('');

    substitutions.forEach(function(substitution) {
      content = content.replace(new RegExp(substitution.string, 'g'), substitution.value);
    });

    return content;

  };

  function _add(objectStatement, fileName){
    sqlcl.setStmt(objectStatement);
    sqlcl.run();
    file.createFile(fileName, objectStatement);
    application.run('file', fileName);
  };

  function package(name) {

    var packageName = name.toString(),
        specification,
        body;

    if(!_nameIsValid(packageName)){
      print("The name of the package is invalid");
      return false;
    }

    specification = _fillTemplate(gTemplatesFiles.packageSpecification, {
      packageName: packageName
    });

    body = _fillTemplate(gTemplatesFiles.packageBody, {
      packageName: packageName
    });

    _add(specification, config.addObjects.fileDir + packageName + "." + _getObjectByFormalType('PACKAGE').extension);
    _add(body, config.addObjects.fileDir + packageName + "." + _getObjectByFormalType('PACKAGE BODY').extension);

  };

  return {
    package: package
  }

})();

// Relplace this with your own configuration
var config = {
  version: "?v=" + Math.random().toString(36).substring(7),
  fileSeparator: java.io.File.separator,
  configDir: args[0],
  //baseDir: "https://raw.githubusercontent.com/mennooo/sqlcl/master",
  applications: {
    web: {
      name: "chrome",
      executable: "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe"
    },
    file: {
      name: "sqldeveloper",
      executable: "C:\\oracle\\sqldeveloper\\sqldeveloper.exe"
    }
  },
  releases: {
    defaultOutputMethod: 'default',
    variableNames: ["package_versie", "c_versie", "version_no"],
    spec: true,
    body: true
  },
  addObjects: {
    nameMaxLength: 30,
    fileDir: 'C:\\Temp\\'
  },
  objectTypes: [{
      type: "script",
      extension: "sql",
      versioning: false,
      dbType: null
    },
    {
      extension: "vw",
      versioning: false,
      dbType: "view",
      formalType: "VIEW"
    },
    {
      extension: "pks",
      versioning: true,
      dbType: "package",
      formalType: "PACKAGE"
    },
    {
      extension: "pkb",
      versioning: true,
      dbType: "package",
      formalType: "PACKAGE BODY"
    },
    {
      extension: "typ",
      versioning: false,
      dbType: "type",
      formalType: "TYPE"
    },
    {
      extension: "tyb",
      versioning: false,
      dbType: "type",
      formalType: "TYPE BODY"
    },
    {
      extension: "trg",
      versioning: false,
      dbType: "trigger",
      formalType: "TRIGGER"
    },
    {
      extension: "prc",
      versioning: false,
      dbType: "procedure",
      formalType: "PROCEDURE"
    }
  ]
};

config.baseDir = function(){
  var slugs = config.configDir.split(java.io.File.separator);
  slugs.splice(-2, 2);
  return slugs.join(java.io.File.separator) + java.io.File.separator;
}();

config.releaseDir = config.baseDir + "demos/2_custom_commands/install/releases/";

config.releaseLogDir = new java.io.File(config.releaseDir + "../logs").getCanonicalPath() + config.fileSeparator;

config.publicDir = config.baseDir + "public/";

config.templateDir = config.baseDir + "templates/";

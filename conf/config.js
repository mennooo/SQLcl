// Relplace this with your own configuration
var config = {
  version: "?v=" + Math.random().toString(36).substring(7),
  fileSeparator: java.io.File.separator,
  configDir: args[0],
  //baseDir: "https://raw.githubusercontent.com/mennooo/sqlcl/master",
  objectTypes: [{
      type: "script",
      extension: "sql",
      versioning: false,
      dbType: null
    },
    {
      type: "view",
      extension: "vw",
      versioning: false,
      dbType: "view"
    },
    {
      type: "packageSpec",
      extension: "pks",
      versioning: true,
      dbType: "package"
    },
    {
      type: "packageBody",
      extension: "pkb",
      versioning: true,
      dbType: "package"
    },
    {
      type: "typeSpec",
      extension: "typ",
      versioning: false,
      dbType: "type"
    },
    {
      type: "typeBody",
      extension: "tyb",
      versioning: false,
      dbType: "type"
    },
    {
      type: "trigger",
      extension: "trg",
      versioning: false,
      dbType: "trigger"
    },
    {
      type: "procedure",
      extension: "prc",
      versioning: false,
      dbType: "procedure"
    }
  ]
};

config.baseDir = function(){
  var slugs = config.configDir.split(java.io.File.separator);
  slugs.splice(-2, 2);
  return slugs.join(java.io.File.separator) + java.io.File.separator;
}();

config.releaseDir = config.baseDir + "demos/2_custom_commands/install/releases/";

config.releaseLogDir = config.releaseDir + "../logs/";

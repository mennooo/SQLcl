// Relplace this with your own configuration

(function() {

    var version = "1.1.7";

    print("loading config, version", version);

    var baseDir = "C:/Users/mhoogendijk/stack/Qualogy/presentation/sqlcl/releases";

    var objectTypes = [{
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
    ];

    return {
        version: version,
        baseDir: baseDir,
        objectTypes: objectTypes
    };

})();

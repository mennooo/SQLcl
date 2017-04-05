// Relplace this with your own configuration

(function() {

    var version = "1.1.1";

    print("loading config, version", version);

    var baseDir = "C:/Users/mhoogendijk/stack/Qualogy/presentation/sqlcl/releases";

    var objectTypes = {
        script: {
            extension: "sql",
            versioning: false,
            dbType: null
        },
        view: {
            extension: "vw",
            versioning: false,
            dbType: "view"
        },
        packageSpec: {
            extension: "pks",
            versioning: true,
            dbType: "package"
        },
        packageBody: {
            extension: "pkb",
            versioning: true,
            dbType: "package"
        },
        typeSpec: {
            extension: "typ",
            versioning: false,
            dbType: "type"
        },
        typeBody: {
            extension: "tyb",
            versioning: false,
            dbType: "type"
        },
        trigger: {
            extension: "trg",
            versioning: false,
            dbType: "trigger"
        },
        procedure: {
            extension: "prc",
            versioning: false,
            dbType: "procedure"
        }
    }

    return {
        version: version,
        baseDir: baseDir,
        objectTypes: objectTypes
    };

})();

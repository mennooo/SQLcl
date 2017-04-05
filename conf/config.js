var conf = {
    objectTypes: {
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
}

(function() {

    return conf;

})();

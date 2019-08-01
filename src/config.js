'use strict';

const winston = require('winston');
const commons = require('@jtviegas/jscommons').commons;
const tenant = require("./tenant");

const config_module = function(){


    let config = {
        STAGE_SCOPE: [ 'dev', 'test', 'prod']
        , ENV_SCOPE: [ 'local', 'dev', 'test', 'prod']
        , WINSTON_CONFIG: {
            level: 'debug',
            format: winston.format.combine(
                winston.format.splat(),
                winston.format.timestamp(),
                winston.format.printf(info => {
                    return `${info.timestamp} ${info.level}: ${info.message}`;
                })
            ),
            transports: [new winston.transports.Console()]
        }

    };

    const variables = [
        'TENANT'
        , 'STAGE'
        , 'ENV'
        , 'DB_ENDPOINT'
        , 'DB_API_REGION'
        , 'DB_API_VERSION'
        , 'ENTITIES'
        , 'DB_API_ACCESS_KEY_ID'
        , 'DB_API_ACCESS_KEY'
    ];

    const defaults = [
        null
        , 'prod'
        , 'prod'
        , null // 'http://localhost:8000'
        , 'eu-west-1'
        , '2012-08-10'
        , null
        , null
        , null
    ];

    config = commons.configByDecoration(config, variables, defaults, tenant, '_SCOPE', []);

    console.log(config)
    return config;
    
}();

module.exports = config_module;

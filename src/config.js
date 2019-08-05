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
        , BUCKET_FOLDER_PROD: 'production'
        , BUCKET_FOLDER_DEV: 'development'
        , BUCKET_FOLDERS: ['production', 'development']
        , BUCKET_FOLDERS_STAGE: ['prod', 'dev']

    };

    const variables = [
        'TENANT'
        , 'STAGE'
        , 'ENV'
        , 'DB_ENDPOINT'
        , 'DB_API_REGION'
        , 'DB_API_VERSION'
        , 'ENTITY'
        , 'DB_API_ACCESS_KEY_ID'
        , 'DB_API_ACCESS_KEY'
        , 'ITEM_PROPERTIES_NUMBER'
        , 'ID_SEED'
        , 'DATA_DESCRIPTOR_FILE'
        , 'S3_REGION'
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
        , 8
        , 5300
        , 'items.txt'
        , 'eu-west-1'
    ];

    config = commons.configByDecoration(config, variables, defaults, tenant, '_SCOPE', []);

    config.TABLE = `${config.TENANT}_${config.ENTITY}_${config.ENV}`;
    config.S3_AMAZON_URL = 'https://s3.' + config.S3_REGION + '.amazonaws.com';

    console.log(config)
    return config;
    
}();

module.exports = config_module;

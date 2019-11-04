'use strict';

const winston = require('winston');
const commons = require('@jtviegas/jscommons').commons;
const ServerError = require('@jtviegas/jscommons').ServerError;
const logger = winston.createLogger(commons.getDefaultWinstonConfig());

const constants = {
    STORELOADERSERVICE_DATA_DESCRIPTOR_FILE: 'data.spec'
    , STORELOADER_ENVIRONMENTS: ['pro','dev']
};
const CONFIGURATION_SPEC = {
    STORELOADERSERVICE_AWS_REGION: 'STORELOADER_AWS_REGION'
    , STORELOADERSERVICE_AWS_ACCESS_KEY_ID: 'STORELOADER_AWS_ACCESS_KEY_ID'
    , STORELOADERSERVICE_AWS_ACCESS_KEY: 'STORELOADER_AWS_ACCESS_KEY'

    // testing environment
    , STORELOADERSERVICE_TEST_bucket_endpoint: 'STORELOADER_TEST_bucket_endpoint'
    , STORELOADERSERVICE_TEST_store_endpoint: 'STORELOADER_TEST_store_endpoint'

};

logger.info("[storeloader]...initializing store-loader module...");
let configuration = commons.mergeConfiguration( commons.getEnvironmentConfiguration(CONFIGURATION_SPEC, commons.handleTestVariables), constants);
logger.info("[storeloader] configuration: %o", configuration);
const service = require('@jtviegas/store-loader-service')(configuration);

exports.handler = (event, context, callback) => {
    logger.info('[storeloader|handler|in] (event: %o, context: %o)', event, context);

    const done = (err, res) => callback( null, {
        statusCode: err ? ( err.status ? err.status : 500 ) : 200,
        body: err ? err.message : JSON.stringify(res),
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    });

    try {
        let app = null;
        let environment = null;
        let bucket = null;

        for(let i=0; i<event.Records.length; i++){
            let record = event.Records[i];
            if( record.s3 && record.s3.bucket && record.s3.bucket.name && record.s3.object && record.s3.object.key){
                let bucketNameElements = record.s3.bucket.name.split("-");
                app = bucketNameElements[0];
                environment = bucketNameElements[1];
                if( -1 >= configuration.STORELOADER_ENVIRONMENTS.indexOf(environment) ){
                    logger.warn('[storeloader|handler] wrong environment: %s)', environment);
                    throw new ServerError(`wrong environment: "${environment}"`, 400);
                }

                bucket = record.s3.bucket.name;
                break;
            }
        }

        if( null === environment  || null === app || null === bucket ){
            logger.warn('[storeloader|handler] wrong input => environment:%s | app:%s | bucket:%s)', environment, app, bucket);
            throw new ServerError("event must provide 'entity1', 'environment' and 'bucket'", 400);
        }

        service.load(app, environment, bucket, done);

    }
    catch(error) {
        done(error);
    }
    logger.info('[storeloader|handler|out]');
};


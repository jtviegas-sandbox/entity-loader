'use strict';

const winston = require('winston');
const commons = require('@jtviegas/jscommons').commons;
const ServerError = require('@jtviegas/jscommons').ServerError;
const service = require('@jtviegas/entity-loader-service');
const logger = winston.createLogger(commons.getDefaultWinstonConfig());

logger.info("[entityLoader]...initializing entity-loader module...");

const CONSTANTS = { region: 'eu-west-1' };
const CONFIGURATION_SPEC = [ 'region', 'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY'
    , 'DYNDBSTORE_TEST_ENDPOINT', 'BUCKETWRAPPER_TEST_ENDPOINT' ];
let configuration = commons.mergeConfiguration(CONSTANTS, commons.getEnvironmentVarsSubset(CONFIGURATION_SPEC));

logger.info("[entityLoader] configuration: %o", configuration);

exports.handler = (event, context, callback) => {
    logger.info('[entityLoader|handler|in] (event: %o, context: %o)', event, context);

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
                environment = bucketNameElements[bucketNameElements.length-2];
                app = record.s3.bucket.name.substr(0, record.s3.bucket.name.indexOf(`-${environment}`));
                bucket = record.s3.bucket.name;
                break;
            }
        }

        if( null === environment  || null === app || null === bucket ){
            logger.warn('[entityLoader|handler] wrong input => environment:%s | app:%s | bucket:%s)', environment, app, bucket);
            throw new ServerError("event must provide 'entity1', 'environment' and 'bucket'", 400);
        }

        service.load(app, environment, bucket, done);

    }
    catch(error) {
        done(error);
    }
    logger.info('[entityLoader|handler|out]');
};


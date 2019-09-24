'use strict';

const winston = require('winston');
const commons = require('@jtviegas/jscommons').commons;
const ServerError = require('@jtviegas/jscommons').ServerError;
const logger = winston.createLogger(commons.getDefaultWinstonConfig());

const constants = {
    STORELOADERSERVICE_DATA_DESCRIPTOR_FILE: 'data.spec'
    , STORELOADER_ENVIRONMENTS: ['production','development','test']
};
const CONFIGURATION_SPEC = {
    STORELOADER_APP: 'STORELOADER_APP'
    , STORELOADERSERVICE_AWS_REGION: 'STORELOADER_AWS_REGION'
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
        let entity = null;
        let environment = null;
        let bucket = null;

        for(let i=0; i<event.Records.length; i++){
            let record = event.Records[i];
            if( record.s3 && record.s3.bucket && record.s3.bucket.name && record.s3.object && record.s3.object.key){
                let keyElements =  record.s3.object.key.split("/");
                entity = keyElements[0];
                environment = keyElements[1];
                if( -1 >= configuration.STORELOADER_ENVIRONMENTS.indexOf(environment) )
                    throw new ServerError(`wrong environment: "${environment}"`, 400);
                bucket = record.s3.bucket.name;
                break;
            }
        }

        if( null === environment  || null === entity || null === bucket )
            throw new ServerError("event must provide 'entity', 'environment' and 'bucket'", 400);

        service.load(configuration.STORELOADER_APP, entity, environment, bucket, done);

    }
    catch(error) {
        done(error);
    }
    logger.info('[storeloader|handler|out]');
};

/*
var event = {
"Records": [
{
"eventVersion": "2.1",
"eventSource": "aws:s3",
"awsRegion": "eu-west-1",
"eventTime": "2019-08-05T16:14:54.314Z",
"eventName": "ObjectCreated:Put",
"userIdentity": {
"principalId": "A8HL0WRYU0T0V"
},
"requestParameters": {
"sourceIPAddress": "212.130.110.70"
},
"responseElements": {
"x-amz-request-id": "F6BCFB743F96B2D0",
"x-amz-id-2": "iEZgEkQhJD/9bR9SRWtNBnUcK1LULh0HMe4PuvBkDX3Lv5mpohAOokhuYaDZwjods97mquNIbTg="
},
"s3": {
"s3SchemaVersion": "1.0",
"configurationId": "split4ever_store_loader_event_dev",
"bucket": {
"name": "split4ever-items",
"ownerIdentity": {
"principalId": "A8HL0WRYU0T0V"
},
"arn": "arn:aws:s3:::split4ever-items"
},
"object": {
"key": "development/update",
"size": 0,
"eTag": "d41d8cd98f00b204e9800998ecf8427e",
"sequencer": "005D4855FE4B037C3B"
}
}
}
]
};
let context = {
"callbackWaitsForEmptyEventLoop": true,
"logGroupName": "/aws/lambda/split4ever_function_store_loader_prod",
"logStreamName": "2019/08/05/[$LATEST]2a8a53bed14840e3abebc83f0507314f",
"functionName": "split4ever_function_store_loader_prod",
"memoryLimitInMB": "1024",
"functionVersion": "$LATEST",
"invokeid": "f71898cd-c7d7-430f-a8ec-ab760d46efdb",
"awsRequestId": "f71898cd-c7d7-430f-a8ec-ab760d46efdb",
"invokedFunctionArn": "arn:aws:lambda:eu-west-1:692391178777:function:split4ever_function_store_loader_prod"
}

exports.handler(event, context, (e,d)=>{console.log('DONE', e,d);})
*/


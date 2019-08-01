'use strict';

const winston = require('winston');
const config = require("./config");
const logger = winston.createLogger(config['WINSTON_CONFIG']);
const service = require('@jtviegas/store-loader-service')(config);
const ServerError = require('@jtviegas/jscommons').ServerError;

exports.handler = (event, context, callback) => {
    logger.info('[handler|in] (event: %s, context: %s)', JSON.stringify(event, null, 4), JSON.stringify(context, null, 2));

    const done = (err, res) => callback( null, {
        statusCode: err ? ( err.status ? err.status : 500 ) : 200,
        body: err ? err.message : JSON.stringify(res),
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    });
    
    try {
        let stage = null;
        let bucket = null;
        for(let i=0; i<event.Records.length; i++){
            let record = event.Records[i];
            if( record.s3 && record.s3.bucket && record.s3.bucket.arn && record.s3.object && record.s3.object.key){
                stage =  record.s3.object.key.split(".")[0];
                bucket = record.s3.bucket.arn;
                break;
            }
        }

        if( null === stage  || null === bucket )
            throw new ServerError("event must provide 'stage' and 'bucket'", 400);
        else {
            if( -1 === config.STAGE_SCOPE.indexOf( stage ) )
                throw new ServerError(`wrong stage: "${stage}"`, 400);
            service.load(stage, bucket, done);
        }
    }
    catch(error) {
      done(error);
    }
    logger.info('[handler|out]');
};

/*
var event = {
    "Records": [
        {
            "eventVersion": "2.0",
            "eventSource": "aws:s3",
            "awsRegion": "eu-west-1",
            "eventTime": "2018-11-21T18:00:22.624Z",
            "eventName": "ObjectCreated:Put",
            "userIdentity": {
                "principalId": "A8HL0WRYU0T0V"
            },
            "requestParameters": {
                "sourceIPAddress": "194.88.4.145"
            },
            "responseElements": {
                "x-amz-request-id": "50A535B76621EAC2",
                "x-amz-id-2": "9eigH2IKYrt+rx5p8lmjtEknR/MHV5cHzqQ9gZFK26RubVHVdUAOS6GOzM9U5Cb9qA9OzLQBj2Q="
            },
            "s3": {
                "s3SchemaVersion": "1.0",
                "configurationId": "s4ePartsDevUpdateEvent",
                "bucket": {
                    "name": "parts.split4ever.com",
                    "ownerIdentity": {
                        "principalId": "A8HL0WRYU0T0V"
                    },
                    "arn": "arn:aws:s3:::parts.split4ever.com"
                },
                "object": {
                    "key": "update.dev",
                    "size": 0,
                    "eTag": "d41d8cd98f00b204e9800998ecf8427e",
                    "sequencer": "005BF59D3688C73978"
                }
            }
        }
    ]
}

exports.handler(event, null, (e,d)=>{console.log('DONE', e,d);})
*/
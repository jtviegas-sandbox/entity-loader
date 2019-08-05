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
        let folder = null;
        for(let i=0; i<event.Records.length; i++){
            let record = event.Records[i];
            if( record.s3 && record.s3.bucket && record.s3.bucket.name && record.s3.object && record.s3.object.key){
                folder =  record.s3.object.key.split("/")[0];
                let index = config.BUCKET_FOLDERS.indexOf(folder);
                if( -1 >= index )
                    throw new ServerError(`wrong folder: "${folder}"`, 400);
                stage = config.BUCKET_FOLDERS_STAGE[index];
                bucket = record.s3.bucket.name;
                break;
            }
        }

        if( null === stage  || null === bucket || null === folder )
            throw new ServerError("event must provide 'stage', 'folder' and 'bucket'", 400);
        else {
            if( -1 === config.STAGE_SCOPE.indexOf( stage ) )
                throw new ServerError(`wrong stage: "${stage}"`, 400);
            service.load(stage, folder, bucket, done);
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
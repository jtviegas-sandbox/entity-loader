'use strict';

const fs = require('fs');
const path = require('path');
const winston = require('winston');
const commons = require('@jtviegas/jscommons').commons;
const logger = winston.createLogger(commons.getDefaultWinstonConfig());
const chai = require('chai');
const expect = chai.expect;
const store = require('@jtviegas/dyndbstore');
const index = require('../index');

const config = {
    APP: 'app'
    , ENTITIES: ['entity1','entity2']
    , ENVIRONMENT: 'dev'
};

describe('index tests', function() {

    this.timeout(50000);
    let tables = [];
    for( let i=0; i < config.ENTITIES.length; i++ ){
        tables.push(commons.getTableNameV4(config.APP, config.ENTITIES[i], config.ENVIRONMENT))
    }

    describe('...bucket event on development with 3 items', function(done) {

        it('should store 3 objects in 2 different tables', function(done) {
            let event = {
                "Records": [
                    {
                        "eventSource": "aws:s3",
                        "awsRegion": "eu-west-1",
                        "s3": {
                            "s3SchemaVersion": "1.0"
                            ,"bucket": {
                                "name": `${config.APP}-${config.ENVIRONMENT}-entities`
                            },
                            "object": {
                                "key": "trigger"
                            }
                        }
                    }
                ]
            };

            index.handler( event, {}, (e,d)=>{
                logger.info("e: %o", e);
                if(e)
                    done(e);
                else {
                    try{
                        for( let i=0; i < tables.length; i++ ){
                            let table=tables[i];
                            store.getObjs(table, (e,r) => {
                                if(e)
                                    done(e);
                                else {
                                    expect(r.length).to.equal(3);
                                    if( i == (tables.length-1) )
                                        done(null);
                                }
                            });
                        }

                    }
                    catch(e){
                        done(e);
                    }
                }
            });
        });
    });
});

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


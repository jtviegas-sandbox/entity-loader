'use strict';

const fs = require('fs');
const path = require('path');
const winston = require('winston');
const commons = require('@jtviegas/jscommons').commons;
const logger = winston.createLogger(commons.getDefaultWinstonConfig());

const chai = require('chai');
const expect = chai.expect;
const store = require('@jtviegas/dyndbstore');

const config = {

    DYNDBSTORE_AWS_REGION: 'eu-west-1'
    , DYNDBSTORE_AWS_ACCESS_KEY_ID: process.env.ACCESS_KEY_ID
    , DYNDBSTORE_AWS_ACCESS_KEY: process.env.ACCESS_KEY
    , DYNDBSTORE_TEST: { store_endpoint: 'http://localhost:8000' }

    , APP: 'test'
    , ENTITY: 'item'
    , ENVIRONMENT: 'development'

};

const index = require('../index');

describe('index tests', function() {

    this.timeout(50000);
    let table = commons.getTableNameV3(config.APP, config.ENTITY, config.ENVIRONMENT);

    before(function(done) {
        try{
            store.init(config );
            done(null);
        }
        catch(e){
            done(e);
        }
    });

    describe('...bucket event on development with 3 items', function(done) {

        it('should store 3 objects', function(done) {
            let event = {
                "Records": [
                    {
                        "eventSource": "aws:s3",
                        "awsRegion": "eu-west-1",
                        "s3": {
                            "s3SchemaVersion": "1.0",
                            "configurationId": "split4ever_store_loader_event_dev",
                            "bucket": {
                                "name": "test",
                                "arn": "arn:aws:s3:::split4ever-items"
                            },
                            "object": {
                                "key": "item/development/trigger"
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
                        store.getObjs(table, (e,r) => {
                            if(e)
                                done(e);
                            else {
                                expect(r.length).to.equal(3);
                                done(null);
                            }
                        });
                    }
                    catch(e){
                        done(e);
                    }
                }
            });
        });
    });
});
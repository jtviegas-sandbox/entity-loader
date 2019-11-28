[![Build Status](https://travis-ci.org/jtviegas/entity-loader.svg?branch=master)](https://travis-ci.org/jtviegas/entity-loader)
[![Coverage Status](https://coveralls.io/repos/github/jtviegas/entity-loader/badge.svg?branch=master)](https://coveralls.io/github/jtviegas/entity-loader?branch=master)
entity loader
=========

An opinionated service that loads content into a data store.
The content, as an example, can be a set of items, and its related images, 
to be later retrieved and linked from a web application. 
The content data is store in the db, the `binary | image` data is then left in the bucket and linked from the content data.
Current implementation uses aws S3 and DynamoDB.

## Installation

  `npm install @jtviegas/entity-loader`

## Usage

### description

A service that loads entities from folders in a bucket (elements described by `data.spec` file and related 
```[0-9]*_[0-9]*\.{jpg|png|gif}``` image files) into a table.

Currently the entities, and therefore the tables in the data store, will be named after the app, the bucket folder name and its environment,
 as in ```${app}_${foldername=entity}_${env}```.
There will be also a ```trigger``` file, that should be created in the root folder to generate an event
that will trigger the loading process.
The bucket folder structure, can be exemplified as in:

    /
      parts/
          data.spec
          1_1.png
          1_2.png
          2.1.png 
      users/  
          data.spec
          1_1.png
          1_2.png
          2.1.png
      trigger
          
So, to load the data into a table (currently `aws dynamodb`) one should create a folder, named after the entity name (ex: `parts`), and dump the content inside it, e.g., the `data.spec` file explaining the data elements and the image files named according to the element name and image index (ex: `1_2.png` being the second image of element 1),
and then place the trigger file in the root folder to trigger the upload process.

### procedure
  - in your working console session, login to your AWS account;
  - if you want set the AWS region to your specific case, export the environment variable `TF_VAR_region`, default region is always `eu-west-1`;
  - create the terraform remote state bucket and table, use the script `devops/tf-state/run.sh`;
  - deploy the store loader invoking the script `devops/deploy.sh`;
  - you should now create the related entity tables, `store-loader-${env}-${entity-*}`, the store loader will write on it;
  - End products:
    - `store-loader-${env}-entities` bucket;
  - dump the entities folders (accordingly to the tables that you've created) and content in the buckets;
  - dump the `trigger` file in the root;
  - End products:
    - all the entities will be now entries in the table, and the images will be linked to the images in the bucket folder;
    - example:
    ```
        { 
        id: 1,
        number: 1,
        family: 'blabla',
        category: 'category A',
        subcategory: 'subcategory C',
        name: 'rusty part',
        price: 12.34,
        notes: 'great stuff',
        date: 1535760000000,
        images:
            [ { name: undefined,
                type: 'image/png',
                href: 'https://s3.eu-west-1.amazonaws.com/store-dev-entities/parts/1_1.png' },
                { name: undefined,
                type: 'image/png',
                href: 'https://s3.eu-west-1.amazonaws.com/store-dev-entities/parts/1_2.png' } ] 
        }
    ```
    

### test code snippet example
    
  Check the test folder in source tree.
  
## Tests

    npm test

## Contributing

just help yourself and submit a pull request

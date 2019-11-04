store loader
=========

An opinionated service that loads content into a data store.
The content, as an example, can be a set of items, and its related images, 
to be later retrieved and linked from a web application. 
The content data is store in the db, the `binary | image` data is then left in the bucket and linked from the content data.
Current implementation uses aws S3 and DynamoDB.

## Installation

  `npm install @jtviegas/store-loader`

## Usage

### description

A service that loads a folder contents (items described by `data.spec` file and related 
```[0-9]*_[0-9]*\.{jpg|png|gif}``` image files) from a bucket into a data store.
Currently the table in the data store will be named after the first level bucket folder, 
which by itself will define the items name, as in ```${app}_${foldername=entities_name}_${env}```.
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
          
So, to load the data into a cloud data store, currently aws dynamodb, one should create the folders and content
and then place the trigger file in the root folder.

### procedure
  - edit the variables in `platform/pro/main.tf` and in `platform/dev/main.tf`;
  - invoke `platform/platform.sh` to deploy and undeploy to aws;
  - End products:
    - `${app}-${env}-${entity-*}` tables; 
    - `${app}-${env}-entities` bucket;
  - dump the entities folders and content in the buckets;
  - dump the `trigger` file in the root;
  - End products:
    - all the entities will be reflected in entries in the table, and the images will contain a link to the image in the bucket folder;
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
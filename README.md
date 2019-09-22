store loader
=========

An opinionated service that loads content into a data store.
The content, as an example, can be a set of items, and its related images, 
to be later retrieved and linked from a web application. 
The content data is store in the db, the binary|image data is then left in the bucket and linked from the content data.
Current implementation uses aws S3 and DynamoDB.

## Installation

  `npm install @jtviegas/store-loader`

## Usage

### description

A service that loads a folder contents (items described by `data.spec` file and related 
```[0-9]*_[0-9]*\.{jpg|png|gif}``` image files) from a bucket into a data store.
Currently the table in the data store will be named after the first level bucket folder, 
which by itself will define the items name along with the environment which will be hinted 
by the second level folder, as in ```storeloader_${foldername=itemsname}_${env}```.
There will be also a ```trigger``` file, that should be created in the environment folder to generate an event
that will trigger the loading process.
The bucket folder structure, can de exemplified as in:

    /
      products/
        production/
          trigger
          data.spec
          1_1.png
          1_2.png
          2.1.png
        development/
          data.spec
          1_1.png
          1_2.png
          2.1.png    
      users/  
        test/
          trigger
          data.spec
          1_1.png
          1_2.png
          2.1.png
          
So, to load the data into a cloud data store, currently aws dynamodb, one should create the folders and content
and then place the trigger file accordingly to what is supposed to be loaded.

### required environment variables or configuration properties
  - STORELOADER_APP
  - STORELOADER_AWS_REGION
  - STORELOADER_AWS_ACCESS_KEY_ID
  - STORELOADER_AWS_ACCESS_KEY

### test code snippet example
    
  Check the test folder in source tree.
  
## Tests

    npm test

## Contributing

just help yourself and submit a pull request
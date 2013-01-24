doctape-gallery
===============

simple image gallery from your doctape tags. hacked at doctape hackathon #1 (01/18 - 01/19 2013, Hannover).
needs node.js and couchdb.

to install just clone the repo and

    npm install

the dependencies.

in app.js / app.coffee change

    DOCTAPE_APP_KEY = 'your-doctape-app-key';
    DOCTAPE_APP_SECRET = 'your-doctape-app-secret';
    CALLBACK_URL = 'http://app.url/auth/doctape/callback';
    DB_URL = 'http://couch:5984';
    DB_DATABASE = 'database';
    DB_DESIGN = 'designdoc';

to your corresponding values. your couchdb _design document should contain the following simple view:

    {
        "galleries_by_username": {
            "map": "function(doc) { emit(doc._id, doc.galleries) }"
        }
    }

then visit your app.url and log in with your doctape credentials.  

i think that should do it. happy gallerying :)

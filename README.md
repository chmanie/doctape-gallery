doctape-gallery
===============

simple image gallery from your doctape tags. hacked at doctape hackathon #1 (01/18 - 01/19 2013, Hannover).
needs node.js and couchdb.

to install just clone the repo and

    npm install

the dependencies.

in app.js change

    DOCTAPE_APP_KEY = 'your-doctape-app-key';
    DOCTAPE_APP_SECRET = 'your-doctape-app-secret';
    CALLBACK_URL = 'http://app.url/auth/doctape/callback'
    
to your corresponding values. then visit your app.url and log in with your doctape credentials.
    

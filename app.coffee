express = require 'express'
http = require 'http'
path = require 'path'
request = require 'request'
passport = require 'passport'
Couch = require 'node-couch'
Doctape = require 'doctape'
DoctapeStrategy = require('passport-doctape').Strategy

DOCTAPE_APP_KEY = 'your-doctape-app-key'
DOCTAPE_APP_SECRET = 'your-doctape-app-secret'
CALLBACK_URL = 'http://app.url/auth/doctape/callback'
DB_URL = 'http://couch:5984'
DB_DATABASE = 'dtgallery'
DB_DESIGN = 'couch'

# helper functions

member = (arr, val) ->
  val = val.replace(/\s/g, "*#*");
  for v in arr
    v = v.replace(/\s/g, "*#*");
    if v == val
      return true
  return false

all = (arr, inArray) ->
  for a in arr
    if not member inArray, a
      return false
  return true

ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated()
    next()
  else
    res.redirect '/login'

passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj

passport.use new DoctapeStrategy
    authorizationURL: 'https://api.doctape.com/oauth2',
    tokenURL: 'https://api.doctape.com/oauth2/token',
    clientID: DOCTAPE_APP_KEY,
    clientSecret: DOCTAPE_APP_SECRET,
    callbackURL: CALLBACK_URL
  ,(accessToken, refreshToken, profile, done) ->
    profile.accessToken = accessToken
    done(null, profile)

db = new Couch(DB_URL, DB_DATABASE, DB_DESIGN)

getGalleries = (username, cb) ->
  db.view
    key: username
    view: 'galleries_by_username'
  , (err, data) ->
      if data[0].id?
        cb(null, data[0].value)
      else
        cb(null, {})

app = express()

app.configure ->
  app.set 'port', process.env.PORT || 4000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.logger('dev')
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.static(path.join(__dirname, 'public'))
  app.use(express.session({ secret: '39f8d5313141b1f2bade311ba571537e' }));

  app.use passport.initialize()
  app.use passport.session()

  app.configure 'development', ->
    app.use express.errorHandler()

getAllGalleryData = (user, cb) ->
  request.get
    url: 'https://api.doctape.com/v1/doc'
    headers: {'Authorization': 'Bearer ' + user.accessToken}
  , (err, reqres, body) ->
    if !err
      getGalleries user.username, (err, galleries) ->  
        galdocs = []
        for gallery in galleries
          galname = gallery.name
          galtags = gallery.tags
          galobj = {}
          docs = JSON.parse(body).result
          for id, doc of docs
            if all(galtags, doc.tags)
              if doc.media_type == 'image'
                galobj[doc.id] = doc
          galobj._data = 
            name: galname
            tags: galtags
          galdocs.push(galobj)
        cb(galdocs, galleries)

app.get '/', (req, res) ->
  if req.isAuthenticated()
    getAllGalleryData req.user, (galdocs, galleries) ->
        newGalDocs = []
        for gal in galdocs
          newGalObj = {}
          length = Object.keys(gal).length
          newGalObj['length'] = length - 1
          ran = Math.floor(Math.random()*length-1)
          frontImgID = Object.keys(gal)[ran]
          newGalObj['frontImgID'] = frontImgID
          newGalObj['name'] = gal._data.name
          newGalObj['tags'] = gal._data.tags
          newGalDocs.push(newGalObj)
        res.render 'index', { page: 'home', auth: true, galleries: galleries, username: req.user.username, galdocs: newGalDocs }
        #res.send(newGalDocs)
  else
    res.render 'index', { auth: false, page: 'home' }

app.get '/account', ensureAuthenticated, (req, res) ->
  request.get
    url: 'https://api.doctape.com/v1/account',
    headers: {'Authorization': 'Bearer ' + req.user.accessToken}
  , (err, reqres, body) ->
      if !err
        data = JSON.parse(body)
        getGalleries data.result.username, (err, galleries) ->
          if !err
            res.render 'account', { auth: true, username: data.result.username, freespace: Math.round(data.result.quota_free/1000000000*100)/100, galleries: galleries, page: 'account'}
      else
        console.log(err)

app.get '/gallery/:id', ensureAuthenticated, (req, res) ->
  getAllGalleryData req.user, (galdocs, galleries) ->
    galid = req.params.id - 1
    res.render 'gallery', { auth: true, galleries: galleries, username: req.user.username, galdocs: galdocs[galid], page: 'gallery' }

app.get '/thumb/:id', ensureAuthenticated, (req, res) ->
  pic = request
    method: 'GET',
    url: 'https://api.doctape.com/v1/doc/' + req.params.id + '/thumb_320.jpg',
    headers: {'Authorization': 'Bearer ' + req.user.accessToken}
  pic.pipe res

app.get '/image/:id', ensureAuthenticated, (req, res) ->
  pic = request
    method: 'GET',
    url: 'https://api.doctape.com/v1/doc/' + req.params.id + '/original',
    headers: {'Authorization': 'Bearer ' + req.user.accessToken}
  pic.pipe res

app.get '/login', (req, res) ->
  res.render 'login', { auth: false }

app.post '/creategallery', (req, res) ->
  if req.isAuthenticated()
    # data: {name: 'Bla', tags: ['tag1', 'tag2']}
    db.doc req.user.username, (err, data) ->
      if data._id?
        doc = data
        doc.galleries.push(req.body)
        console.log(doc)
      else
        doc =
          _id: req.user.username
          galleries: req.body
      db.saveDoc doc, (err, data) ->
        if !err
          res.send 'OK'
  else
    res.send 'error: not authenticated!'

app.get '/deletegallery/:id', (req, res) ->
  if req.isAuthenticated()
    db.doc req.user.username, (err, data) ->
      if !err
        doc = data
        galleries = data.galleries
        galleries.splice(req.params.id-1,1)
        doc.galleries = galleries
        db.saveDoc doc, (er, dat) ->
          if !er
            res.send('OK')
  else
    res.send 'error: not authenticated!'

app.get '/auth/doctape', passport.authenticate('doctape', {scope: ['account', 'docs']}), (req, res, next) ->

app.get '/auth/doctape/callback', passport.authenticate('doctape', {failureRedirect: '/login'}), (req, res, next) ->
  res.redirect('/')

app.get '/logout', ensureAuthenticated, (req, res) ->
  req.session.destroy()
  res.redirect('/')

server = http.createServer(app)

server.listen app.get('port'), ->
  console.log 'Express server listening on port ' + app.get('port')
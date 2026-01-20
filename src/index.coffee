express = require 'express'
path = require 'path'
fs = require 'fs'

app = express()
PORT = process.env.PORT or 3000

# Ensure logs directory exists
LOGS_DIR = path.join __dirname, '..', 'logs'
fs.mkdirSync LOGS_DIR, recursive: true unless fs.existsSync LOGS_DIR

# Log counter for unique filenames
logCounter = 0

logApiCall = (label, url, status, data) ->
  logCounter++
  timestamp = new Date().toISOString().replace(/[:.]/g, '-')
  filename = "#{String(logCounter).padStart(3, '0')}-#{label}-#{timestamp}.json"
  filepath = path.join LOGS_DIR, filename

  logData =
    url: url
    status: status
    data: data

  fs.writeFileSync filepath, JSON.stringify(logData, null, 2)
  console.log "[#{label}] #{status} -> #{filename}"

# Middleware
app.use express.json()
app.use express.static path.join __dirname, '..', 'public'

# Chub API proxy endpoints
CHUB_API = 'https://api.chub.ai'

# Search characters with filters
app.get '/api/search', (req, res) ->
  apiKey = req.headers['x-chub-api-key']
  unless apiKey
    return res.status(401).json error: 'Missing X-Chub-API-Key header'

  queryParams = new URLSearchParams req.query
  url = "#{CHUB_API}/search?#{queryParams}"

  try
    response = await fetch url,
      headers:
        'CH-API-KEY': apiKey
    data = await response.json()
    logApiCall 'search', url, response.status, data
    res.json data
  catch err
    console.error "[ERROR]", err
    res.status(500).json error: err.message

# Get all tags with counts
app.post '/api/tags', (req, res) ->
  apiKey = req.headers['x-chub-api-key']
  unless apiKey
    return res.status(401).json error: 'Missing X-Chub-API-Key header'

  url = "#{CHUB_API}/tags"

  try
    response = await fetch url,
      method: 'POST'
      headers:
        'CH-API-KEY': apiKey
        'Content-Type': 'application/json'
      body: JSON.stringify req.body
    data = await response.json()
    logApiCall 'tags-list', url, response.status, data
    res.json data
  catch err
    console.error "[ERROR]", err
    res.status(500).json error: err.message

# Add tag to character
app.post '/api/tags/:projectId/:tagname', (req, res) ->
  apiKey = req.headers['x-chub-api-key']
  unless apiKey
    return res.status(401).json error: 'Missing X-Chub-API-Key header'

  {projectId, tagname} = req.params
  url = "#{CHUB_API}/api/tags/#{projectId}/#{tagname}"

  try
    response = await fetch url,
      method: 'POST'
      headers:
        'CH-API-KEY': apiKey
    data = await response.json()
    logApiCall 'tag-add', url, response.status, data
    res.json data
  catch err
    console.error "[ERROR]", err
    res.status(500).json error: err.message

# Remove tag from character
app.delete '/api/tags/:projectId/:tagname', (req, res) ->
  apiKey = req.headers['x-chub-api-key']
  unless apiKey
    return res.status(401).json error: 'Missing X-Chub-API-Key header'

  {projectId, tagname} = req.params
  url = "#{CHUB_API}/api/tags/#{projectId}/#{tagname}"

  try
    response = await fetch url,
      method: 'DELETE'
      headers:
        'CH-API-KEY': apiKey
    data = await response.json()
    logApiCall 'tag-remove', url, response.status, data
    res.json data
  catch err
    console.error "[ERROR]", err
    res.status(500).json error: err.message

# Get specific character
app.get '/api/characters/:creator/:name', (req, res) ->
  apiKey = req.headers['x-chub-api-key']
  unless apiKey
    return res.status(401).json error: 'Missing X-Chub-API-Key header'

  {creator, name} = req.params
  url = "#{CHUB_API}/api/characters/#{creator}/#{name}?full=true"

  try
    response = await fetch url,
      headers:
        'CH-API-KEY': apiKey
    data = await response.json()
    logApiCall 'character', url, response.status, data
    res.json data
  catch err
    console.error "[ERROR]", err
    res.status(500).json error: err.message

# Update character
app.put '/api/characters/:creator/:name', (req, res) ->
  apiKey = req.headers['x-chub-api-key']
  unless apiKey
    return res.status(401).json error: 'Missing X-Chub-API-Key header'

  {creator, name} = req.params
  url = "#{CHUB_API}/api/core/characters/#{creator}/#{name}"

  try
    logApiCall 'update-request', url, 'REQUEST', req.body
    response = await fetch url,
      method: 'PUT'
      headers:
        'CH-API-KEY': apiKey
        'Content-Type': 'application/json'
      body: JSON.stringify req.body
    data = await response.json()
    logApiCall 'update-response', url, response.status, data
    res.json data
  catch err
    console.error "[ERROR]", err
    res.status(500).json error: err.message

# Get user's projects
app.get '/api/users/:username', (req, res) ->
  apiKey = req.headers['x-chub-api-key']
  unless apiKey
    return res.status(401).json error: 'Missing X-Chub-API-Key header'

  {username} = req.params
  url = "#{CHUB_API}/api/users/#{username}"

  try
    response = await fetch url,
      headers:
        'CH-API-KEY': apiKey
    data = await response.json()
    logApiCall 'users', url, response.status, data
    res.json data
  catch err
    console.error "[ERROR]", err
    res.status(500).json error: err.message

app.listen PORT, ->
  console.log "Chub Manager running at http://localhost:#{PORT}"

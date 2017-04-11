const http = require('http')
const url = require('url')

const app = require('./app')

service = http.createServer(app).listen(3000)

module.exports = service

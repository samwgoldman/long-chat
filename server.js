var http = require("http");
var fs = require("fs");

var port = process.env.PORT || 8000;

var listeners = [];

function server(request, response) {
  switch (request.method) {
    case "GET":
      switch (request.url) {
        case "/":
          sendFile(response, "index.html", "text/html");
          break;
        case "/client.js":
          sendFile(response, "client.js", "text/javascript");
          break;
        case "/screen.css":
          sendFile(response, "screen.css", "text/css");
          break;
        default:
          listen(request, response);
      }
      break;
    case "POST":
      speak(request, response);
      break;
    default:
      method_not_allowed(response);
  }
}

function sendFile(response, filePath, mediaType) {
  response.setHeader("Content-Type", mediaType);
  fs.createReadStream(filePath).pipe(response);
}

function listen(request, response) {
  listeners.push(response);
}

function speak(request, response) {
  while (listeners.length) {
    listener = listeners.pop();
    request.pipe(listener);
  }

  response.writeHead(204, "No Content");
  response.end();
}

function method_not_allowed(response) {
  response.writeHead(405, "Method Not Allowed", {
    "Allow": "GET, POST",
    "Connection": "close",
    "Content-Length": 0
  });
  response.end();
}

http.createServer(server).listen(port)

using HTTP, Sockets

const HOST = ip"0.0.0.0" ## from Sockets
const PORT = 8080
const ROUTER = HTTP.Router()
const staticFiles = readdir(joinpath(dirname(@__FILE__), "static"))

# HTTP.listen("127.0.0.1", 8081) do http
#     HTTP.setheader(http, "Content-Type" => "text/html")
#     write(http, "target uri: $(http.message.target)<BR>")
#     write(http, "request body:<BR><PRE>")
#     write(http, read(http))
#     write(http, "</PRE>")
#     return
# end

# index = HTTP.serve(HOST, PORT) do req::HTTP.Request
#     println(req.method)
#     println(req.target)
#     html = read("static/index.html", String)
#     return HTTP.Messages.Response(200, html)
# end

function index(req::HTTP.Request)
    html = read("index.html", String)
    return HTTP.Messages.Response(200, html)
end

function static(req::HTTP.Request)
    uri_part = HTTP.URIs.splitpath(req.target)[2]
    !in(uri_part, staticFiles) && return HTTP.Messages.Response(404)
    try
      html = read("static/$(uri_part)", String)
      HTTP.Messages.Response(200, html)
    catch e
      println("You have entering unvalid path")
      HTTP.Messages.Response(404)
    end
end

function pagenotfound(req::HTTP.Request)
    HTTP.Messages.Response(200, "Page not found")
end

HTTP.@register(ROUTER, "GET", "/", index)
HTTP.@register(ROUTER, "GET", "/static/*", static)
HTTP.@register(ROUTER, "GET", "*", pagenotfound)


HTTP.serve(ROUTER, HOST, PORT)

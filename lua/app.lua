local socket = require("socket")
local http = require("socket.http")
local https = require("ssl.https")
local url = require("socket.url")

function parse_query(query)
    local params = {}
    if query then
        for pair in string.gmatch(query, "([^&]+)") do
            local key, value = string.match(pair, "([^=]+)=([^=]*)")
            if key then
                params[url.unescape(key)] = url.unescape(value or "")
            end
        end
    end
    return params
end

function handle_request(request_line)
    local method, path_query = string.match(request_line, "([A-Z]+) ([^ ]+)")
    if not method or method ~= "GET" then
        return "HTTP/1.1 405 Method Not Allowed\r\n\r\n"
    end
    
    local path, query = string.match(path_query, "([^?]*)%??(.*)")
    if path ~= "/" then
        return "HTTP/1.1 404 Not Found\r\n\r\n"
    end
    
    local params = parse_query(query)
    local keyword = params["keyword"] or ""
    local target = params["target"] or ""
    local found = "false"
    
    if keyword ~= "" and target ~= "" then
        local body
        if string.sub(target, 1, 8) == "https://" then
            body = https.request(target)
        else
            body = http.request(target)
        end
        if body and string.find(body, keyword, 1, true) then
            found = "true"
        end
        print(string.format("found=%s, keyword=%s, uri=%s", found, keyword, target))
    end
    
    local response = string.format(
        "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: %d\r\n\r\n%s",
        #found, found
    )
    return response
end

local server = socket.bind("0.0.0.0", 31337)
print("listening on 0.0.0.0:31337")

while true do
    local client = server:accept()
    client:settimeout(10)
    
    local request_line = client:receive()
    if request_line then
        local response = handle_request(request_line)
        client:send(response)
    end
    
    client:close()
end
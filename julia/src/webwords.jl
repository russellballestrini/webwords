using HTTP
using Sockets

function handle_request(req::HTTP.Request)
    uri = HTTP.URI(req.target)
    query = HTTP.URIs.queryparams(uri)
    
    keyword = get(query, "keyword", "")
    target = get(query, "target", "")
    found = "false"
    
    if !isempty(keyword) && !isempty(target)
        try
            response = HTTP.get(target, readtimeout=10)
            body = String(response.body)
            
            if occursin(keyword, body)
                found = "true"
            end
            
            println("found=$found, keyword=$keyword, uri=$target")
        catch e
            println("Error: $e")
        end
    end
    
    return HTTP.Response(200, found)
end

function main()
    port = parse(Int, get(ENV, "PORT", "31337"))
    println("listening on 0.0.0.0:$port")
    HTTP.serve(handle_request, Sockets.ip"0.0.0.0", port)
end

main()
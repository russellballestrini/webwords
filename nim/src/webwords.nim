import jester
import httpclient
import strutils

# Jester settings - disable threading to avoid segfaults
settings:
  port = Port(31337)
  bindAddr = "0.0.0.0"
  numThreads = 1

proc fetchUrl(url: string): string =
  try:
    let client = newHttpClient()
    client.timeout = 10000
    let response = client.getContent(url)
    client.close()
    return response
  except Exception as e:
    echo "HTTP error: " & e.msg
    return ""

routes:
  get "/":
    let keyword = request.params.getOrDefault("keyword", "")
    let target = request.params.getOrDefault("target", "")
    var found = "false"
    
    if keyword.len > 0 and target.len > 0:
      let body = fetchUrl(target)
      if keyword in body:
        found = "true"
      
      echo "found=" & found & ", keyword=" & keyword & ", uri=" & target
    
    resp found

when isMainModule:
  echo "listening on 0.0.0.0:31337"
  runForever()
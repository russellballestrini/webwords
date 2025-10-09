# PowerShell WebWords Implementation - Simplified for Linux
param(
    [int]$Port = 31337
)

# Create HTTP listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$Port/")

try {
    $listener.Start()
    Write-Host "listening on 0.0.0.0:$Port"
    
    # Simple synchronous request handling loop
    while ($listener.IsListening) {
        try {
            # Get incoming request (blocking call)
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            # Extract query parameters
            $keyword = $request.QueryString["keyword"]
            $target = $request.QueryString["target"]
            $found = "false"
            
            if ($keyword -and $target) {
                try {
                    # Use Invoke-RestMethod for better Linux compatibility
                    $body = Invoke-RestMethod -Uri $target -Method Get -TimeoutSec 10
                    
                    # Convert to string if needed and check for keyword
                    $bodyStr = $body.ToString()
                    if ($bodyStr.Contains($keyword)) {
                        $found = "true"
                    }
                    
                    Write-Host "found=$found, keyword=$keyword, uri=$target"
                }
                catch {
                    Write-Host "Error fetching ${target}: $($_.Exception.Message)"
                    # Keep $found as "false" on error
                }
            }
            
            # Send HTTP response
            $response.ContentType = "text/plain"
            $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($found)
            $response.ContentLength64 = $responseBytes.Length
            $response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)
            $response.OutputStream.Close()
        }
        catch {
            Write-Host "Request error: $($_.Exception.Message)"
            # Continue serving despite individual request errors
        }
    }
}
catch {
    Write-Error "Server error: $($_.Exception.Message)"
}
finally {
    if ($listener.IsListening) {
        $listener.Stop()
    }
    $listener.Close()
}
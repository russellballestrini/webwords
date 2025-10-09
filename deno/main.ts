import { serve } from "https://deno.land/std@0.200.0/http/server.ts";

async function fetchUrl(url: string): Promise<string | null> {
  try {
    const response = await fetch(url, { 
      signal: AbortSignal.timeout(10000)
    });
    return await response.text();
  } catch (error) {
    console.log(`Error fetching ${url}: ${error.message}`);
    return null;
  }
}

async function handler(request: Request): Promise<Response> {
  const url = new URL(request.url);
  const keyword = url.searchParams.get("keyword") || "";
  const target = url.searchParams.get("target") || "";
  
  let found = "false";
  
  if (keyword && target) {
    const body = await fetchUrl(target);
    if (body && body.includes(keyword)) {
      found = "true";
    }
    
    console.log(`found=${found}, keyword=${keyword}, uri=${target}`);
  }
  
  return new Response(found, {
    status: 200,
    headers: { "content-type": "text/plain" }
  });
}

console.log("listening on 0.0.0.0:31337");
await serve(handler, { port: 31337, hostname: "0.0.0.0" });
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import java.io.*;
import java.net.*;
import java.util.Map;
import java.util.HashMap;

public class WebWords {
    public static void main(String[] args) throws Exception {
        HttpServer server = HttpServer.create(new InetSocketAddress(31337), 0);
        server.createContext("/", new MyHandler());
        server.setExecutor(null);
        System.out.println("listening on 0.0.0.0:31337");
        server.start();
    }

    static class MyHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange t) throws IOException {
            String query = t.getRequestURI().getQuery();
            Map<String, String> params = parseQuery(query);
            
            String keyword = params.get("keyword");
            String target = params.get("target");
            String found = "false";
            
            if (keyword != null && target != null) {
                try {
                    URL url = new URL(target);
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("GET");
                    conn.setConnectTimeout(10000);
                    conn.setReadTimeout(10000);
                    
                    BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                    StringBuilder response = new StringBuilder();
                    String line;
                    
                    while ((line = reader.readLine()) != null) {
                        response.append(line);
                    }
                    reader.close();
                    
                    if (response.toString().contains(keyword)) {
                        found = "true";
                    }
                    
                    System.out.printf("found=%s, keyword=%s, uri=%s%n", found, keyword, target);
                } catch (Exception e) {
                    System.out.println("Error: " + e.getMessage());
                }
            }
            
            t.sendResponseHeaders(200, found.length());
            OutputStream os = t.getResponseBody();
            os.write(found.getBytes());
            os.close();
        }
        
        private Map<String, String> parseQuery(String query) {
            Map<String, String> result = new HashMap<>();
            if (query != null) {
                for (String param : query.split("&")) {
                    String[] entry = param.split("=");
                    if (entry.length > 1) {
                        try {
                            result.put(URLDecoder.decode(entry[0], "UTF-8"), URLDecoder.decode(entry[1], "UTF-8"));
                        } catch (UnsupportedEncodingException e) {
                            // ignore
                        }
                    }
                }
            }
            return result;
        }
    }
}
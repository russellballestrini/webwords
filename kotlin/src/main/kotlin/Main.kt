import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun main() {
    val client = HttpClient(CIO) {
        engine {
            requestTimeout = 10000
        }
    }
    
    embeddedServer(Netty, port = 31337, host = "0.0.0.0") {
        routing {
            get("/") {
                val keyword = call.request.queryParameters["keyword"] ?: ""
                val target = call.request.queryParameters["target"] ?: ""
                var found = "false"
                
                if (keyword.isNotEmpty() && target.isNotEmpty()) {
                    try {
                        val response: HttpResponse = client.get(target)
                        val body = response.bodyAsText()
                        
                        if (body.contains(keyword)) {
                            found = "true"
                        }
                        
                        println("found=$found, keyword=$keyword, uri=$target")
                    } catch (e: Exception) {
                        println("Error: ${e.message}")
                    }
                }
                
                call.respondText(found)
            }
        }
    }.start(wait = true)
}
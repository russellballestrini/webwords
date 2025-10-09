import akka.actor.typed.ActorSystem
import akka.actor.typed.scaladsl.Behaviors
import akka.http.scaladsl.Http
import akka.http.scaladsl.model._
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.server.Route
import scala.concurrent.Future
import scala.util.{Failure, Success}

object WebWords extends App {
  implicit val system = ActorSystem(Behaviors.empty, "webwords-system")
  implicit val executionContext = system.executionContext

  val route: Route =
    path("") {
      get {
        parameters("keyword".?, "target".?) { (keyword, target) =>
          complete {
            (keyword, target) match {
              case (Some(k), Some(t)) if k.nonEmpty && t.nonEmpty =>
                fetchAndCheck(k, t)
              case _ =>
                Future.successful("false")
            }
          }
        }
      }
    }

  def fetchAndCheck(keyword: String, target: String): Future[String] = {
    Http().singleRequest(HttpRequest(uri = target))
      .flatMap(_.entity.toStrict(scala.concurrent.duration.Duration(10, "seconds")))
      .map { entity =>
        val body = entity.data.utf8String
        val found = if (body.contains(keyword)) "true" else "false"
        println(s"found=$found, keyword=$keyword, uri=$target")
        found
      }
      .recover {
        case ex =>
          println(s"Error: ${ex.getMessage}")
          "false"
      }
  }

  val port = sys.env.getOrElse("PORT", "31337").toInt
  val bindingFuture = Http().newServerAt("0.0.0.0", port).bind(route)

  bindingFuture.onComplete {
    case Success(binding) =>
      println(s"listening on 0.0.0.0:$port")
    case Failure(exception) =>
      println(s"Server binding failed with ${exception.getMessage}")
      system.terminate()
  }
}
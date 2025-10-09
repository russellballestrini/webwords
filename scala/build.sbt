ThisBuild / scalaVersion := "2.13.10"
ThisBuild / version := "0.1.0"

lazy val root = (project in file("."))
  .enablePlugins(JavaAppPackaging)
  .settings(
    name := "webwords",
    mainClass := Some("WebWords"),
    libraryDependencies ++= Seq(
      "com.typesafe.akka" %% "akka-http" % "10.5.0",
      "com.typesafe.akka" %% "akka-stream" % "2.8.0",
      "com.typesafe.akka" %% "akka-actor-typed" % "2.8.0",
      "com.typesafe.akka" %% "akka-http-spray-json" % "10.5.0"
    )
  )
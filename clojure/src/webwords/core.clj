(ns webwords.core
  (:require [ring.adapter.jetty :as jetty]
            [ring.util.response :as response]
            [ring.middleware.params :as params]
            [clj-http.client :as http])
  (:gen-class))

(defn fetch-url [url]
  (try
    (:body (http/get url {:socket-timeout 10000 :conn-timeout 10000}))
    (catch Exception e nil)))

(defn handle-request [request]
  (let [params (:query-params request)
        keyword (get params "keyword" "")
        target (get params "target" "")
        found (if (and (not-empty keyword) (not-empty target))
                (let [body (fetch-url target)]
                  (if (and body (.contains body keyword))
                    "true"
                    "false"))
                "false")]
    (when (and (not-empty keyword) (not-empty target))
      (println (str "found=" found ", keyword=" keyword ", uri=" target)))
    (response/response found)))

(defn -main [& args]
  (let [port (Integer/parseInt (or (System/getenv "PORT") "31337"))]
    (println (str "listening on 0.0.0.0:" port))
    (jetty/run-jetty (params/wrap-params handle-request) {:port port :host "0.0.0.0"})))
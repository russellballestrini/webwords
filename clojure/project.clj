(defproject webwords "0.1.0"
  :description "WebWords in Clojure"
  :dependencies [[org.clojure/clojure "1.11.1"]
                 [ring/ring-core "1.9.6"]
                 [ring/ring-jetty-adapter "1.9.6"]
                 [clj-http "3.12.3"]]
  :main ^:skip-aot webwords.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
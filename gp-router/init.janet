(import gp/net/http :as http)
(import spork/htmlgen :as h)

(defn make-html [{:status status :body body :headers headers}]
  (default status 200)
  (default headers {})
  (http/http
    {:body (h/html body)
     :status status
     :headers (http/content-type ".html")}))

(defn- html-middleware [f]
  (fn [req]
    (make-html (f req))))

(defn- regular-middleware [f]
  (fn [req]
    (http/http (f req))))

(defn render [body]
  {:body body
   :status 200
   :headers {}})

(defn render-with [status body]
  {:body body
   :status status
   :headers {}})

(defn- my-routes-push [obj]
  (let [arr (dyn :my-routes @[])]
    (assert (array? arr) ":my-routes must be an array")
    (setdyn :my-routes (array/push arr obj))))

# TODO:
# - fail if route exists
# - add :json middleware
(defmacro route
  ```There are multiple ways to use this macro:

   (route :get \"/\" (fn [req] (render \"Hello\")))

  and

   (route :html :get \"/\" (fn [req] (render \"Hello\")))

  The optional first arg is a middleware option and can either be :json or :html.

  NOTE: :json is not implemented yet.
  ```
  [& args]
  (let [with-middlware (= (length args) 4)]
    (if with-middlware
     ~(,my-routes-push {:path ,(get args 2)
                        :method ,(get args 1)
                        :handler ,(get args 3)
                        :middleware ,(get args 0)})
     ~(,my-routes-push {:path ,(get args 1)
                        :method ,(get args 0)
                        :handler ,(get args 2)}))))

(defn create-routes [&opt dispatch]
  (default dispatch http/dispatch)

  (var routes @{}) # Example: {"/" {:get (fn [req]) :post (fn [req)}}}
  (loop [{:path path :method method :handler handler :middleware middleware} :in (dyn :my-routes)]
    (let [methods (get routes path {})]
      (put routes path (merge methods @{method (cond
                                                 (and (not (dyn :no-middleware)) (= middleware :html))
                                                 (html-middleware handler)

                                                 (not (dyn :no-middleware))
                                                 (regular-middleware handler)

                                                 handler)}))))

  (tabseq [[path config] :pairs routes]
    path (dispatch (tabseq [[method handler] :pairs config]
                       (string/ascii-upper (string method)) handler))))

# Middleware is not added, for easier testing
(defn create-test-routes [&opt dispatch]
  (setdyn :no-middleware true)
  (create-routes dispatch))

(defn test-app [req]
  (let [f (http/drive (create-test-routes))]
    (f req)))

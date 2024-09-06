# gp-router

Some helper functions over gp/http.

Motivation was mainly to make it easier to test endpoints returning html easier.


## Example

```janet
(import gp/net/http :as http)
(use gp-router)

(defn index [_]
  (render [:h1 "heisann"]))

(defn not-found [_]
  (render-with 404 [:h1 "Not found"]))

(defn ready [_]
  {:body "Ready"
   :status 200
   :headers {}})

(defn with-parameter [req]
  (let [id (get-in req [:params :id])]
    (render [:p "heisann: " id])))

(route :html :get "/" index)
(route :html :get "/with-param/:id" with-parameter)
(route :html :get :not-found not-found)
(route :get "/ready" ready)

(def app (-> (http/drive (create-routes))
             (http/journal)
             (http/parser)))

(defn run [port]
  (assert (number? port) "Port must be a number")
  (print (string "Starting server on " port))
  (http/server app "localhost" port))
```


## Testing with Judge

`test-app` is a helper function that keeps the response table intact and makes it easier to test your html endpoints.

```janet
(defn index [_]
  (render [:h1 "heisann"]))

(defn ready [_]
  {:body "Ready"
   :status 200
   :headers {}})
	 
(route :html :get "/" index)
(route :get "/ready" ready)

(test (-> (test-app @{:uri "/" :method "GET"})
          (get :body)) [:h1 "heisann"])

(test (test-app @{:uri "/ready" :method "GET"}) {:body "Ready" :headers {} :status 200})
```

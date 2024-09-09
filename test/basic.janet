(use ../gp-router/init)
(use judge)
(import gp/net/http :as http)
(import spork/htmlgen :as h)

(defn test-app [req]
  (let [f (http/drive (create-test-routes))]
    (f req)))

(test
  (do
    (setdyn :my-routes @[])
    (defn index [_] [:p "hello world!"])
    (defn post-index [_] [:p "hello world"])
    (route :html :get "/" index)
    (route :html :post "/" post-index)
    (create-test-routes identity)) @{"/" @{"GET" @index "POST" @post-index}})

(deftest "testing test-app"
  (do
    (setdyn :my-routes @[])
    (defn index [_] [:p "hello world"])
    (defn not-found [_] [:p "not found"])
    (defn with-param [req] [:p (string "param: " (get-in req [:params :id]))])
    (route :html :get "/test" index)
    (route :html :get :not-found not-found)
    (route :get "/param/:id" with-param)
    (test (test-app @{:method "GET" :uri "/test"}) [:p "hello world"])
    (test (test-app @{:method "GET" :uri "/"}) [:p "not found"])
    (test (test-app @{:method "GET" :uri "/param/2"}) [:p "param: 2"])))

(declare-project
  :name "gp-router"
  :description ```Some helper functions over gp/http ```
  :version "0.0.1"
  :dependencies [{:url "https://git.sr.ht/~pepe/gp"
                  :tag "c28608def28e0e29ac7da9c814b1dbab35fd681f"}
                 {:url "https://github.com/ianthehenry/judge.git" :tag "v2.4.0"}
                 "spork"])

(declare-source
  :prefix "gp-router"
  :source ["gp-router/init.janet"])

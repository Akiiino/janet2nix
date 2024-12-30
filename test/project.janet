(declare-project
  :name "test"
  :description "A tool for building janet programs using the nix package manager" # some example metadata.

  # Optional urls to git repositories that contain required artifacts.
  :dependencies [])

(declare-executable
 :name "test"
 :entry "main.janet"
 :install true)

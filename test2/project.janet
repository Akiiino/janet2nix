(declare-project
  :name "test"
  :description ""
  :dependencies ["https://github.com/janet-lang/jaylib"])

(declare-executable
 :name "test"
 :entry "main.janet"
 :install true)

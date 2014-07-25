CSS_ASSETS = Dir["assets/css/**/*.sass"].map do |s|
  s.gsub(/^assets\/css\//, "").gsub(/\.sass$/, ".css")
end.reject { |e| e == "index.css" }

JS_ASSETS = Dir["assets/js/**/*.coffee"].map do |s|
  s.gsub(/^assets\/js\//, "").gsub(/\.coffee$/, ".js")
end.reject { |e| e == "index.js" }

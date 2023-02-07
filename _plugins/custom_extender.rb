Jekyll::Hooks.register :pages, :post_render do |site|
  puts "Hello World!"
  require "rouge"
end
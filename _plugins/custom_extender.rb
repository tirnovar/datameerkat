Jekyll::Hooks.register :site, :pre_render do |jekyll|
    puts "Adding more JavaScript Markdown aliases..."
end
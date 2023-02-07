Jekyll::Hooks.register :site, :pre_render do |site|
    puts "Adding more JavaScript Markdown aliases..."
end
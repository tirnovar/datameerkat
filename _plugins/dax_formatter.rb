require 'httparty'
require 'net/http'

module Jekyll
    class DAXFormatter < Liquid::Block
        def render(context)
            @dxCode = super
            @params = { query: {embed: 1},body: { fx: @dxCode} }
            @result = HTTParty.post("https://www.daxformatter.com/", @params).parsed_response
            parsed = @result[/<div[^>]*>((.|[\n\r])*)<\/div>/]
            '<div class="codebox">'+parsed+'</div><br>'
        end
    end
end
  
Liquid::Template.register_tag('dax_format', Jekyll::DAXFormatter)
Jekyll::Hooks.register :posts, :pre_render do |posts|
    require "rouge"
  
    # This class defines the PDL lexer which is used to highlight "pdl" code snippets during render-time
module Rouge
    module Lexers    
        class PowerQuery < RegexLexer
        tag 'pq'
        title 'PowerQuery'
        aliases 'pq', 'powerquery', 'm'
        filenames '*.pq'

            def self.detect?(text)
                return true if text.shebang? 'pq'
            end
        
            def self.constants
            @constants ||= Set.new %w(
                as is
            )
            end

            def self.declarations
            @declarations ||= Set.new %w(
                    as is try otherwise else each if then catch and or not error true false meta
                )
              end
            
            def self.keywords
                @keywords ||= Set.new %w(
                let in
                )
            end

            def self.builtins
                @builtins ||= Set.new %w(
                    table type text record list number any null function date time duration binary datetime duration datetimezone
                )
            end

            state :root do
                rule %r/\s+/m, Text
                rule %r(//.*), Comment::Single
                rule %r(/(\\\n)?[*].*?[*](\\\n)?/)m, Comment::Multiline
                rule %r(/[+]), Comment::Multiline
                rule %r/"(\\\\|\\"|[^"])*"/, Str
                rule %r/(?:#")(\\\\|\\"|[^"])*"/, Text
                rule %r/[()]/, Punctuation
                rule %r/#[a-z]+/, Text
                rule %r([-=;,*+><!/|^.%&\?\[\]{}]), Operator
                rule %r/[A-Za-z0-9]+(\.Type)/, Name::Attribute

                rule %r/[A-Z]\w*/, Text
        
                rule %r/[a-z_]\w*/ do |m|
                    name = m[0]
            
                    if self.class.keywords.include? name
                        token Keyword
                    elsif self.class.constants.include? name
                        token Name::Class
                    elsif self.class.declarations.include? name
                        token Name::Class
                    elsif self.class.builtins.include? name
                        token Name::Builtin
                    else
                        token Name
                  end
                end
        
                rule %r((\d+[.]?\d*|\d*[.]\d+)(e[+-]?[0-9]+)?)i, Num::Float
                rule %r/\d+/, Num::Integer
            end
        end
    end
end
end
#--
# DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
# Version 2, December 2004
#
# Copyleft shura [shura1991@gmail.com]
#
# DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
# TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
# 0. You just DO WHAT THE FUCK YOU WANT TO.
#++

autoload :StringIO, 'stringio'

class ConfParser < Hash
  class Section < Hash
    attr_reader :parent

    def initialize (parent)
      super()
      @parent = parent
    end

    alias __get__ []
    def [] (name)
      __get__(name).tap {|x|
        if x.is_a?(String)
          x.gsub!(/\$\((.+?)\)/) {|n|
            (self[$1] || parent[$1]).to_s
          }
        end
      }
    end

    private :__get__
  end

  class << self
    protected :new

    def from_file (file)
      return nil unless File.file?(file)
      self.new(File.open(file))
    end

    def from_io (io)
      return nil unless io.is_a?(IO)
      self.new(io)
    end

    def from_string (str)
      return nil unless str.is_a?(String)
      self.new(StringIO.new(str))
    end
  end

  def initialize (io)
    section, key, lineno = nil, nil, 0

    io.each_line {|line|
      lineno += 1

      case line
      when /^\s*[;#]/ then next
      when /^\s*$/ then next
      when /^\s*(.+?)\s*[=:]\s*(.*)$/
        if section
          self[section] = Section.new(self) unless self[section]
          key = $1
          self[section][key] = $2
        else
          key = $1
          self[key] = $2
        end
      when /^\s*\[(.+?)\]\s*$/
        section = $1
      else
        if key
          if section
            self[section] = Section.new(self) unless self[section]
            self[section][key] += "\n" + line
          else
            self[key] += "\n" + line
          end
        else
          raise "Syntax error at line #{lineno}"
        end
      end
    }
    io.close
  end

  alias __get__ []
  def [] (name)
    __get__(name).tap {|x|
      if x.is_a?(String)
        x.gsub!(/\$\((.+?)\)/) {|n|
          (self[$1]).to_s
        }
      end
    }
  end

    private :__get__
end

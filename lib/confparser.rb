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
  module Template
    def self.included (obj)
      obj.class_eval {
        attr_reader :parent
        alias __get__ []
        alias __set__ []=
        private :__get__, :__set__

        def [] (name)
          __get__(name).tap {|x|
            break x.gsub(/\$\((.+?)\)/) {|n|
              (self[$1] || parent[$1]).to_s
            }.strip if x.is_a?(String)
          }
        end

        def to_s
          map {|key, value|
            value.is_a?(Hash) ? "[#{key}]\n#{value.to_s.gsub(/^/, '  ')}" : "#{key} = #{value.to_s}"
          }.join("\n")
        end
      }
    end
  end

  class Section < Hash
    class << self
      def from_hash (parent, hash)
        raise ArgumentError unless hash.is_a?(Hash)
        return hash if hash.is_a?(self)
        self.new(parent).tap {|sec|
          hash.each {|key, value|
            sec[key] = value
          }
        }
      end
    end

    include Template

    def initialize (parent)
      super()
      @parent = parent
    end

    def []= (key, value)
      raise ArgumentError unless key.is_a?(String) and value.is_a?(String)
      __set__(key.to_s, value.to_s)
    end
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

  include Template

  def initialize (io)
    @parent, section, key, lineno = {}, nil, nil, 0

    io.each_line {|line|
      lineno += 1

      case line
      when /^\s*[;#]/ then next
      when /^\s*(.+?)\s*[=:]\s*(.*)$/
        if section
          __set__(section, Section.new(self)) unless self[section]
          key, self[section][key] = $1, $2
        else
          key, self[key] = $1, $2
        end
      when /^\s*\[(.+?)\]\s*$/
        section, key = $1, nil
      else
        if key
          if section
            __set__(section, Section.new(self)) unless self[section]
            self[section][key] = '' unless self[section][key]
            self[section][key] += "\n" + line
          else
            __set__(key, '') unless self[key]
            self[key] += "\n" + line
          end
        else
          raise "Syntax error at line #{lineno}" unless line =~ /^\s*$/
        end
      end
    }
    io.close
  end

  def []= (key, value)
    raise ArgumentError unless key.is_a?(String) and (value.is_a?(String) or value.is_a?(Hash))
    __set__(key.to_s, (value.is_a?(String) ? value.to_s : Section.from_hash(self, value)))
  end

  def save (path)
    File.open(path, 'w') {|f|
      f.write(self.to_s)
    }
  end
end

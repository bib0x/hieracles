module Hieracles
  class Hiera

    def initialize
      raise IOError, "Hierafile #{Config.hierafile} not found." unless File.exist? Config.path('hierafile')
      @hierafile = Config.path('hierafile')
      @loaded = YAML.load_file(@hierafile)
    end

    def datapath
      raise TypeError, "Sorry hieracles only knows yaml backend for now." unless @loaded[:yaml]
      parampath = File.expand_path(File.join(Config.basepath, datadir))
      raise IOError, "Params dir #{parampath} not found." unless Dir.exist? parampath
      parampath
    end

    def hierarchy
      @loaded[:hierarchy]
    end

    def datadir
      @loaded[:yaml][:datadir]
    end

    def params
      hierarchy.join(',').scan(/%\{(?:::)?([^\}]*)\}/).flatten.uniq
    end

  end
end

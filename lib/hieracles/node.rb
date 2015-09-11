require "net/http"
require "uri"
require "yaml"

module Hieracles
  class Node
    include Hieracles::Utils

    attr_reader :hiera_params, :hiera

    def initialize(fqdn, options)
      Config.load(options)
      @hiera = Hieracles::Hiera.new
      @hiera_params = { fqdn: fqdn }.
        merge(get_hiera_params(fqdn)).
        merge(Config.extraparams)
      @fqdn = fqdn
    end

    def get_hiera_params(fqdn)
      if File.exist?(File.join(Config.encpath, "#{fqdn}.yaml"))
        load = YAML.load_file(File.join(Config.encpath, "#{fqdn}.yaml"))
        sym_keys(load['parameters'])
      else
        puts "Node not found"
        {}
      end
    end

    def files
      @hiera.hierarchy.reduce([]) do |a, f|
        file = format("#{f}.yaml", @hiera_params) rescue nil
        if file && File.exist?(File.join(@hiera.datadir, file))
          a << file
        end
        a
      end
    end

    def paths
      files.map { |p| File.join(@hiera.datadir, p) }
    end

    def params
      params = {}
      paths.each do |f|
        data = YAML.load_file(f)
        s = to_shallow_hash(data)
        s.each do |k,v|
          params[k] ||= []
          params[k] << { value: v, file: f}
        end
      end
      params.sort
    end

    def params_tree
      @_populated_params_tree ||= populate_params_tree(files)
    end

    def modules
      @_populated_modules ||= populate_modules(@farm)
    end

    def add_common
      addfile "params/common/common.yaml"
    end

    def info
      @hiera_params
    end

    def classpath(path)
      format(Config.classpath, path)
    end

    def modulepath(path)
      File.join(Config.modulepath, path)
    end

  private


    def populate_params(files)
      params = {}
      files.each do |f|
        data = YAML.load_file(f)
        s = to_shallow_hash(data)
        s.each do |k,v|
          params[k] ||= []
          params[k] << { value: v, file: f}
        end
      end
      params.sort
    end

    def populate_params_tree(files)
      params = {}
      files.each do |f|
        data = YAML.load_file(f)
        deep_merge!(params, data)
      end
      deep_sort(params)
    end

    def populate_modules(farm)
      classfile = classpath(farm)
      if File.exist?(classfile)
        modules = {}
        f = File.open(classfile, "r")
        f.each_line do |line|
          modules = add_modules(line, modules)
        end
        f.close
        modules
      else
        raise "Class file #{classfile} not found."
      end
    end

    def add_modules(line, modules)
      if /^\s*include\s*([-_:a-zA-Z0-9]*)\s*/.match(line)
        mod = $1
        mainmod = mod[/^[^:]*/]
        if modules[mod]
          modules[mod] += " (duplicate)"
        else
          if Dir.exists? modulepath(mainmod)
            modules[mod] = File.join(Config.modulepath, mainmod)
          else
            modules[mod] = "not found."
          end
        end
      end
      modules
    end

  end
end

require 'fileutils'
require 'json'
require 'yaml'
require 'hieracles/utils'

module Hieracles
  # configuration singleton
  module Config
    include Hieracles::Utils
    extend self

    attr_reader :extraparams, :server, :classpath, :scope, :puppetdb, :usedb,
      :modulepath, :hierafile, :basepath, :encpath, :format, :interactive

    def load(options)
      @optionfile = options[:config] || defaultconfig
      @extraparams = extract_params(options[:params])
      values = get_config(@optionfile)
      @server = values['server']
      @usedb = values['usedb']
      @puppetdb = values['puppetdb']
      @basepath = File.expand_path(options[:basepath] || values['basepath'] || values['localpath'] || '.')
      @classpath = build_path(values['classpath'])
      @modulepath = resolve_path(values['modulepath'] || 'modules')
      @encpath = resolve_path(options[:encpath] || values['encpath'] || 'enc')
      @hierafile = resolve_path(options[:hierafile] || values['hierafile'] || 'hiera.yaml')
      @format = (options[:format] || values['format'] || 'console').capitalize
      facts_file = options[:yaml_facts] || options[:json_facts]
      facts_format = options[:json_facts] ? :json : :yaml
      @scope = sym_keys((facts_file && load_facts(facts_file, facts_format)) || values['defaultscope'] || {})
      @interactive = options[:interactive] || values['interactive']
    end

    def get_config(file)
      initconfig(file) unless File.exist? file
      values = YAML.load_file(file)
    end

    def initconfig(file)
      FileUtils.mkdir_p(File.dirname(file))
      File.open(file, 'w') do |f|
        f.puts '---'
        f.puts '# uncomment if you use the CGI method for discovery'
        f.puts '# server: puppetserver.example.com'
        f.puts 'classpath: manifests/classes/%s.pp'
        f.puts 'modulepath: modules'
        f.puts 'encpath: enc'
        f.puts 'hierafile: hiera.yaml'
      end
    end

    def defaultconfig
      File.join(ENV['HOME'], '.config', 'hieracles', 'config.yml')
    end

    # str is like: something=xxx;another=yyy  
    def extract_params(str)
      return {} unless str
      str.split(';').reduce({}) do |a, k|
        a["#{k[/^[^=]*/]}".to_sym] = k[/[^=]*$/]
        a
      end
    end

    def path(what)
      send(what.to_sym)
    end

    def load_facts(file, format)
      if format == :json
        JSON.parse(File.read(file))
      else
        YAML.load_file(file)
      end
    end

    def resolve_path(path)
      if File.exists?(File.expand_path(path))
        File.expand_path(path)
      elsif File.exists?(File.expand_path(File.join(@basepath, path)))
        File.expand_path(File.join(@basepath, path))
      else
        raise IOError, "File #{path} not found."
      end
    end

    def build_path(path)
      File.expand_path(File.join(@basepath, path))
    end

  end
end

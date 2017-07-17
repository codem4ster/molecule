module Molecule
  module Router

    def route_store
      @routes ||= {}
    end

    def route(path, options)
      route_store[path] = options
    end

  end
end
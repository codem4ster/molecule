class MoleculeController < ApplicationController
  def spa
    router = Router.new
    router.routes
    @parts = router.route_store[request.path]
    raise RuntimeError, 'Route cannot found:' + request.path unless @parts
  end
end
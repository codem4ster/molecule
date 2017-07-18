class MoleculeController < ApplicationController
  def spa
    if request.user_agent =~ /(Applebot|baiduspider|Bingbot|Googlebot|ia_archiver|msnbot|Naverbot|seznambot|Slurp|teoma|Twitterbot|Yandex|Yeti)/
      cookies['_sid'] = Molecule::SessionStart.run!(guid: cookies['_sid'])
      router = Router.new
      router.routes
      @parts = router.route_store[request.path]
      raise 'Route cannot found:' + request.path unless @parts
      render 'molecule/bots'
    else
      PowerStrip.start
      render 'molecule/non-bots'
    end
  end
end
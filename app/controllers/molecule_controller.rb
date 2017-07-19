# This is the main Controller for molecule it handles SPA requests
class MoleculeController < ApplicationController

  BOTS = %w[Applebot baiduspider Bingbot Googlebot ia_archiver msnbot
            Naverbot seznambot Slurp teoma Twitterbot Yandex Yeti].freeze
  def spa
    return render 'molecule/non-bots' unless bot?
    cookies['_sid'] = Molecule::SessionStart.run!(guid: cookies['_sid'])
    find_route
    render 'molecule/bots'
  end

  private

  def bot?
    request.user_agent =~ /(#{BOTS.join('|')})/
  end

  def find_route
    router = Router.new
    router.routes
    @parts = router.route_store[request.path]
    raise 'Route cannot found:' + request.path unless @parts
  end
end
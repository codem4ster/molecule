module MoleculeHelper

  def component(name, options = {})
    comp = name.new
    comp.props = options
    comp.parse
  end

end
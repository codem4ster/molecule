module MoleculeHelper

  def component(name, options = {})
    comp = name.new
    comp.props = options
    '<script id="from-server" type="text/javascript">server_rendered=true</script>' + comp.parse
  end

end
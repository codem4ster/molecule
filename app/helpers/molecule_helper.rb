module MoleculeHelper

  def component(name, options = {}, &block)
    comp = name.new
    comp.props = options
    script = "<script type=\"text/javascript\">var __server_rendered__ = true</script>\n"
    script + comp.parse(&block)
  end

end
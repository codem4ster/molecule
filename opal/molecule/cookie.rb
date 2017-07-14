module Molecule
  class Cookie
    class << self

      def get(cname)
        `
        var result = false;
        var name = #{cname} + "=";
          var ca = document.cookie.split(';');
          for(var i = 0; i < ca.length; i++) {
              var c = ca[i];
              while (c.charAt(0) == ' ') {
                  c = c.substring(1);
              }
              if (c.indexOf(name) == 0) {
                  result = c.substring(name.length, c.length);
              }
          }`
        `result`
      end

      def set(cname, cvalue, expire)
        `var d = new Date();
        d.setTime(d.getTime() + (#{expire * 1000}));
        var expires = "expires="+d.toUTCString();
        document.cookie = #{cname} + "=" + #{cvalue} + ";" + expires + ";path=/";`
      end

    end
  end
end
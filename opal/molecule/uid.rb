module Molecule
  class Uid

    @chars = %w[a A b B c C ç Ç d D e E f F g G ğ Ğ h H ı I i İ j J k K l L m M]
    @chars += %w[n N o O ö Ö p P q Q r R s S ş Ş t T u U ü Ü x X w W v V y Y z Z]
    @chars += %w[0 1 2 3 4 5 6 7 8 9 . _ - / # | @ = + * &]


    def self.generate(digit)
      @chars.sample(digit).join
    end
  end
end
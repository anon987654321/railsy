module Brgen
  class UtilityMethods
    def self.random_id
      SecureRandom.hex(3)
    end
  end
end


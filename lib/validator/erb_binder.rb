require 'ostruct'

module Validator
  class ErbBinder < OpenStruct
    def initialize struct
      super struct.marshal_dump
    end

    def get_binding
      return binding()
    end
  end
end

require 'miasma'

module Miasma
  module Types

    # Base data container
    class ThinModel < Data

      class << self

        # Get/Set fat model
        #
        # @param klass [Class] fat model class
        # @return [Class] fat model class
        def model(klass)
          if(klass)
            unless(klass.ancestors.include?(Miasma::Types::Model))
              raise TypeError.new "Expecting `Miasma::Types::Model` subclass! (got #{klass})"
            else
              self._model = klass
            end
          end
          self._model
        end

        protected

        # @return [Class] fat model class
        attr_accessor :_model

      end

      # @return [Miasma::Types::Api] service API
      attr_reader :api

      # Build new instance
      #
      # @param api [Miasma::Types::Api] service API
      # @param args [Hash] model data
      def initailize(api, args={})
        super args
      end

      # @return [FalseClass]
      # @note thin models are always false
      def persisted?
        false
      end

      # Associated model class
      #
      # @return [Class] of type Miasma::Types::Model
      # @note will deconstruct namespace and rebuild using provider
      def model
        if(self.class.model)
          self.class.model.to_s.split('::').insert(
            3, Utils.camel(api.provider)
          ).inject(Object) do |memo, konst|
            memo.const_get(konst)
          end
        else
          raise NotImplementedError.new "No associated model for this thin model type (#{self.class})"
        end
      end

      # Build fat model instance
      #
      # @return [Miasma::Types::Model]
      def expand
        model.new(api, :id => self.id).reload
      end

    end

  end
end

# frozen_string_literal: true

module SupportEngine
  # Group concerns
  module Concerns
    # Helper modules and methods for contracts
    module Contracts
      # Checksum property allows to generate and remap existing properties to
      # their SHA256 checksum version allowing to build new attributes
      # (mostly primary and secondary key fields) based on other contract values
      #
      # @example Builds a new contract with id based on the sha of an email property
      #
      # class New < ApplicationContract
      #   property :email
      #
      #   checksum_property :id, from: %i[email]
      # end
      #
      # @example Builds a commit_id field based on the repository.id and commit_hash
      #   Note that we cannot use a direct key map as repository is an object on which
      #   we use the #id method. That's why we had to use a proc instead
      #
      # class Create < ApplicationContract
      #   property :repository
      #   property :commit_hash
      #
      #   checksum_property :commit_id, from: -> { [repository.id, commit_hash] }
      # end
      module ChecksumProperty
        extend ActiveSupport::Concern

        class_methods do
          # @overload checksum_property(name, from:)
          #   Tells a contract that it should build checksum property based on the array
          #   with names of the arguments
          #   @param name [Symbol] Name of a property under which the generated value will
          #     be stored
          #   @param from [Array<Symbol>] array with names of properties that will be used to
          #     build checksum property
          # @overload checksum_property(name, from:)
          #   Tells contract that it should build checksum property based on the proc
          #   return value (that needs to be array)
          #   @param name [Symbol] Name of a property under which the generated value will
          #     be stored
          #   @param from [Proc] Proc that will be evaluated in the contract context
          #   @param type [Class] type of digest that we want to use
          def checksum_property(name, from: [], type: OpenSSL::Digest::SHA256)
            property name
            validates name, presence: true

            define_method(name) do
              cached_value = instance_variable_get(:"@#{name}")
              return cached_value if cached_value

              new_value = type.hexdigest(values(name, from).join(''))
              instance_variable_set(:"@#{name}", new_value)

              public_send(:"#{name}=", new_value)
            end
          end
        end

        # Build values from proc or array
        # @overload values(from)
        #   @param name [Symbol] Name of a property under which the generated value will
        #     be stored
        #   @param from [Array<Symbol>] array with names
        # @overload values(from)
        #   @param name [Symbol] Name of a property under which the generated value will
        #     be stored
        #   @param from [Proc] proc that will be evaluated in the contract context
        def values(name, from)
          if from.is_a?(Proc)
            instance_exec(&from)
          else
            from.map do |key|
              key == name ? super() : public_send(key)
            end
          end
        end
      end
    end
  end
end

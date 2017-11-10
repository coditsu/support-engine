# frozen_string_literal: true

RSpec.describe SupportEngine::Concerns::Contracts::ChecksumProperty do
  describe '.checksum_property' do
    subject(:checksum_property) { base_contract.new(base_class.new) }

    let(:base_class) do
      Class.new do
        attr_accessor :test1, :test2

        def email
          rand.to_s
        end

        def name
          rand.to_s
        end
      end
    end

    let(:base_contract) do
      included_class = described_class

      Class.new(::Reform::Form) do
        include ::Reform::Form::Property
        include ::Reform::Form::ActiveModel
        include ::Reform::Form::ActiveModel::Validations
        include included_class

        property :name
        property :email

        checksum_property :test1, from: %i[email]
        checksum_property :test2, from: -> { [email, name] }
      end
    end

    it { expect(checksum_property.test1).not_to be_empty }
    it { expect(checksum_property.test1).to be_instance_of(String) }
    it { expect(checksum_property.test2).not_to be_empty }
    it { expect(checksum_property.test2).to be_instance_of(String) }
  end
end

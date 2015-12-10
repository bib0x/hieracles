require 'spec_helper'

describe Hieracles::Puppetdb::Query do

  describe '.new' do
    let(:elements) { [ 'something=value' ] }
    let(:query) { Hieracles::Puppetdb::Query.new elements }
    before {
      allow(query).
        to receive(:parse).
        with(elements).
        and_return(['=', 'something', 'value'])
    }
    it { expect(query.instance_variable_get(:@elements)).to eq ['=', 'something', 'value'] }
  end

  describe '.parse' do
    context 'with a single argument not matching an assignment' do
      let(:elements) { [ 'anything' ] }
      let(:expected) { [] }
      let(:query) { Hieracles::Puppetdb::Query.new elements }
      it { expect(query.instance_variable_get(:@elements)).to eq expected }
    end
    context 'with a single argument matching an assignment' do
      let(:elements) { [ 'something=value' ] }
      let(:expected) { ['=', 'something', 'value'] }
      let(:query) { Hieracles::Puppetdb::Query.new elements }
      it { expect(query.instance_variable_get(:@elements)).to eq expected }
    end
    context 'with 2 arguments matching an assignment' do
      let(:elements) { [ 'something=value', 'another=else' ] }
      let(:expected) { [['=', 'something', 'value'], ['=', 'another', 'else']] }
      let(:query) { Hieracles::Puppetdb::Query.new elements }
      #it { expect(query.instance_variable_get(:@elements)).to eq expected }
    end

  end

end
# -*- rspec -*-
# encoding: utf-8

require_relative '../helpers'

describe 'Basic type mapping' do
	describe PG::BasicTypeRegistry do
		it "can register_type" do
			regi = PG::BasicTypeRegistry.new
			regi.register_type(1, 'int4', PG::BinaryEncoder::Int8, PG::BinaryDecoder::Integer)

			expect( regi.coders_for(1, :encoder)['int4'] ).to be_kind_of(PG::BinaryEncoder::Int8)
			expect( regi.coders_for(1, :decoder)['int4'] ).to be_kind_of(PG::BinaryDecoder::Integer)
		end

		it "can alias_type" do
			regi = PG::BasicTypeRegistry.new
			regi.register_type(1, 'int4', PG::BinaryEncoder::Int4, PG::BinaryDecoder::Integer)
			regi.alias_type(1, 'int8', 'int4')

			expect( regi.coders_for(1, :encoder)['int8'] ).to be_kind_of(PG::BinaryEncoder::Int4)
			expect( regi.coders_for(1, :decoder)['int8'] ).to be_kind_of(PG::BinaryDecoder::Integer)
		end

		it "can register_coder" do
			regi = PG::BasicTypeRegistry.new
			enco = PG::BinaryEncoder::Int8.new(name: 'test')
			regi.register_coder(enco)

			expect( regi.coders_for(1, :encoder)['test'] ).to be(enco)
			expect( regi.coders_for(1, :decoder)['test'] ).to be_nil
		end

		it "checks format and direction in coders_for" do
			regi = PG::BasicTypeRegistry.new
			expect( regi.coders_for 0, :encoder ).to eq( nil )
			expect{ regi.coders_for 0, :coder }.to raise_error( ArgumentError )
			expect{ regi.coders_for 2, :encoder }.to raise_error( ArgumentError )
		end

		context "class methods" do
			let!(:regi){ PG::BasicTypeRegistry::DEFAULT_TYPE_REGISTRY }

			it "can register_type" do
				expect do
					PG::BasicTypeRegistry.register_type(1, 'testtype1', PG::BinaryEncoder::Int8, PG::BinaryDecoder::Integer)
				end.to output(/deprecated/).to_stderr

				expect( regi.coders_for(1, :encoder)['testtype1'] ).to be_kind_of(PG::BinaryEncoder::Int8)
				expect( regi.coders_for(1, :decoder)['testtype1'] ).to be_kind_of(PG::BinaryDecoder::Integer)
			end

			it "can alias_type" do
				expect do
					PG::BasicTypeRegistry.alias_type(1, 'testtype2', 'int4')
				end.to output(/deprecated/).to_stderr

				expect( regi.coders_for(1, :encoder)['testtype2'] ).to be_kind_of(PG::BinaryEncoder::Int4)
				expect( regi.coders_for(1, :decoder)['testtype2'] ).to be_kind_of(PG::BinaryDecoder::Integer)
			end

			it "can register_coder" do
				enco = PG::BinaryEncoder::Int8.new(name: 'testtype3')
				expect do
					PG::BasicTypeRegistry.register_coder(enco)
				end.to output(/deprecated/).to_stderr

				expect( regi.coders_for(1, :encoder)['testtype3'] ).to be(enco)
				expect( regi.coders_for(1, :decoder)['testtype3'] ).to be_nil
			end
		end
	end
end

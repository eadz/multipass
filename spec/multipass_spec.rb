require 'spec_helper'

describe MultiPass do
  let(:site_key) { 'ha8a-l515-fan1nay' }
  let(:api_key)  { 'ha8a-l515-fan1nay' }
  let(:expires)  { nil }
  let(:data)     { {'foo' => '1', 'bar' => '2' } }

  let(:encoded) { MultiPass.encode(site_key, api_key, data, expires) }

  let(:decode) { -> { MultiPass.decode(site_key, api_key, encoded) } }

  describe '.decode' do
    it 'decodes the data' do
      expect(decode.call).to eq(data)
    end

    describe 'invalid encrypion' do
      let(:encoded) { 'abcdefg' }
      it 'raises a DecryptError' do
        expect{ decode.call }.to raise_error(MultiPass::DecryptError)
      end
    end

    describe 'invalid key' do
      it 'raises a DecryptError' do
        expect{ MultiPass.decode(site_key, api_key+'foo', encoded) }.to raise_error(MultiPass::DecryptError)
      end
    end

    describe 'missing keys' do
      let(:site_key) { nil }
      it 'raises a MissingKeyError' do
        expect{ decode.call }.to raise_error(MultiPass::MissingKeyError)
      end
    end

    describe 'blank keys' do
      let(:site_key) { '' }
      it 'raises a MissingKeyError' do
        expect{ decode.call }.to raise_error(MultiPass::MissingKeyError)
      end
    end

    describe 'expiry' do

      context 'with an expiry in the future' do
        let(:expires) { Time.now + 60 }
        it 'decodes the data' do
          expect(decode.call).to eq(data)
        end
      end

      context 'with an expiry in the past' do
        let(:expires) { Time.now - 60 }
        it 'raises an expired error' do
          expect{ decode.call }.to raise_error(MultiPass::ExpiredError)
        end
      end

      context 'specifing a nil expiry' do
        let!(:encoded) { MultiPass.encode(site_key, api_key, data, nil) }

        it 'has no expiry' do
          Timecop.freeze(Time.now + 60*60*24*30) do # month in the future
            expect(decode.call).to eq(data)
          end
        end
      end

      context 'not specifiying an expiry ( default: 30 seconds)' do
        let!(:encoded) { MultiPass.encode(site_key, api_key, data) }

        it 'is valid now' do
          Timecop.freeze(Time.now) do
            expect(decode.call).to eq(data)
          end
        end

        it 'expires in 30 seconds' do
          Timecop.freeze(Time.now + 31) do # 31 seconds in the future
            expect{ decode.call }.to raise_error(MultiPass::ExpiredError)
          end
        end
      end
    end
  end

  describe '.encode' do
    context 'uses an initialization vector' do
      let(:expires) { Time.parse("2020-01-01") }
      let(:encoded_1) { MultiPass.encode(site_key, api_key, data, expires) }
      let(:encoded_2) { MultiPass.encode(site_key, api_key, data, expires) }

      it 'so each encrypted string is different' do
        expect(encoded_1).to_not eq(encoded_2)
      end

      it 'both decodes to the same data' do
        decoded_1 = MultiPass.decode(site_key, api_key, encoded_1)
        decoded_2 = MultiPass.decode(site_key, api_key, encoded_2)
        expect(decoded_1).to eq(decoded_2)
      end
    end
  end

  it 'has a version number' do
    expect(MultiPass::VERSION).not_to be nil
  end
end

require 'pry'
require 'vcr'

describe SolanaRpcRuby::ApiClient do
  describe '#initialize' do
    let(:testnet_cluster) { 'https://api.testnet.solana.com' }
    let(:mainnet_cluster) { 'https://api.mainnet-beta.solana.com' }

    before :all do 
      SolanaRpcRuby.config do |c|
        c.json_rpc_version = '2.0'
        c.cluster = 'https://api.testnet.solana.com'
        c.encoding = 'base58'
      end
    end

    it 'fails without cluster passed in' do
      SolanaRpcRuby.config do |c|
        c.cluster = nil
      end

      expect { described_class.new }.to raise_error(ArgumentError)

      SolanaRpcRuby.config do |c|
        c.cluster = testnet_cluster
      end
    end

    it 'allows to set cluster' do
      api_client = described_class.new(testnet_cluster)
      
      expect(api_client.cluster).to eq(testnet_cluster)
    end

    it 'allows to override cluster from config' do
      api_client = described_class.new(mainnet_cluster)
      
      expect(api_client.cluster).to_not eq(SolanaRpcRuby.cluster)
      expect(api_client.cluster).to eq(mainnet_cluster)
    end
  end
end
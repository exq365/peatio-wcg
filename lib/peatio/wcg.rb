require 'peatio/services/blockchain_service/wcg'
require 'peatio/services/wallet_service/wcg'
require 'peatio/client/blockchain_client/wcg'
require 'peatio/client/wallet_client/wcg'

module Peatio
  module Wcg
    require "peatio/wcg/version"

    # init plugins
    Peatio::WalletService.register_adapter(:wcg, WalletServiceWcg)
    Peatio::BlockchainService.register_adapter(:wcg, BlockchainServiceWcg)
  end
end

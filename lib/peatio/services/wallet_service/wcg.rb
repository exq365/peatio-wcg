# encoding: UTF-8
# frozen_string_literal: true
require 'peatio/helpers/coin_helper'

class WalletServiceWcg < Peatio::WalletService::Abstract

  DEFAULT_FEE = 1000000

  include Peatio::WalletService::Helpers
  include Peatio::Wcg::CoinHelper

  def client
    @client ||= WalletClientWcg.new(@wallet)
  end

  def create_address!(options = {})
    client.create_address!(options)
  end

  def collect_deposit!(deposit, options = {})
    if is_token_asset?(deposit.currency)
      collect_asset_deposit(deposit, options)
    else
      collect_coin_deposit(deposit, options)
    end
  end

  def build_withdrawal!(withdraw, options = {})
    if is_token_asset?(withdraw.currency)
      build_asset_withdrawal(withdraw, options)
    else
      build_coin_withdrawal(withdraw, options)
    end
  end

  def deposit_collection_fees(deposit, options = {})
    fees_wallet = txn_fees_wallet
    destination_address = deposit.account.payment_address.address

    client.create_coin_withdrawal!(
        {address: fees_wallet.address, secret: fees_wallet.secret},
        {address: destination_address},
        DEFAULT_FEE,
        options
    )
  end

  def load_balance(address, currency)
    client.load_balance!(address, currency)
  end

  private

  def txn_fees_wallet
    Wallet
      .active
      .find_by(currency_id: :wcg, kind: :fee)
  end

  def collect_coin_deposit(deposit, options = {})
    pa = deposit.account.payment_address

    spread_hash = spread_deposit(deposit)
    spread_hash.map do |address, amount|

      amount *= deposit.currency.base_factor
      amount -= DEFAULT_FEE

      client.create_coin_withdrawal!(
          {address: pa.address, secret: pa.secret},
          {address: address},
          amount.to_i,
          options
      )
    end
  end

  def collect_asset_deposit(deposit, options = {})
    pa = deposit.account.payment_address

    spread_hash = spread_deposit(deposit)
    spread_hash.map do |address, amount|
      amount *= deposit.currency.base_factor
      client.create_asset_withdrawal!(
          {address: pa.address, secret: pa.secret},
          {address: address},
          amount.to_i,
          options.merge(token_asset_id: token_asset_id(deposit.currency))
      )
    end
  end

  def build_coin_withdrawal(withdraw, options = {})
    client.create_coin_withdrawal!(
        {address: @wallet.address, secret: @wallet.secret},
        {address: withdraw.rid},
        withdraw.amount_to_base_unit!,
        options
    )
  end

  def build_asset_withdrawal(withdraw, options = {})
    client.create_asset_withdrawal!(
        {address: @wallet.address, secret: @wallet.secret},
        {address: withdraw.rid},
        withdraw.amount_to_base_unit!,
        options.merge(token_asset_id: token_asset_id(withdraw.currency))
    )
  end
end

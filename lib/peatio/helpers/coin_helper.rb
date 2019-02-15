module Peatio::Wcg::CoinHelper

  def is_token_currency?(currency)
    currency
        .options
        .symbolize_keys
        .fetch(:token_currency_id, nil)
        .present?
  end

  def is_token_asset?(currency)
    currency
        .options
        .symbolize_keys
        .fetch(:token_asset_id, nil)
        .present?
  end

  def token_asset_id(currency)
    currency
        .options
        .symbolize_keys
        .fetch(:token_asset_id, nil)
  end
end

# encoding: UTF-8
# frozen_string_literal: true

class BlockchainService::Wcg < Peatio::BlockchainService::Abstract
  BlockGreaterThanLatestError = Class.new(StandardError)
  FetchBlockError = Class.new(StandardError)
  EmptyCurrentBlockError = Class.new(StandardError)

  include Peatio::BlockchainService::Helpers

  delegate :case_sensitive?, to: :client

  def fetch_block!(block_number)
    raise BlockGreaterThanLatestError if block_number > latest_block_number

    @block_json = client.get_block(client.get_block_hash(block_number))
    @block_json['number'] = block_number unless @block_json.blank?

    if @block_json.blank? || @block_json['transactions'].blank?
      raise FetchBlockError
    end
  end

  def current_block_number
    require_current_block!
    @block_json['number']
  end

  def latest_block_number
    @cache.fetch(cache_key(:latest_block), expires_in: 5.seconds) do
      client.latest_block_number
    end
  end

  def client
    @client ||= BlockchainClient::Wcg.new(@blockchain)
  end

  def filtered_deposits(payment_addresses, &block)
    require_current_block!
    @block_json
        .fetch('transactions')
        .each_with_object([]) do |txn, deposits|

      next if client.invalid_transaction?(txn) # skip if invalid transaction

      payment_addresses
          .where(address: client.to_address(txn))
          .each do |payment_address|


        deposit_txs = client.build_transaction(txn, current_block_number, payment_address.currency)

        deposit_txs.fetch(:entries).each_with_index do |entry, i|

          if entry[:amount] <= payment_address.currency.min_deposit_amount
            # Currently we just skip small deposits. Custom behavior will be implemented later.
            Rails.logger.info do
              "Skipped deposit with txid: #{deposit_txs[:id]} with amount: #{entry[:amount]}"\
                                     " from #{entry[:address]} in block number #{deposit_txs[:block_number]}"
            end
            next
          end

          deposits << {txid: deposit_txs[:id],
                       address: entry[:address],
                       amount: entry[:amount],
                       member: payment_address.account.member,
                       currency: payment_address.currency,
                       txout: i,
                       block_number: deposit_txs[:block_number],
                       options: deposit_txs[:options]}

          block.call(deposit) if block_given?
          deposits << deposit
        end
      end
    end
  end

  def filtered_withdrawals(withdrawals, &block)
    require_current_block!
    @block_json
        .fetch('transactions')
        .each_with_object([]) do |txn, withdrawals_h|

      withdrawals
          .where(txid: txn.fetch('transaction'))
          .each do |withdraw|

        next if client.invalid_transaction?(txn) # skip if invalid transaction

        withdraw_txs = client.build_transaction(txn, @block_json['number'], withdraw.currency)
        withdraw_txs.fetch(:entries).each do |entry|
          withdrawal =  { txid:           withdraw_txs[:id],
                          rid:            entry[:address],
                          amount:         entry[:amount],
                          block_number:   withdraw_txs[:block_number] }
          block.call(withdrawal) if block_given?
          withdrawals_h << withdrawal
        end
      end
    end
  end

  def filter_unconfirmed_txns(payment_addresses, &block)
    Rails.logger.info {"Processing unconfirmed deposits."}

    txns = client.get_unconfirmed_txns

    # Read processed mempool tx ids because we can skip them.
    processed = @cache.read("processed_wcg_mempool_txids") || []

    @block_json['transactions'] = txns - processed
    @block_json['number'] = nil
    filtered_deposits(payment_addresses, &block)

    # Store processed tx ids from mempool.
    @cache.write("processed_wcg_mempool_txids", txns)
  end

  def process_pending_txns(pending_txns, &block)
    pending_txns.each do |deposit|
      # approved = true, false or nil
      approved = client.get_phasing_poll(deposit.txid)
      block.call(deposit, approved) if block_given?
    end
  end

  private
  def require_current_block!
    raise EmptyCurrentBlockError if @block_json.blank?
  end
end




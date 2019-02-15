# Peatio::Wcg

Peatio Plugin to enable WCG coin.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'peatio-wcg', github: 'skyach/peatio-wcg', branch: 'feature/v2'
```

And then execute:

    $ bundle

## Usage in peatio


`Coin:` config/seeds/currencies.yml

```
- id:                   wcg
  blockchain_key:       ~
  symbol:               'W'
  type:                 coin
  precision:            8
  base_factor:          1_00_000_000   # IMPORTANT: Don't forget to update this variable according
  enabled:              true
  # Deposits with less amount are skipped during blockchain synchronization.
  # We advise to set value 10 times bigger than the network fee to prevent losses.
  min_deposit_amount:    0.01
  min_collection_amount: 0.01
  withdraw_limit_24h:    300
  withdraw_limit_72h:    600
  deposit_fee:          0
  withdraw_fee:         0
  options:              {}
```

`Asset:` config/seeds/currencies.yml

```
- id:                   ~
  blockchain_key:       ~
  symbol:               ~
  type:                 coin
  is_token:             true
  precision:            4
  base_factor:          10_000 # IMPORTANT: Don't forget to update this variable according
  enabled:              true
  # Deposits with less amount are skipped during blockchain synchronization.
  # We advise to set value 10 times bigger than the network fee to prevent losses.
  min_deposit_amount:    0.01
  min_collection_amount: 0.01
  withdraw_limit_24h:    300
  withdraw_limit_72h:    600
  deposit_fee:          0
  withdraw_fee:         0
  options:
    #
    # Asset configuration
    token_asset_id:    '0000000000000000'   
  
```

`configure application.yml:` config/application.yml

```
  GATEWAYS: 'wcg' # along side other gateways

  BLOCKCHAIN_CLIENTS: 'wcg' # along side other blockchain clients
```
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/peatio-wcg. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Peatio::Wcg project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/peatio-wcg/blob/master/CODE_OF_CONDUCT.md).

# Peatio::Wcg

Peatio Plugin to enable WCG coin.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'peatio-wcg'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install peatio-wcg

## Usage in peatio


`Coin:` config/seeds/currencies.yml

```
- id:                   ~
  blockchain_key:       ~
  symbol:               ~
  type:                 coin
  precision:            8
  base_factor:          1_00_000_000
  enabled:              ~
  quick_withdraw_limit: ~
  min_deposit_amount:  0.01
  deposit_fee:          ~
  withdraw_fee:         ~
  options:              {}
```

`Asset:` config/seeds/currencies.yml

```
  options:
    token_asset_id:    '000000000000000'          
  
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/peatio-wcg. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Peatio::Wcg project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/peatio-wcg/blob/master/CODE_OF_CONDUCT.md).

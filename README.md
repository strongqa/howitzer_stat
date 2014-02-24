Howitzer Pages Usage Statistics
===============================

[Howitzer](http://romikoops.github.io/howitzer/) extension for test coverage visualisation of each your web application page

This extension consists from 2 parts:
- Sinatra based REST web service
- Client files(js, css, html markup) for injection to testable web app

## Requirements

**Ruby 1.9.3++**

## Demo

Coming soon...

## Documentation

* [Ruby installation in production](https://github.com/romikoops/howitzer_stat/wiki/Ruby-installation-in-production)
* [Deployment to production](https://github.com/romikoops/howitzer_stat/wiki/Deployment-to-production)
* [Settings List](https://github.com/romikoops/howitzer_stat/wiki/Settings-List)
* [REST API Documentation](https://github.com/romikoops/howitzer_stat/wiki/REST-API)
* [Howitzer](http://romikoops.github.io/howitzer)

## Limitation

* It does not support many branches and environments
* It only support Cucumber scenario now
* It is still required to cover by unit tests(both client and server part)

Hopefully these limitations will be eliminated in upcoming releases

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Development Environment

* Create config/custom.yml with following properties:

```
path_to_source: ./demo
port: 7000
domain: localhost
```

* Specify correct path to real howitzer based project(path_to_source setting)
* Start service:

`unicorn -p 7000`

* Navigate to url `http://localhost:7000/test?page=SomePage`

where *SomePage* is one of Ruby page classes

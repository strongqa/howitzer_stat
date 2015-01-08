Howitzer Stat
===============================

[![Build Status](https://travis-ci.org/strongqa/howitzer_stat.png?branch=master)](https://travis-ci.org/strongqa/howitzer_stat)
[![Dependency Status](https://gemnasium.com/romikoops/howitzer_stat.png)](https://gemnasium.com/romikoops/howitzer_stat)

[Howitzer](http://strongqa.github.io/howitzer/) extension used for automated tests coverage visualization of web application pages.

This extension consists of 2 components:
- REST web service based on Sinatra
- Client files (js, css, html markup) intended for injection to a testable web application

## Requirements

**Ruby 1.9.3+**

## Demo

* <a href="https://raw.githubusercontent.com/strongqa/howitzer_stat/gh-pages/images/1_accounts_page.png" target="_blank">Screenshot1</a>
* <a href="https://raw.githubusercontent.com/strongqa/howitzer_stat/gh-pages/images/2_accounts_page_with_stat.png" target="_blank">Screenshot2</a>
* <a href="https://raw.githubusercontent.com/strongqa/howitzer_stat/gh-pages/images/3_accounts_page_with_expanded_stat.png" target="_blank">Screenshot3</a>

Real demo application is coming soon...


## Documentation

* [Ruby installation in production](https://github.com/strongqa/howitzer_stat/wiki/Ruby-installation-in-production)
* [Deployment to production](https://github.com/strongqa/howitzer_stat/wiki/Deployment-to-production)
* [Client integration](https://github.com/strongqa/howitzer_stat/wiki/Client-integration)
* [Settings List](https://github.com/strongqa/howitzer_stat/wiki/Settings-List)
* [REST API Documentation](https://github.com/strongqa/howitzer_stat/wiki/REST-API)
* [Howitzer](http://strongqa.github.io/howitzer)

## Limitations

* Not many branches and environments are supported.
* Currently only Cucumber scenario can be applied.
* The extension is to be covered by unit tests (both client and server part).
* The Demo web application with HowitzerStat is not available.

We expect to eliminate these limitations in the upcoming releases.

## Contributing

1. Fork the project.
2. Create a new feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push the branch (`git push origin my-new-feature`)
5. Create a new pull request.

### Development Environment

* Create `config/custom.yml` with the following properties:

```
path_to_source: ./demo
port: 7000
domain: localhost
```

* Specify a correct path to the real howitzer based project (path_to_source setting).
* Run a service:

`unicorn -p 7000`

* Navigate to url `http://localhost:7000/test?page=SomePage`

where *SomePage* is one of the Ruby page classes.

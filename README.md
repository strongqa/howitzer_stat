Howitzer Pages Usage Statistics
===============================

Client/Server Howitzer extension for coverage visualisation  of each web page by Cucumber/RSpec scenarios

This project is **under active development** now...

# Architecture

## Client Side

Javascript code which will be injected to layout of web app.
Purpose:
  - send current url and page title to small REST web service
  - receive scenarios list in JSON format
  - render data via predefined underscore.js template

We can be inspired by UI from this video: http://railscasts.com/episodes/368-miniprofiler

## Server Side

Small REST web service with Sinatra(about 40 lines of code, that is all)
Purpose:
  - receive page title and url
  - identify appropriate Ruby class for the page(we already have uniq Regular expression in each Page class)
  - find all step definitions, which are using the Page class
  - find all scenarios with steps which are matched to the step definitions
  - response the scenarios in JSON format

To speed up performance of web service, it makes sense to implement some auxiliary Ruby task in order to generate predefined JSON data for all pages in advance.

The entire application is contained within the api.rb file.

config.ru is a minimal Rack configuration for unicorn.

## Requirements

**Ruby 2.0+**

## Install

    bundle install

## Run the app

    unicorn -p 7000

# REST API

The REST API to the app is described below.

## Get all Page Classes

### Request

`GET /page_classes`

    curl -i -H 'Accept: application/json' http://localhost:7000/page_classes

### Response

    HTTP/1.1 200 OK
    Date: Sat, 04 Jan 2014 15:13:14 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 12
    X-Content-Type-Options: nosniff

    ["testpage"]

## Get Page Classe by title and url

### Request

`GET /page_classes?url=<current page url>&title=<current page title>`

    curl -i -H 'Accept: application/json' http://localhost:7000/page_classes?url=http://test.com&title=Welcome%20to%20Test%20Site

### Response

    HTTP/1.1 200 OK
    Date: Sat, 04 Jan 2014 15:20:49 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 19
    X-Content-Type-Options: nosniff

    {"page":"TestPage"}


## Get statistic for specific Page Class

### Request

`GET /pages/:page_class`

    curl -i -H 'Accept: application/json' http://localhost:7000/pages/TestPage

### Response

    HTTP/1.1 200 OK
    Date: Sat, 04 Jan 2014 14:06:19 GMT
    Status: 200 OK
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 215
    X-Content-Type-Options: nosniff

    [{"feature":{"name":"...","description":"...","path_to_file":"...","line":1},"scenarios":[{"scenario":{"name":"...","line":10},"steps":[{"text":"...","line":11,"used":"yes"},{"text":"...","line":12,"used":"no"}]}]}]

## Get statistic for a non-existent Page Class

### Request

`GET /pages/:page_class`

    curl -i -H 'Accept: application/json' http://localhost:7000/pages/UnknownPage

### Response

    HTTP/1.1 404 Not Found
    Date: Sat, 04 Jan 2014 13:50:09 GMT
    Status: 404 Not Found
    Connection: close
    Content-Type: application/json;charset=utf-8
    Content-Length: 58
    X-Content-Type-Options: nosniff

    {"status":404,"reason":"Page 'UnknownPage' was not found"}

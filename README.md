howitzer_stat
=============

Client/Server Howitzer extension for coverage visualisation  of each web page by Cucumber/RSpec scenarios

This project is **under active development** now...

## Requirements

**Ruby 2.0+**

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
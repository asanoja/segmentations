require 'selenium-webdriver'
require 'base64'
require 'uri'
require 'fileutils'

driver = Selenium::WebDriver.for :chrome
driver.navigate.to "about:black"
driver.manage.window.resize_to(1024,768)
$stdin.read

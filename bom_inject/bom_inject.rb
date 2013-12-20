require 'selenium-webdriver'

def filename(url)
end

Selenium::WebDriver::Firefox::Binary.path='/usr/bin/firefox'

driver = Selenium::WebDriver.for :firefox

load_dump = <<FIN
function func_dump() {
	var script = document.createElement('script');
	script.type = "text/javascript"
	script.setAttribute("id","pagelyzerinject");
	script.setAttribute("src","http://www-poleia.lip6.fr/~sanojaa/BOM/bom2.js");
	document.getElementsByTagName('head')[0].appendChild(script);
}

var callback = arguments[arguments.length - 1];
callback(func_dump());
FIN

url = ARGV[0]

driver.navigate.to url
driver.manage.window.resize_to(970,728)

driver.execute_async_script(load_dump)
puts "BOM v" + driver.execute_script("return bomversion;")
puts "rURL: " + real_url = driver.execute_script("return document.URL;")
driver.save_screenshot("gtimg/#{real_url.hash}.png")

src = driver.execute_script("startSegmentation(undefined,0.5,50);return record;")
puts src
driver.navigate.to "http://www-poleia.lip6.fr/~sanojaa/BOM/add.php"
driver.find_element(:id,'record').send_keys src

driver.find_element(:tag_name, "input").click

sleep 10
driver.close

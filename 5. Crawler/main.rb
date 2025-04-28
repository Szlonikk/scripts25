require 'nokogiri'
require 'open-uri'


maxDepth = 50

puts "Provide keyword to scrape Empik.com for:"

keyword = gets

doc = Nokogiri::HTML(URI.open("https://www.empik.com/szukaj/produkt?q=#{keyword}&qtype=basicForm"))

items = doc.css('.search-list-item')

itemNames = [];
itemPrices = [];
itemsBrands = [];
itemLinks = [];

puts items.length 

maxDepth = [maxDepth, items.length].min

puts "Scrapping: (#{maxDepth} items)"

for i in 0..(maxDepth-1) do

    item = items[i]

    itemNames[i] = item.attr('data-product-name');
    itemPrices[i] = item.attr('data-product-price');
    itemLinks[i] = "https://www.empik.com#{item.css('.seoImage').attr('href')}";
    itemsBrands[i] = item.css('.smartAuthor').text.strip;

end

puts "Items list:"

for i in 0..(maxDepth-1) do
    puts "================================"
    puts "Name: #{itemNames[i]}"
    puts "Price: #{itemPrices[i]}"
    puts "Brand: #{itemsBrands[i]}"
    puts "Link: #{itemLinks[i]}"
    #puts "Seller: #{itemSellers[i]}"
end
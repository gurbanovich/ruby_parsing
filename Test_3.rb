#!/usr/bin/env ruby
class Test_3

  require 'nokogiri'
  require 'csv'
  require 'curb'

  def self.pars(uri)
    product = []
    curb2=Curl.post(uri.to_s)
    doc = Nokogiri::HTML(curb2.body_str)
    name =  doc.xpath('*//h1[@itemprop="name"]/text()').text.strip
    picture = doc.xpath('*//img[@id="bigpic"]/@src').text.strip
    doc.xpath('*//ul[@class="attribute_labels_lists"]').each do |row|
      attribute =  row.xpath('*/span[@class = "attribute_name"]').text.strip
      price =  row.xpath('*/span[@class = "attribute_price"]').text.strip
      product.push(
      name+" "+attribute,
      price,
      picture,
      nil
      )
    end
    return product
  end


  CSV.open(ARGV[3].to_s, "w") do |wr| #products.csv
  start_uri=ARGV[1] #http://www.petsonic.com/es/perros/snacks-y-huesos-perro/galletas-granja-para-perro/

    until start_uri=='https://www.petsonic.com'
      curb=Curl.post(start_uri.to_s)
      page=Nokogiri::HTML(curb.body_str)
      page.xpath('//a[@class = "product-name"]/@href').each do |links|
         pars(links).each{|x| wr << ["#{x}"]}
      end

      next_uri=page.xpath('//li[@class = "pagination_next"]//a/@href')
      start_uri='https://www.petsonic.com'+ next_uri.to_s
    end
  end
end 

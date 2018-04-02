#!/usr/bin/env ruby
class PetsonicPars

  require 'nokogiri'
  require 'csv'
  require 'curb'
  require 'regex'


def initialize(arg0, arg1, arg2, arg3)
  if (/https/.match arg1)&&(/.csv/.match arg3)
    @uri=arg1
    @file = arg3
  elsif (/https/.match arg3)&&(/.csv/.match arg1)
    @uri=arg3
    @file = arg1
  else 
    puts "please enter the argument in the form: -url url_value -file file_name"
  end
end 

  def pag
    threads = []
    start_uri = @uri
    CSV.open(@file, "w") do |wr|
      mainT=Thread.new do
        puts "main thread start"
        until start_uri=='https://www.petsonic.com'
          puts start_uri
          curb=Curl.post(start_uri.to_s)
          page=Nokogiri::HTML(curb.body_str)
          page.xpath('//a[@class = "product-name"]/@href').each do |links|
            threads << Thread.new(links) do |l|
              puts l, " start" 
              Thread.current["mc"]=l 
              pars(l).each {|x| wr << x.values}      
             end
          end
          next_uri=  page.xpath('//li[@class = "pagination_next"]//a/@href')
          start_uri='https://www.petsonic.com'+ next_uri.to_s
        end
        threads.each {|t| t.join; puts t["mc"], " is finished"}
    end
    mainT.join
    puts "main thread is finished"
   end
  end

  private
  def pars(uri)
    product = []
    thr = []
    curb2=Curl.post(uri.to_s)
    doc = Nokogiri::HTML(curb2.body_str)
    name =  doc.xpath('*//h1[@itemprop="name"]/text()').text.strip
    picture = doc.xpath('*//img[@id="bigpic"]/@src').text.strip
    doc.xpath('*//ul[@class="attribute_labels_lists"]').each do |row|
      thr << Thread.new(name, picture) do |n, p|
        puts n +" start"
        Thread.current["mp"]=n
        attribute =  row.xpath('*/span[@class = "attribute_name"]').text.strip
        price =  row.xpath('*/span[@class = "attribute_price"]').text.strip
        product.push(
           Name: n+" "+attribute,
           Price: price.to_s,
           Picture: p
        )
        end
      end
      thr.each {|t| t.join; puts t["mp"] +" is finished"}
    return product
  end

end




 begin
   t=PetsonicPars.new(*ARGV)
   rescue ArgumentError
   puts "Argument error: please enter the argument in the form: -url url_value -file file_name"
 end

 if (/www.petsonic.com/.match ARGV[1])||(/www.petsonic.com/.match ARGV[3])
  begin
    t.pag
  rescue TypeError, NoMethodError
    puts "Push one more time with corrections"
  end
 else
  puts "enter correct url of petsonic.com" 
 end

    
  






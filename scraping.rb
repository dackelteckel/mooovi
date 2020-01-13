require 'mechanize'

agent = Mechanize.new
page = agent.get("https://app-mooovi.herokuapp.com/works/third_scraping")
elements = page.search('.etc div')

elements.each do |emt|
  puts emt.inner_text
end
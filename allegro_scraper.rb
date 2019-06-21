require 'net/http'
require 'nokogiri'
require 'csv'


class AllegroScraper
  attr_accessor :uri, :csv_file, :pages

  def initialize(uri, pages = 1)
    @uri = uri
    @pages = pages
  end

  def open_csv_file(file_name = "data.csv")
    @csv_file = CSV.open(file_name, "w", col_sep: "|", )
    @csv_file << ["Rok produkcji:","Przebieg:","Pojemność silnika:"]
  end

  # dla kazdej podkategorii tworzy plik i skrapuje jej dane
  def get_data_from_all_subcategories
    doc = get_document(@uri)
    doc.css('span._66f9580').search('a').each do |subcat|
      open_csv_file(subcat.text + ".csv")
      get_data("https://allegro.pl" + subcat['href'])
    end
  end

  # przyjmuje link do listy ofert oraz ile stron ma zeskrapować
  def get_data(uri=@uri)
    #otwiera plik jezeli był on zamkniety lub nie ma go
    open_csv_file if @csv_file == nil || @csv_file.closed?
    (1..@pages).each do |page|
      puts uri
      doc = get_document(uri, page)
      doc.css('div.opbox-listing--base').search('h2.ebc9be2').each do |link|
        get_auction_data(link.children[0]['href'])
      end
      # sprawdza czy nie przekroczyło ilosci stron w kategorii
      break if doc.at('span.m-pagination__text').text.to_i == page
    end
    @csv_file.close
  end

  # przyjmuje link i zwraca html
  # jezeli to jest lista ofert to mozna podac argument page który spowoduje zwrócenie konkretnej strony
  def get_document(uri, page = 1)
    uri = URI(uri)
    uri.query = URI.encode_www_form({:p => page}) if page != 1
    Nokogiri::HTML(Net::HTTP.get(uri))
  end

  # dopisuje do pliku csv parametry znalezione w ofercie do której odnosi się uri
  def get_auction_data(uri)
    doc = get_document(uri)
    row = Array.new
    doc.css('div[data-box-name="Parameters"]').css('div._18da3096').each do |param|
      if ["Rok produkcji:","Przebieg:","Pojemność silnika:"].include? param.children[0].text
        row << param.children[1].text
      end
    end
    @csv_file << row
  end

end

allegro_scraper = AllegroScraper.new('https://allegro.pl/kategoria/samochody-osobowe-4029?bmatch=baseline-n-dict4-sauron-bp-adv-1-3-0618')
allegro_scraper.pages = 2
# allegro_scraper.get_data_from_all_subcategories()
# allegro_scraper.get_data('https://allegro.pl/kategoria/osobowe-acura-57967?bmatch=baseline-n-dict4-sauron-bp-adv-1-3-0618')
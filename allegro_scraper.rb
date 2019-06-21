require 'net/http'
require 'nokogiri'
require 'csv'


class AllegroScraper
  attr_accessor :uri, :csv_file, :pages

  def initialize(uri, pages = 1)
    @uri = uri
    @pages = pages
  end

  # tworzy plik csv dla kategorii auta
  def open_csv_file(file_name = "data.csv")
    @csv_file = CSV.open("./data/" + file_name, "w", col_sep: "|", )
    @csv_file << ["Rok produkcji:","Przebieg:","Pojemność silnika:"]
  end

  # dla kazdej podkategori tworzy plik i skrapuje jej dane
  def get_all_subcats_from_uri(uri = @uri)
    get_all_subcats_from_html(get_document(uri))
  end

  #szuka wszystkich podkategorii w documencie i je skrapuje
  def get_all_subcats_from_html(doc)
    doc.css('span._66f9580').search('a').each do |subcat|
      open_csv_file(subcat.text + ".csv")
      get_category_data_from_uri("https://allegro.pl" + subcat['href'])
    end
  end

  # wywoluje skarapownie danych dla kazdej strony kategori
  def get_category_data_from_uri(uri=@uri)
    (1..@pages).each do |page|
      doc = get_document(uri, page)
      get_category_data_from_html(doc)
      # sprawdza czy nie przekroczyło ilosci stron w kategori
      break if doc.at('span.m-pagination__text').text.to_i == page
    end
  end

  # wywoluje skrapowanie danych na ofertach w dokumencie i zapisuje do pliku
  def get_category_data_from_html(doc)
    # otwiera plik jezeli był on zamkniety lub nie ma go
    open_csv_file if @csv_file == nil || @csv_file.closed?
    doc.css('div.opbox-listing--base').search('h2.ebc9be2').each do |link|
      @csv_file << get_auction_data_from_uri(link.children[0]['href'])
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

  # wywołuje skrapowanie oferty z uri
  def get_auction_data_from_uri(uri)
    get_auction_data_from_html(get_document(uri))
  end

  # szuka parametrów w dokumencie oferty
  def get_auction_data_from_html(doc)
    row = Array.new
    doc.css('div[data-box-name="Parameters"]').css('div._18da3096').each do |param|
      if ["Rok produkcji:","Przebieg:","Pojemność silnika:"].include? param.children[0].text
        row << param.children[1].text
      end
    end
    row
  end

end

allegro_scraper = AllegroScraper.new('https://allegro.pl/kategoria/samochody-osobowe-4029?bmatch=baseline-n-dict4-sauron-bp-adv-1-3-0618')
# allegro_scraper.pages = 2
# allegro_scraper.get_all_subcats_from_uri("https://allegro.pl/kategoria/osobowe-acura-57967?bmatch=baseline-n-dict4-sauron-bp-adv-1-3-0618")
allegro_scraper.get_category_data_from_uri('https://allegro.pl/kategoria/osobowe-acura-57967?bmatch=baseline-n-dict4-sauron-bp-adv-1-3-0618')
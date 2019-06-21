require_relative 'allegro_scraper'
require 'test/unit'
require 'nokogiri'


class TestAllegroScraper < Test::Unit::TestCase

  def self.startup

  end

  def setup
    @doc = Nokogiri::HTML(open("./test_template.html"))
    @numer_of_subcats = 4
    @allegro_scraper = AllegroScraper.new("")
  end

  def teardown
    for f in Dir["./data/*.csv"]
      File.delete(f)
    end
  end

  def test_get_data_from_all_subcategories
    @allegro_scraper.get_all_subcats_from_html(@doc)
    assert_equal(@numer_of_subcats, Dir["./data/*.csv"].size)
  end

  def test_get_data_from_category
    @allegro_scraper.get_category_data_from_html(@doc)
    assert_not_equal(nil, File::size?(@allegro_scraper.csv_file.path))

  end

  def test_get_auction_data
    @allegro_scraper.open_csv_file
    assert_equal(3, @allegro_scraper.get_auction_data_from_html(@doc).length)
  end

  def test_get_document
    assert_instance_of(Nokogiri::HTML::Document, @allegro_scraper.get_document("https://www.google.com/"))
  end

  def test_open_csv_file
    @allegro_scraper.open_csv_file
    assert_equal(false, @allegro_scraper.csv_file.closed?)
  end
end
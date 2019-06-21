require_relative 'allegro_scraper'
require 'test/unit'
require 'nokogiri'


class TestAllegroScraper < Test::Unit::TestCase

  def startup

  end

  def setup
    @allegro_scraper = AllegroScraper.new('https://allegro.pl/kategoria/osobowe-alfa-romeo-4030?bmatch=baseline-n-dict4-sauron-bp-adv-1-3-0618')
  end

  def test_get_data_from_all_subcategories
    @allegro_scraper.get_data_from_all_subcategories

  end

  def test_get_data
    @allegro_scraper.get_data
    assert_not_equal(nil, File::size?(@allegro_scraper.csv_file.path))
  end

  # def test_get_auction_data
  #   @allegro_scraper.get_auction_data(@auction_url)
  #   assert_not_equal(nil, File::size?(@allegro_scraper.csv_file.path))
  # end
  #
  # def test_get_document
  #   assert_instance_of(Nokogiri::HTML::Document, @allegro_scraper.get_document(@allegro_scraper.uri))
  # end

  def test_open_csv_file
    @allegro_scraper.open_csv_file
    assert_equal(false, @allegro_scraper.csv_file.closed?)
  end
end
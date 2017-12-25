require "pry"

require "./lib/config_data.rb"
require "./lib/nyt_scraper.rb"
require "./lib/puzzle_manager.rb"
require "./lib/delivery_manager.rb"

def main
	scraper = NYTScraper.new(verbose: true)
	puzzle_manager = PuzzleManager.new(verbose: true)
	delivery_manager = DeliveryManager.new(test_env: false, verbose: true)

	scraper.scrape_crossword_home
	scraper.fetch_new_puzzles(puzzle_manager, sleep_time = 3.0)

	puzzle_manager.refresh_ids
	if puzzle_manager.has_new_packet?
		packet_path = puzzle_manager.save_new_packet
		puzzle_manager.send_receipt
		delivery_manager.send_letter(packet_path)
	end
end

main
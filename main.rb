require "pry"

require "./lib/config_data.rb"
require "./lib/nyt_scraper.rb"
require "./lib/puzzle_manager.rb"
require "./lib/delivery_manager.rb"

# Main method called at intervals
def main
	scraper = NYTScraper.new(verbose: true)
	puzzle_manager = PuzzleManager.new(verbose: true)
	delivery_manager = DeliveryManager.new(test_env: false, verbose: true)

	# Pulls all new crossword puzzles
	scraper.scrape_crossword_home
	scraper.fetch_new_puzzles(puzzle_manager)

	# Update puzzle manager with the IDs of the new puzzles
	puzzle_manager.refresh_ids

	if puzzle_manager.has_new_packet?
		# Generates a new packet, sends a receipt, and mails the packet
		packet_path = puzzle_manager.save_new_packet
		puzzle_manager.send_receipt
		delivery_manager.send_letter(packet_path)
	end
end

main # Good luck!
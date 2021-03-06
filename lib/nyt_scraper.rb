require "open-uri"
require "nokogiri"
require "rest_client"

# Class for finding puzzle IDs on the NYTimes Crossword home page
# and for retrieving PDFs of crossword puzzles
class NYTScraper

	def initialize(verbose = false)
		@verbose = verbose
	end

	# Scrapes the Crossword Homepage, pulls IDs of puzzles linked from the page
	def scrape_crossword_home
		url = "https://www.nytimes.com/crosswords"
		response = RestClient.get(url, headers = self.get_headers)

		doc = Nokogiri::HTML(response.body)
		@puzzle_ids = extract_puzzle_ids(doc)
	end

	# Fetches puzzles for all puzzles discover which AREN'T
	# already recognized by the puzzle_manager
	# Wait `sleep_time` seconds between each fetch
	def fetch_new_puzzles(puzzle_manager, sleep_time = 5.0)
		@puzzle_ids.each do |id|
			if !puzzle_manager.has_puzzle?(id)
				puts "Fetching #{ id }" if @verbose
				sleep(sleep_time)
				puzzle_manager.save(id, fetch_puzzle(id))
			else
				puts "Skipping #{ id }" if @verbose
			end
		end
	end

	# Takes the ID of a puzzle, returns a PDF file for that puzzle
	def fetch_puzzle(id)
		url = "https://www.nytimes.com/svc/crosswords/v2/puzzle/#{ id }.pdf?block_opacity=55"
		response = RestClient.get(url, headers = self.get_headers)
		response.body
	end

	# Given a Nokogiri object, find all links to puzzles
	# and extract the puzzle ID from them
	def extract_puzzle_ids(doc)
		hrefs = doc.css("a").map do |link|
			link.attribute("href").value
		end

		puzzle_hrefs = hrefs.select do |href|
			href.end_with?(".puz")
		end

		ids = puzzle_hrefs.map do |href|
			href.split("/").last.split(".").first
		end

		return ids.uniq
	end

	# Generates request header, the most important part being the cookie
	def get_headers
		cookie = ConfigData.get(:nytimes, :cookie)

		return {
			"authority" => "www.nytimes.com",
			"accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
			"accept-encoding" => "gzip, deflate, br",
			"accept-language" => "en-US,en;q=0.9",
			"cache-control" => "max-age=0",
			"cookie" => cookie,
			"if-none-match" => 'W/"4fef7-vHgtjdQ3Rb/QZiWFN5GUOhVw7z4"',
			"referer" => "https://www.google.com/",
			"upgrade-insecure-requests" => "1",
			"user-agent" => USER_AGENT
		}
	end

	USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36"
end
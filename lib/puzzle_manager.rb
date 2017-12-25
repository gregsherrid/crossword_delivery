require "set"
require "combine_pdf"

# Class for managing puzzle previously found
# and saving and generating puzzles and packets
class PuzzleManager

	def initialize(verbose: false)
		@verbose = verbose
		self.refresh_ids
	end

	# Looks in the ./puzzles and ./puzzles/packets directory to
	# find IDs of previous puzzles and packets
	def refresh_ids
		# Find all puzzle IDs retrieved
		puzzle_files = Dir["./puzzles/*.pdf"]
		ids = puzzle_files.map do |path|
			path.split("/puzzle-").last.split(".").first
		end
		@puzzle_ids = Set.new(ids)

		# Find all puzzle IDs mailed in packets
		puzzle_packet_files = Dir["./puzzles/packets/*.pdf"]
		id_groups = puzzle_packet_files.map do |path|
			path.split("/").last.split(".").first.split("-")
		end
		@puzzle_packet_ids = Set.new(id_groups.flatten)
	end

	def puzzle_ids
		@puzzle_ids
	end

	def has_puzzle?(id)
		@puzzle_ids.include?(id)
	end

	# Save the puzzle with the given ID
	def save(id, file_data)
		puzzle_path = "./puzzles/puzzle-#{ id }.pdf"
		open(puzzle_path, "wb") do |file|
			file << file_data
		end
	end

	# Gets all puzzles saved which have never been sent in a packet
	def new_puzzle_ids
		@puzzle_ids - @puzzle_packet_ids
	end

	# Checks if there are enough new puzzles to send a packet
	def has_new_packet?
		return self.new_puzzle_ids.length >= ConfigData.get(:custom, :min_puzzles_per_packet)
	end

	# Combine all new puzzles into a packet PDF
	def save_new_packet
		new_ids = self.new_puzzle_ids.sort
		packet_path = "./puzzles/packets/#{ new_ids.join('-') }.pdf"

		pdf = CombinePDF.new
		new_ids.each do |puzzle_id|
			pdf << CombinePDF.load("./puzzles/puzzle-#{ puzzle_id }.pdf")
		end
		pdf.save packet_path
		packet_path
	end

	# Sends a confirmation email that a packet is about to be sent
	def send_receipt
		if ConfigData.get(:receipts, :active).to_s == "true"
			puts "Sending receipt" if @verbose
			api_key = ConfigData.get(:receipts, :mailgun_private_api_key)
			domain = ConfigData.get(:receipts, :mailgun_domain)

			url = "https://api:#{ api_key }@api.mailgun.net/v3/#{ domain }/messages"
			new_ids = self.new_puzzle_ids.sort
			message = "Delivered #{ new_ids.length } "
			if new_ids.length == 1
				message << "puzzle "
			else
				message << "puzzles "
			end
			message << "with IDs: #{ new_ids.join(", ") }."

			RestClient.post(url,
				from: "Crossword Delivery <crossword_receipts@#{ domain }>",
				to: ConfigData.get(:receipts, :email),
				subject: "Crossword Delivery Scheduled!",
				text: message)
		end

	end

end
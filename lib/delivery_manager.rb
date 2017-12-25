require "lob"

class DeliveryManager

	def initialize(test_env: false, verbose: false)
		@verbose = verbose

		if test_env
			@lob = Lob::Client.new(api_key: ConfigData.get(:lob, :test_api_key))
		else
			@lob = Lob::Client.new(api_key: ConfigData.get(:lob, :live_api_key))
		end

	end

	def send_letter(pdf_path)
		puts "Mailing: #{ pdf_path }" if @verbose
		@lob.letters.create(
			description: "Crossword Packet",
			to: self.get_address(:to_address),
			from: self.get_address(:from_address),
			file: File.new(pdf_path),
			color: false,
			double_sided: true,
			address_placement: :insert_blank_page
		)
	end

	def get_address(address_type)
		return {
			name: 			ConfigData.get(address_type, :name),
			address_line1: 	ConfigData.get(address_type, :line_1),
			address_line2: 	ConfigData.get(address_type, :line_2),
			address_city: 	ConfigData.get(address_type, :city),
			address_state: 	ConfigData.get(address_type, :state),
			address_zip: 	ConfigData.get(address_type, :zip)
		}
	end
end
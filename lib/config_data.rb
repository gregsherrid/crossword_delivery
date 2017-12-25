require "yaml"

class ConfigData
	def self.get(space, key)
		value = ConfigData::DATA["config"][space.to_s].to_h[key.to_s]
		if value.nil?
			raise "No value: #{ space }, #{ key }"
		end
		value
	end

	DATA = YAML.load_file("./config/private-config.yml")
end
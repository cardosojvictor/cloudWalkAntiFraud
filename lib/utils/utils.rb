require 'date'
require 'time'

module Utils
    def self.format_date(date_string)
      parsed_datetime = DateTime.parse(date_string)
      parsed_datetime.strftime("%Y-%m-%d %H:%M:%S")
    end

    def self.remove_offset(time_string)

        puts " %%%%%%%%%%%%%%%%%%%%%%%% Entrou AQUIIIIIIIIIIIIIIIIIIIII"

        parsed_time = DateTime.strptime(time_string, "%Y-%m-%d %H:%M:%S %z")
        puts "parsed_time: #{parsed_time}"
        result = parsed_time.strftime("%Y-%m-%d %H:%M:%S")
        puts "result #{result}"
    end

end
  
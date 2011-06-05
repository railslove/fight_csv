require 'csv'
module FightCSV
	OptionsMapping = { seperator: :col_sep, dataset_seperator: :row_sep }

  module Parser
    def self.from_files(files, options = {})
      files.inject([]) do |data,file|
        csv = CSV.read(file, convert_options(options))
				data << {data_source: DataSource.new(header: csv.shift, filename: file), body: csv}
      end
    end

    def self.from_string(string, options = {})
			csv = CSV.parse(string, convert_options(options))
      [{data_source: DataSource.new(header: csv.shift), body: csv}]
    end

		def self.convert_options(options)
			Hash[options.map { |key,val| [OptionsMapping[key],val] }]
		end
		private_class_method :convert_options

  end
end

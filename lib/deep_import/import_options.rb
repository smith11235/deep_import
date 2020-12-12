module DeepImport

  def self.raise_error?
    @@raise_error
  end

  private

  @@import_options = nil
  @@raise_error = nil

  def self.import_options=( options = {})
    @@import_options = ImportOptions.new(options).to_hash
    @@raise_error = @@import_options[:on_save] == :raise_error 
  end

  class ImportOptions
    def initialize(options)
      @options = options || {}
      add_defaults
      validate!
    end

    def to_hash
      return @options
    end

    private

    def valid_key_values
      {
        :on_save => [ :raise_error, :noop ]
      }
    end

    def default_values
      defaults = Hash.new
      valid_key_values.each { |option,values| defaults[ option ] = values.first }
      return defaults
    end

    def add_defaults
      @options.reverse_merge! default_values
    end

    def validate!
      valid_values = valid_key_values
      @options.each do |option,value|
        raise "Unknown Import Option: #{option}" unless valid_values.keys.include? option
        raise "Unknown #{option} => #{value}, expecting #{valid_values[option]}" unless valid_values[ option ].include? value
      end
    end
  end
end

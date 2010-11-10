module HTTPI
  class DimeRecord < Struct.new('DimeRecord', :version, :first, :last, :chunked, :type_format, :options, :id, :type, :data)
  end

  class Dime < Array
    BINARY = 1
    XML = 2

    def initialize(body)
      bytes = body.unpack('C*')

      while bytes.length > 0
        record = DimeRecord.new

        # Shift out bitfields for the first fields
        byte = bytes.shift
        record.version     = (byte >> 3) & 31         # 5 bits  DIME format version (always 1)
        record.first       = (byte >> 2) & 1          # 1 bit   Set if this is the first part in the message
        record.last        = (byte >> 1) & 1          # 1 bit   Set if this is the last part in the message
        record.chunked     = byte & 1                 # 1 bit   This file is broken into chunked parts
        record.type_format = (bytes.shift >> 4) & 15  # 4 bits  Type of file in the part (1 for binary data, 2 for XML)
                                                      # 4 bits  Reserved (skipped in the above command)

        # Fetch big-endian lengths
        lengths = [] # we can't use a hash since the order will be screwed in Ruby 1.8
        lengths << [:options, (bytes.shift << 8) | bytes.shift]                                             # 2 bytes   Length of the "options" field
        lengths << [:id,      (bytes.shift << 8) | bytes.shift]                                             # 2 bytes   Length of the "ID" or "name" field
        lengths << [:type,    (bytes.shift << 8) | bytes.shift]                                             # 2 bytes   Length of the "type" field
        lengths << [:data,    (bytes.shift << 24) | (bytes.shift << 16) | (bytes.shift << 8) | bytes.shift] # 4 bytes   Size of the included file

        # Read in padded data
        lengths.each do |attribute_set|
          attribute, length = attribute_set
          content = bytes.slice!(0, length).pack('C*')
          if attribute == :data && record.type_format == BINARY
            content = StringIO.new(content)
          end

          record.send "#{attribute.to_s}=", content

          bytes.slice!(0, 4 - (length & 3)) if (length & 3) != 0
        end

        self << record
      end
    end

    def xml_records
      select { |r| r.type_format == XML }
    end

    def binary_records
      select { |r| r.type_format == BINARY }
    end
  end
end

module Griddler
  module Sendgrid
    class Adapter
      def initialize(params)
        @params = params
        encode_params
      end

      def self.normalize_params(params)
        adapter = new(params)
        adapter.normalize_params
      end

      def normalize_params
        params.merge(
          to: recipients(:to),
          cc: recipients(:cc),
          attachments: attachment_files,
        )
      end

      private

      attr_reader :params, :charsets

      def recipients(key)
        ( params[key] || '' ).split(',')
      end

      def attachment_files
        params.delete('attachment-info')
        attachment_count = params[:attachments].to_i

        attachment_count.times.map do |index|
          params.delete("attachment#{index + 1}".to_sym)
        end
      end

      def encode_params
        begin
          @charsets = JSON.parse(params['charsets'])
        rescue
          @charsets = {}
        end
        params = encode_field('text')
        params = encode_field('html')
        params
      end

      def encode_field(name)
        if params[name]
          if charsets[name]
            params[name] = params[name].force_encoding(charsets[name]).encode('UTF-8')
          else
            params[name] = params[name].encode('UTF-8')
          end
        end
        params
      end
    end
  end
end

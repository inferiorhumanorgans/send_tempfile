# This file is part of send_tempfile.
# 
# send_tempfile is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# send_tempfile is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with send_tempfile.  If not, see <http://www.gnu.org/licenses/>.

module SendTempfile

  module RenderHelper
    class StreamingFileBody
      def initialize(path)
        @file = File.open(path, 'rb')
      end

      # Stream the file's contents even if Rack::Sendfile is present.
      def each
        begin
          while chunk = @file.read(16384)
            yield chunk
          end
        ensure
          @file.close
        end
      end
    end

    def send_tempfile(options={}, &block)
      begin
        tmp_options = {}
        tmp_options[:encoding] = options.delete(:tmp_encoding) if options[:tmp_encoding].present?
        tmp = Tempfile.open(Rails.application.class.parent_name, tmp_options)

        block.call(tmp)

        raise MissingFile, "Cannot read file #{tmp.path}" unless File.file?(tmp.path) and File.readable?(tmp.path)

        options[:filename] ||= File.basename(tmp.path) unless options[:url_based_filename]
        send_file_headers! options

        self.status = options[:status] || 200
        self.content_type = options[:content_type] if options.key?(:content_type)
        self.response_body = StreamingFileBody.new(tmp.path)
      ensure
        tmp.close!
      end
    end
  end

  class SendTempfileRailtie < Rails::Railtie
    initializer "send_tempfile.register" do |app|
      ActionController::Base.send :include, RenderHelper
    end
  end
end

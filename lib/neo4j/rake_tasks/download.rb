require 'ruby-progressbar'
require 'net/http'

module Neo4j
  module RakeTasks
    class Download
      def initialize(url)
        @url = url
      end

      def exists?
        status = head(@url).code.to_i
        (200...300).cover?(status)
      end

      def fetch(message)
        require 'open-uri'
        open(@url,
             content_length_proc: lambda do |total|
               create_progress_bar(message, total) if total && total > 0
             end,
             progress_proc: lambda do |s|
               @progress_bar.progress = s if @progress_bar
             end).read
      end

      private

      def create_progress_bar(message, total)
        @progress_bar ||= ProgressBar.create title: message,
                                             total: total
      end

      def head(url)
        parsed_url = URI(url)
        Net::HTTP.start(parsed_url.host, parsed_url.port) do |http|
          return http.head(parsed_url.path)
        end
      end
    end
  end
end

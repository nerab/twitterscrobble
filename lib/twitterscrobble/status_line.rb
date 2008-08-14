require 'shorturl'

module Twitterscrobble
  class StatusLine
      TWITTER_MAX_MSG_LEN = 140
  
      def initialize(track)
          @track = track
      end
  
      # TODO
      # The algorithm to use the maximum number of characters is not the best yet.
      # We should also try to cut down single fields that are overly long in favor of
      # not loosing another short field.
      #
      # Example:
      #
      #   track.name = "A"
      #   track.artist = "Very long artist name that is close to the maximum length of the whole line"
      #
      # The algorithm below would just return "A", but a better version would return "Very long ... - A".
      #
      #
      def to_s
          status = with_name
  
          if with_artist.length <= TWITTER_MAX_MSG_LEN
              status = with_artist
          end
  
          if with_album.length <= TWITTER_MAX_MSG_LEN
              status = with_album
          end
  
           if with_url.length <= TWITTER_MAX_MSG_LEN
               status = with_url
           end
  
  #        if status.length > TWITTER_MAX_MSG_LEN # still too long, enforce length restriction
  #            status = "#{status[1, 137]}..."
  #        end
  
          status
      end
  
  private
      def with_name
          "Now playing: #{CGI::escapeHTML(@track.name)}"
      end
  
      def with_artist
          if @track.artist.blank?
              with_name
          else
              "Now playing: #{CGI::escapeHTML(@track.artist)} - #{CGI::escapeHTML(@track.name)}"
          end
      end
  
      def with_album
          if @track.album.blank?
              with_artist
          else
              "#{with_artist} (from #{CGI::escapeHTML(@track.album)})"
          end
      end
  
      def with_url
          if @track.url.blank?
              with_album
          else
              "#{with_album} #{ShortURL.shorten(@track.url)}"
          end
      end
  end
end
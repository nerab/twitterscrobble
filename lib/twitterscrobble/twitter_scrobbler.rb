require 'scrobbler'
require 'twitter'

module Twitterscrobble
  #
  # Read the latest tracks of a user from last.fm and post them to Twitter.
  #
  class TwitterScrobbler
  
      def initialize(prefs)
          @prefs = prefs
          @logger = @prefs.logger
      end
  
      def update
          @logger.info("Reading recent tracks for #{@prefs.scrobbler_user}")
  
          # Order by date_uts so that we can rely on tracks being steady
          tracks = Scrobbler::User.new(@prefs.scrobbler_user).recent_tracks.sort{|x,y| x.date_uts <=> y.date_uts }
  
          if !@prefs.max.blank? && 0 < @prefs.max
              @logger.info("Limiting number of posted songs to #{@prefs.max}")
              tracks = tracks[@prefs.max * -1, @prefs.max]
          end
  
          # Filter already posted tracks
          tracks.reject!{|track|
              if track.date_uts.to_i <= @prefs.history.to_i
                  @logger.info("Skipping #{track.artist} - #{track.name} because #{track.date_uts.to_i} <= #{@prefs.history.to_i}")
                  true
              end
          }
  
          @logger.info("No new tracks since #{Time.at(@prefs.history.to_i).to_s}") if 0 == tracks.size
  
          tracks.each{|track|
              status = StatusLine.new(track)
  
              begin
                  if @prefs.no_post
                      puts status
                  else
                      @logger.info("Posting new status: '#{status}'")
                      Twitter::Base.new(@prefs.twitter_user, @prefs.twitter_password).update(status)
                  end
  
                  @prefs.history = track.date_uts.to_i
               rescue
                  @logger.error("Error: #{$!}")
              end
          }
      end
  end
end
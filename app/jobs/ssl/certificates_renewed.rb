module Jobs
  module Ssl
    class CertificatesRenewed < Jobs::BackgroundJob::Job
      def self.run
        log = "#{Rails.root}/log/ssl.cron.log"
        output = `touch #{log} && cat #{log}`
        unless $?.success? and output =~ /SUCCESS/
            @errors << "Ssl Renew Certificate Failed: #{output}"
        end
        `rm -f ${log}`
      end
    end
  end
end
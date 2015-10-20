require 'rb-inotify'
require 'logger'

$logger = Logger.new('/logs/repo-scanner/scanner.log', 'daily')
$logger.level = Logger::INFO

$top_dir = "/repo"

def scanAndUpdate()

        # get repo dir list, clean and dedup
        repo_dirs = Dir["#$top_dir/**/*.rpm"]
        repo_dirs.map! { |item| item = File.dirname item }
        repo_dirs.uniq!

        for dir in repo_dirs
                $logger.info("scanning repo #{dir}")
                system "createrepo --update #{dir}"
                if $?.exitstatus != 0
                        $logger.error("Could not update repo #{dir}")
                end
        end
end

notifier = INotify::Notifier.new
notifier.watch($top_dir, :recursive, :close, :move, :delete) do |event|
        if event.name.match(/^.*\.rpm$/)
                $logger.info("rpm change detected ... running repo scan")
                scanAndUpdate()
        end
end

notifier.run
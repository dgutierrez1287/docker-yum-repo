require 'rb-inotify'
require 'logger'
require 'time'

$logger = Logger.new('/logs/repo-scanner/scanner.log', 'daily')
$logger.level = Logger::INFO

$top_dir = "/repo"
WAIT_SECONDS = 3
$last_update = Time.at(0)
$scan_dirs = Hash.new
$scan_dirs_lock = Mutex.new

# Start a background thread to scan the repo(s) only once every 3 seconds
Thread.new do
    while true do
        sleep 1
        $scan_dirs_lock.synchronize do
            if ($last_update + WAIT_SECONDS) > Time.now
                # wait at least WAIT_SECONDS since last notification
                $logger.info("Waiting before we regenearate the repo...")
                next
            end
            $scan_dirs.keys.each do |dir|
                $logger.info("scanning repo #{dir}")
                system "createrepo --update #{dir}"
                if $?.exitstatus != 0
                    $logger.error("Could not update repo #{dir}")
                end
                $scan_dirs.delete(dir)
                $logger.info("scan complete for #{dir}")
            end
        end
    end
end


def scanAndUpdate()
    # get repo dir list, clean and dedup
    repo_dirs = Dir["#$top_dir/**/*.rpm"]
    repo_dirs.map! { |item| item = File.dirname item }
    repo_dirs.uniq!

    $scan_dirs_lock.synchronize do
        repo_dirs.each do |dir|
            $last_update = Time.now
            $scan_dirs[dir] = true
        end
    end
end

notifier = INotify::Notifier.new
notifier.watch($top_dir, :recursive, :attrib, :move, :create, :delete) do |event|
    if event.absolute_name.match(/^.*\.rpm$/)
        $logger.info("rpm change detected ... running repo scan")
        scanAndUpdate()
    end
end

notifier.run

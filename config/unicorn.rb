# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/home/dota2responsesbot/dota2responsesbot/current"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/home/dota2responsesbot/dota2responsesbot/shared/tmp/pids/unicorn.pid"

# Path to logs
# stderr_path "/path/to/log/unicorn.log"
# stdout_path "/path/to/log/unicorn.log"
stderr_path "/home/dota2responsesbot/dota2responsesbot/current/log/unicorn.stderr.log"
stdout_path "/home/dota2responsesbot/dota2responsesbot/current/log/unicorn.stdout.log"

# Unicorn socket
listen "/tmp/unicorn.dota2responsesbot.sock"

# Number of processes
# worker_processes 4
worker_processes 3

# Time-out
timeout 30

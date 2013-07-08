Puppet::Util::Log.newdesttype :array_hash do
  def initialize
    @all_logs = []
    @warn_logs = []
  end

  def handle(msg)
    @all_logs << { :level => msg.level, :message => msg.message}
    @warn_logs << msg.message if msg.level == :warning
  end

  def logs
    @all_logs
  end

  def warnings
    @warn_logs
  end
end

# Monkeypatch - prevent Puppetlint from outputting messages to stdout
class PuppetLint
  def format_message(message)
  end
end

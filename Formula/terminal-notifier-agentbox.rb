class TerminalNotifierAgentbox < Formula
  desc "Send macOS notifications with the agentbox logo as their icon"
  homepage "https://github.com/julienXX/terminal-notifier"
  url "https://github.com/julienXX/terminal-notifier/archive/refs/tags/3.1.0.tar.gz"
  sha256 "7dac44a563f00c10d49aa2da4cde9d1fecdb12b36ed57fe7fdff789c3578421e"
  license "MIT"

  depends_on :macos

  # Both install bin/terminal-notifier: callers find it by name
  conflicts_with "terminal-notifier", because: "both install `terminal-notifier`"

  # A notification's icon comes from the sending app's bundle, so the logo
  # means a copy of the app with its own icon and bundle identifier.
  # Rendered at 1024px from agentbox's docs/brand/icon.svg, a private repo:
  #   rsvg-convert -w 1024 -h 1024 docs/brand/icon.svg -o terminal-notifier-agentbox.png
  ICON = File.expand_path("../assets/terminal-notifier-agentbox.png", __dir__).freeze

  def install
    system "make", "icon", "ICON=#{ICON}", "APP_NAME=agentbox"
    prefix.install "build/agentbox.app"
    # A wrapper, not a symlink: run through a symlink, the binary loses its bundle
    bin.write_exec_script prefix/"agentbox.app/Contents/MacOS/terminal-notifier"
  end

  def caveats
    <<~EOS
      macOS asks for notification permission the first time it posts:
      it's a separate app from terminal-notifier (System Settings → Notifications → agentbox).
    EOS
  end

  # The binary is killed in brew's test sandbox, so this checks the bundle
  test do
    app = prefix/"agentbox.app/Contents"
    assert_path_exists app/"Resources/icon.icns"
    assert_match "terminal-notifier.agentbox",
                 shell_output("/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' #{app}/Info.plist")
  end
end

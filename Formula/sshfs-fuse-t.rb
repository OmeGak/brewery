class SshfsFuseT < Formula
  desc "SSHFS built against the installed FUSE-T"
  homepage "https://github.com/macos-fuse-t/sshfs"
  # The fuse-t-sshfs cask's 1.0.2 (2023) has an older libfuse-t built in,
  # which drops newer mount options such as noappledouble
  url "https://github.com/macos-fuse-t/sshfs/archive/6f2908b8d80fed0f52a7f8bbe440b166a86c1c42.tar.gz"
  version "1.0.2-6f2908b"
  sha256 "f4690f652203c6756d4549cd27a5ece525eb849cf437a9daa91c2ccf36b9c945"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkgconf" => :build
  depends_on "gettext"
  depends_on "glib"
  depends_on :macos

  # FUSE-T is a cask, which a formula can't depend on
  FUSE_T_LIB = "/usr/local/lib/libfuse-t.dylib".freeze
  FUSE_T_INCLUDE = "/Library/Application Support/fuse-t/include/fuse".freeze

  def install
    odie "FUSE-T is missing: brew install --cask fuse-t" unless File.exist?(FUSE_T_LIB)

    # The headers' path has a space, which CPPFLAGS can't carry
    (buildpath/"fuse-t-include").install_symlink Dir["#{FUSE_T_INCLUDE}/*"]
    ENV.append "CPPFLAGS", "-I#{buildpath}/fuse-t-include"
    # Linked to FUSE-T's dylib, so its upgrades reach sshfs without a rebuild
    ENV.append "LDFLAGS", "-Wl,-rpath,#{File.dirname(FUSE_T_LIB)}"

    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", *std_configure_args
    system "make"
    bin.install "sshfs"
    man1.install "sshfs.1"
  end

  def caveats
    <<~EOS
      Uninstall the fuse-t-sshfs cask first: both install sshfs.
    EOS
  end

  test do
    assert_match "SSHFS version", shell_output("#{bin}/sshfs --version 2>&1")
  end
end

class ItarScan < Formula
  desc "ITAR content scanner for repositories"
  homepage "https://github.com/yourusername/tech-data-scan"
  version "0.1.0"
  
  if Hardware::CPU.arm?
    url "https://github.com/yourusername/tech-data-scan/releases/download/v#{version}/itar-scan-macos-arm64"
    sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" # You'll need to fill this in after creating the release
  else
    url "https://github.com/yourusername/tech-data-scan/releases/download/v#{version}/itar-scan-macos-x86_64"
    sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" # You'll need to fill this in after creating the release
  end

  def install
    bin.install "itar-scan-macos-#{Hardware::CPU.arm? ? "arm64" : "x86_64"}" => "itar-scan"
  end

  def caveats
    <<~EOS
      This binary is not signed with an Apple Developer ID.
      You may need to run the following command to allow execution:
        xattr -d com.apple.quarantine $(which itar-scan)
    EOS
  end

  test do
    system "#{bin}/itar-scan", "--version"
  end
end 
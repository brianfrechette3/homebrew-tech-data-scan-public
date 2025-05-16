# homebrew-itartools/Formula/itarscan.rb
class ItarScan < Formula
  desc     "CLI scanner that detects ITAR-controlled source with a local LLM"
  homepage "https://github.com/Fizzler-LLC/homebrew-tech-data-scan-public"
  version  "0.1.0"
  license  "MIT"                           # ← or whatever license your code uses

  # ─── Binary + LoRA (PyInstaller output) ──────────────────────────
  on_macos do
    if Hardware::CPU.arm?
      url     "https://github.com/brianfrechette3/tech-data-scan-public/releases/download/v0.1.0/itarscan-macos-arm64.tar.gz"                # e.g. https://github.com/yourorg/itar-scan/releases/download/v0.2.0/itarscan-macos-arm64.tar.gz
      sha256  "7cbe4091f1ca5f8598a58233cd19d05b00e98a42364742dc7982d618954cae70"
    else
      odie "Only Apple Silicon is supported at the moment."
    end
  end

  # ─── Resource: base Phi-3 GGUF from Hugging Face ─────────────────
  resource "phi3-base-model" do
    url     "https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf"
    sha256  "8a83c7fb9049a9b2e92266fa7ad04933bb53aa1e85136b7b30f1b8000ff2edef"
  end

  # No runtime dependencies: everything needed is baked into the PyInstaller binary.
  # If your code *imports* other shared libs at runtime, declare them here.

  def install
    # 1. Install the PyInstaller bundle (bin & libexec)
    bin.install     "bin/itar-scan"             # thin wrapper you added
    libexec.install "itar-scan"                 # the one-dir bundle
    libexec.install "libexec"                   # contains empty models/

    # 2. Stage the GGUF into that libexec/models/ directory
    (libexec/"models").mkpath
    resource("phi3-base-model").stage do
      cp Dir["Phi-3-mini-4k-instruct-q4.gguf"], libexec/"models"
    end
  end

  def caveats
    <<~EOS
      A pre-quantised Phi-3 model (© Microsoft, MIT licence) was downloaded
      under its own terms from HuggingFace.  If you need to update or
      replace it you can remove:
          #{libexec}/models/Phi-3-mini-4k-instruct-q4.gguf
      and reinstall this formula.
    EOS
  end

  test do
    # The LLM initialisation is expensive; a simple flag is enough to prove the binary works.
    assert_match "Usage:", shell_output("#{bin}/itar-scan --help")
  end
end

class Kubevela < Formula
  desc "Application Platform based on Kubernetes and Open Application Model"
  homepage "https://kubevela.io"
  url "https://github.com/kubevela/kubevela.git",
      tag:      "v1.7.0",
      revision: "8ef2513b2e98d0379066ab22e38e40871ac81bf6"
  license "Apache-2.0"
  head "https://github.com/kubevela/kubevela.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "6022f36b132bce053d3e4025ae28a7308ce98bd47c8ccea3dfbdd623f70f8c10"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "6022f36b132bce053d3e4025ae28a7308ce98bd47c8ccea3dfbdd623f70f8c10"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "6022f36b132bce053d3e4025ae28a7308ce98bd47c8ccea3dfbdd623f70f8c10"
    sha256 cellar: :any_skip_relocation, ventura:        "e0d2bdd0bbdc385dd0553055f77df81993539c4c4486a31eb01eb7328f81a61a"
    sha256 cellar: :any_skip_relocation, monterey:       "e0d2bdd0bbdc385dd0553055f77df81993539c4c4486a31eb01eb7328f81a61a"
    sha256 cellar: :any_skip_relocation, big_sur:        "e0d2bdd0bbdc385dd0553055f77df81993539c4c4486a31eb01eb7328f81a61a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "62150ba6a28a40d449b4b4fba27e06a84cd8bd436b18f66bfb4042034784f15e"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/oam-dev/kubevela/version.VelaVersion=#{version}
      -X github.com/oam-dev/kubevela/version.GitRevision=#{Utils.git_head}
    ]

    system "go", "build", *std_go_args(output: bin/"vela", ldflags: ldflags), "./references/cmd/cli"

    generate_completions_from_executable(bin/"vela", "completion", shells: [:bash, :zsh], base_name: "vela")
  end

  test do
    # Should error out as vela up need kubeconfig
    status_output = shell_output("#{bin}/vela up 2>&1", 1)
    assert_match "error: no configuration has been provided", status_output

    (testpath/"kube-config").write <<~EOS
      apiVersion: v1
      clusters:
      - cluster:
          certificate-authority-data: test
          server: http://127.0.0.1:8080
        name: test
      contexts:
      - context:
          cluster: test
          user: test
        name: test
      current-context: test
      kind: Config
      preferences: {}
      users:
      - name: test
        user:
          token: test
    EOS

    ENV["KUBECONFIG"] = testpath/"kube-config"
    version_output = shell_output("#{bin}/vela version 2>&1")
    assert_match "Version: #{version}", version_output
  end
end

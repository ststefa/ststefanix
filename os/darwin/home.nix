{ ... }:
{
  # Darwin-specific Home Manager adjustments

  home.sessionVariables = {
    # Choose java, see https://knasmueller.net/how-to-install-java-openjdk-16-on-macos-big-sur
    JAVA_HOME = "/opt/homebrew/opt/openjdk";
  };
}

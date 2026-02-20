{ ... }:
{
  # Darwin-specific Home Manager adjustments can be placed here.

  home.sessionVariables = {
    # Choose java, see https://knasmueller.net/how-to-install-java-openjdk-16-on-macos-big-sur
    JAVA_HOME = "/opt/homebrew/opt/openjdk";
  };
}

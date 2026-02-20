{ ... }:
{
  # Windows-specific Home Manager adjustments
  home.sessionVariables = {
    WSLENV = "EDITOR/u";
    EDITOR = "code -w";
  };
}

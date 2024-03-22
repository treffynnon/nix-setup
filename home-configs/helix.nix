{pkgs, ...}: {
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "base16_terminal";
      editor = {
        line-number = "relative";
        shell = ["${pkgs.fish}/bin/fish" "-c"];
      };
      editor.cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
    };
  };
}

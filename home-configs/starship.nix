{
  programs.starship = {
    enable = true;

    settings = {
      add_newline = false;
      character.symbol = "λ";
      directory.fish_style_pwd_dir_length = 1;

      # disable stuff I don't use
      conda.disabled = true;
      dotnet.disabled = true;
      golang.disabled = true;
      java.disabled = true;
      ruby.disabled = true;
      rust.disabled = true;
    };
  };
}

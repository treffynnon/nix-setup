{
  programs.starship = {
    enable = true;

    settings = {
      add_newline = false;
      character.success_symbol = "└─λ.(bold green)";
      character.error_symbol = "└─λ.(bold red)";

      # disable stuff I don't use
      conda.disabled = true;
      dotnet.disabled = true;
      golang.disabled = true;
      java.disabled = true;
      ruby.disabled = true;
    };
  };
}

self: super:

rec {
  httpie = super.httpie.overrideAttrs (
    oldAttrs: rec {
      src = builtins.fetchTarball {
        name = "httpie-master";
        url = https://github.com/jakubroztocil/httpie/archive/fc497daf7d9a7c9eec1896fad6037c6e861d38d5.tar.gz;
        sha256 = "0akamylcbvcz41fknqc1dr7shgajdvlfxznpjjcj1lzizlfh2csk";
      };
    }
  );
}

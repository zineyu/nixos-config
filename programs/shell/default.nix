# shell 与提示符：fish、bash、starship。
{ extraLibs, ... }:

{
  imports = extraLibs.scanPaths ./.;
}

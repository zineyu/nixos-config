{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pi-coding-agent
    codex
    cc-switch
  ];
}

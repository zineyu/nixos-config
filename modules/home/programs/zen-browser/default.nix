{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  zenPolicies = {
    DisableAppUpdate = true;
    DisableFeedbackCommands = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableTelemetry = true;
    DontCheckDefaultBrowser = true;
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
    OfferToSaveLogins = false;
    EnableTrackingProtection = {
      Value = true;
      Cryptomining = true;
      Fingerprinting = true;
    };
  };

  stableZenUnwrapped =
    let
      sources = builtins.fromJSON (builtins.readFile "${inputs.zen-browser}/sources.json");
      system = pkgs.stdenv.hostPlatform.system;
    in
    pkgs.callPackage "${inputs.zen-browser}/package.nix" {
      name = "stable";
      variant = sources.variants.beta.${system};
      applicationName = "Zen Browser";
      icon = "zen-browser";
      policies = zenPolicies;
    };

  defaultBrowser = "zen-stable.desktop";
  browserMimeTypes = [
    "application/json"
    "application/xhtml+xml"
    "application/x-extension-htm"
    "application/x-extension-html"
    "application/x-extension-shtml"
    "application/x-extension-xht"
    "application/x-extension-xhtml"
    "text/html"
    "text/plain"
    "x-scheme-handler/about"
    "x-scheme-handler/chrome"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/mailto"
    "x-scheme-handler/unknown"
  ];
in
{
  imports = [ inputs.zen-browser.homeModules.default ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = false;
    unwrappedPackage = stableZenUnwrapped;
    policies = zenPolicies;

    profiles."f03mub95.Default (release)" = {
      id = 0;
      name = "Default (release)";
      path = "f03mub95.Default (release)";
      isDefault = true;

      settings = {
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.tabs.loadInBackground" = false;
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.translations.automaticallyPopup" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.searches" = false;
        "dom.security.https_only_mode" = true;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "general.autoScroll" = true;
        "intl.accept_languages" = "zh-cn,zh";
        "intl.locale.requested" = "zh-CN,en-US";
        "media.autoplay.default" = 0;
        "media.peerconnection.enabled" = false;
        "media.peerconnection.ice.default_address_only" = true;
        "media.peerconnection.ice.no_host" = true;
        "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
        "network.trr.mode" = 5;
        "nimbus.rollouts.enabled" = false;
        "privacy.globalprivacycontrol.enabled" = true;
        "signon.rememberSignons" = false;
        "zen.view.compact.enable-at-startup" = true;
        "zen.view.use-single-toolbar" = false;
        "zen.welcome-screen.seen" = true;
      };

      containersForce = true;
      containers = {
        Personal = {
          id = 1;
          color = "blue";
          icon = "fingerprint";
        };
        Work = {
          id = 2;
          color = "orange";
          icon = "briefcase";
        };
        Banking = {
          id = 3;
          color = "green";
          icon = "dollar";
        };
        Shopping = {
          id = 4;
          color = "pink";
          icon = "cart";
        };
      };

      keyboardShortcutsVersion = 19;
      keyboardShortcuts = [
        {
          id = "zen-compact-mode-toggle";
          key = "s";
          keycode = "";
          modifiers = {
            accel = true;
            alt = false;
            control = false;
            meta = false;
            shift = false;
          };
        }
        {
          id = "zen-compact-mode-show-sidebar";
          key = "s";
          keycode = "";
          modifiers = {
            accel = true;
            alt = true;
            control = false;
            meta = false;
            shift = false;
          };
        }
        {
          id = "key_toggleReaderMode";
          disabled = true;
        }
        {
          id = "key_exitFullScreen";
          disabled = true;
        }
      ];
    };
  };

  xdg.mimeApps = {
    associations.added = lib.genAttrs browserMimeTypes (_: lib.mkDefault defaultBrowser);
    defaultApplications = lib.genAttrs browserMimeTypes (_: lib.mkDefault defaultBrowser);
  };

  home.sessionVariables.BROWSER = "zen-stable";
}

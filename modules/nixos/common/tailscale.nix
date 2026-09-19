{ config, hostname, ... }:
{
  # 所有 NixOS host 加入 Headscale tailnet（hs.zineyu.cn），
  # 替代原 hub-and-spoke WireGuard overlay（见 docs/adr/0008-headscale-tailnet.md）。
  #
  # 接入采用双重授权模型（见 docs/secrets.md「Tailnet（Headscale）」）：
  # repo 管理的 host 使用共享 sops 文件中的可复用 preauth key 自动注册
  # （tailscaled-autoconnect 监听 BackendState，NeedsLogin 时自动 tailscale up，
  # 状态丢失可自愈）；手机等其余设备用服务端手动授权。
  #
  # key 的 provisioning（一次性，见 secrets.md）：控制面部署后
  #   headscale preauthkeys create --user zine --reusable --expiration 8760h
  #   ... | sops set --value-stdin secrets/tailscale.yaml '["preauth_key"]'
  # 新 host 若要自动入网，需把其 age recipient 加入 .sops.yaml 中
  # secrets/tailscale.yaml 的规则并 sops updatekeys。
  #
  # 部署注意（fake-ip 代理共存）：tailscaled 的控制连接带 fwmark 0x80000，
  # 会绕过本机 mihomo TUN 的拦截，若控制面域名被 fake-ip 劫持则发往不可路由的
  # 假 IP 超时。运行 fake-ip 代理的 host 需在代理配置中：
  #   1. fake-ip-filter 加入 hs.zineyu.cn（返回真实 IP 直连）
  #   2. nameserver-policy 把 +.ts.zineyu.cn 指向 100.100.100.100（MagicDNS 解析）
  sops.secrets.tailscale_auth_key = {
    sopsFile = ../../../secrets/tailscale.yaml;
    key = "preauth_key";
    mode = "0400";
    # key 更新（轮换）后重新触发自动注册。
    restartUnits = [ "tailscaled-autoconnect.service" ];
  };

  services.tailscale = {
    enable = true;
    # 放行 UDP 41641，有利于 NAT 后的 P2P 直连。
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale_auth_key.path;
    extraUpFlags = [ "--login-server=https://hs.zineyu.cn" ];
  };

  # tailnet 成员互信（沿用原 wg0 的安全 posture）：dev server 的任意端口
  # 对其他节点可达，支撑远程开发调试场景。
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}

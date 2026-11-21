# 蓝牙：内核已检测到适配器（hci0），但没有 hardware.bluetooth.enable 时 BlueZ
# 守护进程（bluetoothd）不会启动，DankMaterialShell 等桌面客户端会报“无适配器”。
# bluez 由此 option 自动拉入，无需单独安装。
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}

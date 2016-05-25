# openvpn-openwrt-fuckrkn
Скрипт для маршрутизации определенного списка адресов через VPN


1. Устанавливаем зависимости: 
```
opkg update 
opkg install openvpn-openssl luci-app-openvpn openssl-util ip ipset
```

2. Настраиваем openvpn client. (Здесь предполагается, что сервер уже настроен и у нас есть  
  - Файл сертификата (client.crt);
  - Файл сертификата удостоверяющего центра (сa.crt);
  - Ключ к сертификату (client.key);

  2.1. Редактируем конфиг  ```/etc/config/openvpn```, добавляем секцию (предварительно скопировав на роутер сертификаты и ключ (файлы указанные в "option ca", "option cert", "option key" ):
  ```
  config openvpn 'fuckrkn'
        option client '1'
        option dev 'tun'
        option script_security '2'
        option proto 'udp'
        option resolv_retry 'infinite'
        option nobind '1'
        option persist_key '1'
        option persist_tun '1'
        option user 'nobody'
        option comp_lzo 'yes'
        option verb '4'
        option remote 'your-remote-address-here''
        option enabled '1'
        option ca '/etc/openvpn/myca.crt'
        option cert '/etc/openvpn/myclient1.crt'
        option key '/etc/openvpn/myclient1.key'
        option route_up '/usr/bin/fuck_rkn.sh'
  ```

	**ВНИМАНИЕ: если нужно выполнять скрипт, указанный в "route up", необходимо добавить ```option script_security '2'```, НО, после того, как мы это добавим, эту конфигурацию нельзя будет редактировать из LuCI UI - оно удалит эту опцию.**

  2.2. Добавляем интерфейс в ```/etc/config/network```
  ```
  config interface 'vpn'
        option proto 'none'
        option ifname 'tun0'
        option defaultroute '0'
  ```

  2.3. Добавляем в ```/etc/config/firewall```
  ```
  config zone
        option name 'vpn'
        option network 'vpn'
        option input 'REJECT'
        option output 'ACCEPT'
        option forward 'REJECT'
        option masq '1'
        option mtu_fix '1'
  ```
3. Качаем скрипт отсюда https://gist.github.com/anonymous/5bfb2302ba20c28da2f38cbb05974811, кладем его в ```/usr/bin```, делаем исполняемым (chmod a+x).

4. Заходим в LuCI, Services -> OpenVPN, находим наш конфиг, жмем старт, проверяем как работает. Если все работает, то ставим галку enabled и перегружаем роутер.

5. Добавляем в crontab для ежедневного обновления списка:
  ```
  # run fuck_rkn.sh daily
  00 00 * * * /usr/bin/fuck_rkn.sh
  ```

Content-Type: multipart/mixed; boundary="==FGTCONF=="
MIME-Version: 1.0

--==FGTCONF==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system vdom-exception
    edit 1
        set object system.interface
    next
end

config system global
    set admin-sport ${admin_port}
    set hostname ${fgt_name}
    set admintimeout 60
end
config system admin
    edit "admin"
        set password ${fgt_password}
    next
end
config system sdn-connector
    edit "gcp"
        set type gcp
    next
end

config system interface
  edit port1
     set mode static
     set ip ${port1-ip}/32
     set allowaccess https ssh  
  next
  edit lo0
      set vdom root
      set ip ${elb_ip}/32
      set type loopback
      set allowaccess probe-response
  next
  edit port2
    set mode static
    set ip ${port2-ip}/32
    set allowaccess probe-response
    set secondary-IP enable
    config secondaryip
      edit 0
        set ip ${ilb_ip}/32
        set allowaccess probe-response
    next
%{ for idx, alias_ip in port2_alias_ips ~}
      edit ${idx + 1}
        set ip ${alias_ip}/32
        set allowaccess probe-response
    next
%{ endfor ~}
  end
  next
  edit port3
    set mode static
    set ip ${port3-ip}/32
    set allowaccess ping
  next
  edit port4
    set mode static
    set ip ${port4-ip}/32
    set allowaccess ping https ssh fgfm
    next
  end 
end

config system ha
    set group-name "group1"
    set mode a-p
    set hbdev "port3" 50
    set session-pickup enable
    set ha-mgmt-status enable
    set password Fortinet1234$
    config ha-mgmt-interfaces
        edit 1
            set interface "port4"
            set gateway ${mgmt_gw}
        next
    end
    set override disable
    set priority ${priority}
    set unicast-hb enable
    set unicast-hb-peerip ${other_fgt_ha_ip}
    set unicast-hb-netmask ${ha_netmask}
end

config router static
  edit 0
    set device port1
    set gateway ${ext_gw}
  next
  edit 0
    set device port2
    set dst 35.191.0.0/16
    set gateway ${int_gw}
  next
  edit 0
    set device port2
    set dst 130.211.0.0/22
    set gateway ${int_gw}
  next
  edit 0
    set device port2
    set dst ${port2-sub}
    set gateway ${int_gw}
  next
end

config system probe-response
    set mode http-probe
    set http-probe-value OK
    set port ${healthcheck_port}
end

config firewall address
    edit lo0
        set subnet ${elb_ip}/32
    next
end

config firewall service custom
    edit "probe"
        set tcp-portrange 8008
    next
end

config firewall policy
    edit 1
        set name "outbound"
        set srcintf "port2"
        set dstintf "port1"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set comments "out to internet"
    next
    edit 2
        set name "in-to-loopback"
        set srcintf "port1"
        set dstintf "lo0"
        set action accept
        set srcaddr "all"
        set dstaddr "lo0"
        set schedule "always"
        set service "IKE" "ESP" "probe"
    next
end

--==FGTCONF==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="startup_delay.sh"

#!/bin/bash
# Wait for network infrastructure to be fully ready
sleep 30
# Test connectivity before proceeding
for i in {1..10}; do
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        break
    fi
    sleep 10
done

%{ if license_type == "flex" }
--==FGTCONF==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

LICENSE-TOKEN:${license_token}

%{ endif }

%{ if license_type == "byol" }
--==FGTCONF==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

${file(license_file)}

%{ endif }

--==FGTCONF==--
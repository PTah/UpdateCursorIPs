# MikroTik RouterOS 6.49.13 script:
# Refreshes Cursor-related IPv4 addresses in firewall address-list.
#
# Usage:
# 1) Import this file on router.
# 2) Ensure script "cursor-refresh" exists with this source.
# 3) Add scheduler:
#    /system scheduler add name=cursor-refresh interval=1m start-time=startup on-event=cursor-refresh
# 4) Run once manually:
#    /system script run cursor-refresh
/system script
add name=cursor-refresh policy=read,write,test source={
    :local listName "cursor_bypass_v4"
    :local ttl "30m"
    :local tag "cursor-auto"
    :local added 0
    :local updated 0
    :local domains {
        "api2.cursor.sh";
        "authenticate.cursor.sh";
        "authenticator.cursor.sh";
        "marketplace.cursorapi.com";
        "cursor-cdn.com";
        "api.cursor.com";
        "cursor.com"
    }
    :foreach d in=$domains do={
        :do { :resolve $d } on-error={ :log warning ("cursor-refresh: resolve fail " . $d) }
    }
    :foreach i in=[/ip dns cache all find where type="A"] do={
        :local n [/ip dns cache all get $i name]
        :local ip [/ip dns cache all get $i data]
        :local ok false
        :if ([:find $n "cursor.sh"] != nil) do={ :set ok true }
        :if ([:find $n "cursorapi.com"] != nil) do={ :set ok true }
        :if ([:find $n "cursor-cdn.com"] != nil) do={ :set ok true }
        :if ([:find $n "workosdns.com"] != nil) do={ :set ok true }
        :if ([:find $n "workos-dns.com"] != nil) do={ :set ok true }
        :if ($ok=true) do={
            :local ex [/ip firewall address-list find where list=$listName and address=$ip]
            :if ([:len $ex]=0) do={
                /ip firewall address-list add list=$listName address=$ip timeout=$ttl comment=($tag . " " . $n)
                :set added ($added + 1)
            } else={
                :foreach e in=$ex do={
                    /ip firewall address-list set $e timeout=$ttl comment=($tag . " " . $n)
                }
                :set updated ($updated + 1)
            }
        }
    }
    :log info ("cursor-refresh: added=" . $added . " updated=" . $updated)
}

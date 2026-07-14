# WARNING. THIS FILE IS AUTO-GENERATED. DO NOT MODIFY!
#
# This file contains build system settings derived from your snippets.
# Its contents are an implementation detail that should not be used outside
# of Zephyr's snippets CMake module.
#
# See the Snippets guide in the Zephyr documentation for more information.

###############################################################################
# Global information about all snippets.

# The name of every snippet that was discovered.
set(SNIPPET_NAMES "bt-ll-sw-split" "cdc-acm-console" "nordic-flpr" "nordic-flpr-xip" "nordic-log-stm" "nordic-log-stm-dict" "nordic-ppr" "nordic-ppr-xip" "nrf52833-nosd" "nrf52840-nosd" "nus-console" "ram-console" "rp2-boot-mode-retention" "rtt-console" "rtt-tracing" "serial-console" "studio-rpc-usb-uart" "usbip-native-sim" "wifi-ipv4" "xen_dom0" "zmk-usb-logging")
# The paths to all the snippet.yml files. One snippet
# can have multiple snippet.yml files.
set(SNIPPET_PATHS "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/bt-ll-sw-split/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/cdc-acm-console/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/nordic-flpr-xip/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/nordic-flpr/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/nordic-log-stm-dict/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/nordic-log-stm/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/nordic-ppr-xip/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/nordic-ppr/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/nus-console/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/ram-console/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/rp2-boot-mode-retention/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/rtt-console/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/rtt-tracing/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/serial-console/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/usbip-native-sim/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/wifi-ipv4/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zephyr/snippets/xen_dom0/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zmk/app/snippets/nrf52833-nosd/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zmk/app/snippets/nrf52840-nosd/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zmk/app/snippets/studio-rpc-usb-uart/snippet.yml" "/home/tverdyy/Projects/uroblike-zyraft/zmk/app/snippets/zmk-usb-logging/snippet.yml")

# Create variable scope for snippets build variables
zephyr_create_scope(snippets)

###############################################################################
# Snippet 'studio-rpc-usb-uart'

# Common variable appends.
zephyr_set(DTS_EXTRA_CPPFLAGS "-DZMK_BEHAVIORS_KEEP_ALL" SCOPE snippets APPEND)
zephyr_set(EXTRA_DTC_OVERLAY_FILE "/home/tverdyy/Projects/uroblike-zyraft/zmk/app/snippets/studio-rpc-usb-uart/studio-rpc-usb-uart.overlay" SCOPE snippets APPEND)
zephyr_set(EXTRA_CONF_FILE "/home/tverdyy/Projects/uroblike-zyraft/zmk/app/snippets/studio-rpc-usb-uart/studio-rpc-usb-uart.conf" SCOPE snippets APPEND)


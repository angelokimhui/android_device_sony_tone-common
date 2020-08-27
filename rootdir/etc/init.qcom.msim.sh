#!/vendor/bin/sh

MSIM_DEVICES=(
    F8132 # XPerf
    F8332 # XZ
    G8232 # XZs
)
MSIM_DEVICE=0

for device in "${MSIM_DEVICES[@]}"; do
    if grep -q "Model: ${device}" /dev/block/bootdevice/by-name/LTALabel; then
        MSIM_DEVICE=1
        break
    fi
done

if [[ "${MSIM_DEVICE}" -eq 1 ]]; then
    setprop persist.vendor.radio.multisim.config dsds
    setprop persist.radio.multisim.config dsds
    setprop ro.telephony.default_network "22,22"
    setprop persist.vendor.radio.block_allow_data 0
else
    setprop ro.telephony.default_network 22
    setprop persist.vendor.radio.block_allow_data 1
fi

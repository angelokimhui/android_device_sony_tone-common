#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2019 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

LINEAGE_ROOT="${MY_DIR}"/../../..

HELPER="${LINEAGE_ROOT}/vendor/lineage/build/tools/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"


function blob_fixup() {
    case "${1}" in
    vendor/lib64/libcameralight.so)
        ;&
    vendor/lib/libcameralight.so)
        ;&
    vendor/lib64/lib_fpc_tac_shared.so)
        ;&
    vendor/lib/lib_fpc_tac_shared.so)
        sed -i "s/\/system\/etc\//\/vendor\/etc\//g" "${2}"
        ;;
    vendor/lib/libSecureUILib.so)
        ;&
    vendor/lib/libGPTEE_vendor.so)
        ;&
    vendor/lib/libGPTEE_system.so)
        ;&
    vendor/lib/lib_asb_tee.so)
        ;&
    vendor/lib/libtzdrmgenprov.so)
        ;&
    vendor/lib64/libSecureUILib.so)
        ;&
    vendor/lib64/libGPTEE_vendor.so)
        ;&
    vendor/lib64/libtpm.so)
        ;&
    vendor/lib64/libGPTEE_system.so)
        ;&
    vendor/lib64/lib_asb_tee.so)
        ;&
    vendor/lib64/libtee.so)
        ;&
    vendor/lib64/libtzdrmgenprov.so)
        ;&
    vendor/bin/secd)
        sed -i "s/\/system\/etc\/firmware/\/vendor\/etc\/firmware/g" "${2}"
        ;;
	vendor/bin/imsrcsd)
		patchelf --add-needed "libbase_shim.so" "${2}"
		;;

	vendor/lib64/lib-uceservice.so)
		patchelf --add-needed "libbase_shim.so" "${2}"
	;;
    esac
}

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

SECTION=
KANG=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

# Initialize the helper for common device
setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${LINEAGE_ROOT}" true "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"

if [ -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${LINEAGE_ROOT}" false "${CLEAN_VENDOR}"

    extract "${MY_DIR}/../${DEVICE}/proprietary-files.txt" "${SRC}" \
            "${KANG}" --section "${SECTION}"
fi

"${MY_DIR}/setup-makefiles.sh"

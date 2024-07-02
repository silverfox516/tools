#!/usr/bin/python3

import argparse
import re

HAVETO_INCLUDE = [
"onIap2DeviceUpdate: deviceUUID",
"connectBluetoothDevice() : address[",
"onInformationUpdate()",
"Wireless CarPlay connection",
"iAP2ClientStart(895)",
"iAP2ClientStop(972)",
"android.hardware.bt.action",
"android.intent.action.telechips" ]

HAVETO_EXCLUDE = [
        "android.intent.action.telechips.carplay.iap.message"
        ]

ANDROID_TIME_PATTERN = '^\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d*'

def has_str(line, strs):
    for tag in strs:
        if tag in line:
            return True
    return False

def is_match(line1, line2, without):
    l1 = re.sub(without, '', line1)
    l2 = re.sub(without, '', line2)
    return l1 == l2

def test_is_match():
    l1 = '03-19 16:27:02.100  1768  2569 I CarPlay :  : run() at (line: 1040)'
    l2 = '03-19 16:27:02.111   729 17932 E ActivityManager: java.lang.Throwable'
    l3 = '03-19 16:27:02.112   729 17932 E ActivityManager: java.lang.Throwable'

    print('l1 = ' + l1)
    print('l2 = ' + l2)
    print('match : ' + str(is_match(l1, l2, ANDROID_TIME_PATTERN)))
    print('l1 = ' + l2)
    print('l2 = ' + l3)
    print('match : ' + str(is_match(l2, l3, ANDROID_TIME_PATTERN)))

def test_has_str():
    l1 = '03-19 16:39:49.908  1768 18603 I CarPlayService: onPortOpened()'
    l2 = '03-19 16:39:50.864  1768  2569 I CarPlay : Tag:ResourceManagerService,onIap2DeviceUpdate: deviceUUID: FA225C25-5D1D-440D-901B-269DE1799248 macAddress: a0:3b:e3:aa:c4:41 usbSerial: 94de20a62e6b33b3e101c3a4af0d0e51e3475636 deviceName: iPhone  : onIap2DeviceUpdate() at (line: 798)'
    l3 = '03-19 16:31:15.996   729  1040 E ActivityManager: Sending non-protected broadcast android.hardware.bt.action.CARPLAY_CLIENT_DEVICE_DETACHED from system 1656:com.telechips.iap2.client/1000 pkg com.telechips.iap2.client'
    l4 = '03-19 16:31:15.995  2123  5820 I TSUApp_ : [TSUApp_TsuAppBinderImpl.java][requestTsuSomeIpData][requestTsuSomeIpData eventId = 3]'
    l5 = '03-19 16:31:18.932  1880  2072 I iAP2    :  iAP2ClientStart(895) iap2handle 0x76dc188800 detect 0x76dddec298'

    print('has : ' + str(has_str(l1, HAVETO_INCLUDE)) + ', l = ' + l1)
    print('has : ' + str(has_str(l2, HAVETO_INCLUDE)) + ', l = ' + l2)
    print('has : ' + str(has_str(l3, HAVETO_INCLUDE)) + ', l = ' + l3)
    print('has : ' + str(has_str(l4, HAVETO_INCLUDE)) + ', l = ' + l4)
    print('has : ' + str(has_str(l5, HAVETO_INCLUDE)) + ', l = ' + l5)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description = 'hello');    
    parser.add_argument('--file', required = True, help = 'file to filter out');

    args = parser.parse_args()

    l = []
    in_file = open(args.file, 'r')
    out_file = open(args.file + '.out', 'w');

    while True:
        try:
            line = in_file.readline()
        except Exception as e:
            in_file.seek(in_file.tell())
            print(e)

        if not line: break

        if not has_str(line, HAVETO_INCLUDE):
            continue
        if has_str(line, HAVETO_EXCLUDE):
            continue

        if len(l) == 0:
            l.append(line)
        elif is_match(l[-1], line, ANDROID_TIME_PATTERN):
            l.append(line)
        else:
            out_file.write(l[-1])
            l = []
            l.append(line)

    out_file.close()
    in_file.close()

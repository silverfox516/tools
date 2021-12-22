#!/bin/bash

function usage
{
	echo "Usage: $@ -i <input bmp file> -f <convert format>"
	exit 1
}

while getopts "i:f:b:" opt; do
	case $opt in
		i)
			IN_FILE=${OPTARG}
			;;
		f)
			OUT_FMT=${OPTARG}
			;;
		b)
			BASE_NAME=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done

if [ "$IN_FILE" == "" ]; then
	usage
fi

if [ "${BASE_NAME}" == "" ]; then
	if [ "${IN_FILE:(-4)}" == ".bmp" ] || [ "${IN_FILE:(-4)}" == ".BMP" ]; then
		BASE_NAME=${IN_FILE:0:(-4)}
	else
		BASE_NAME=${IN_FILE}
	fi
fi

if [ "${OUT_FMT}" == "" ]; then
	OUT_FMT=bgra
fi

# define variables
OUT_RAW=${BASE_NAME}.img
OUT_HEX=${BASE_NAME}.hex
OUT_HEADER=${BASE_NAME}.h
BASE_NAME_UC=${BASE_NAME^^}
BASE_NAME_LC=${BASE_NAME,,}
IN_W=`identify -format '%w' ${IN_FILE}`
IN_H=`identify -format '%h' ${IN_FILE}`

echo BASE_NAME		: ${BASE_NAME}
echo OUT_RAW		: ${OUT_RAW}
echo OUT_HEX		: ${OUT_HEX}
echo OUT_HEADER		: ${OUT_HEADER}
echo BASE_NAME_UC	: ${BASE_NAME_UC}
echo IN_W		: ${IN_W}
echo IN_H		: ${IN_H}

# convert bmp to raw
convert -depth 8 ${IN_FILE} ${OUT_FMT}:${OUT_RAW}

# convert raw to hex
hexdump -v -e '/1 "0x%02x,"' ${OUT_RAW} > ${OUT_HEX}

# make header
cat > ${OUT_HEADER} <<EOF
#ifndef ${BASE_NAME_UC}_H
#define ${BASE_NAME_UC}_H
#define ${BASE_NAME_UC}_WIDTH	${IN_W}
#define ${BASE_NAME_UC}_HEIGHT	${IN_H}
unsigned char ${BASE_NAME_LC}[] = {
EOF

cat ${OUT_HEX} >> ${OUT_HEADER}

cat >> ${OUT_HEADER} <<EOF

};
#endif
EOF

rm ${OUT_RAW}
rm ${OUT_HEX}

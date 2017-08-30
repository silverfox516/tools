#!/usr/bin/python

import os

class HiddenImage:

    OK = 0
    NOK = 1

    IMAGE_SCREEN = 0
    IMAGE_RESERVED = 1
    IMAGE_NUMBER = 2

    hiddenPartitionImages = [
            [ "bootlogo.bmp", IMAGE_SCREEN ],
            [ "update.bmp", IMAGE_SCREEN ],
            [ "update_success.bmp", IMAGE_SCREEN ],
            [ "update_error.bmp", IMAGE_SCREEN ],
            [ "reserved", IMAGE_RESERVED ],
            [ "reserved", IMAGE_RESERVED ],
            [ "0.bmp", IMAGE_NUMBER ],
            [ "1.bmp", IMAGE_NUMBER ],
            [ "2.bmp", IMAGE_NUMBER ],
            [ "3.bmp", IMAGE_NUMBER ],
            [ "4.bmp", IMAGE_NUMBER ],
            [ "5.bmp", IMAGE_NUMBER ],
            [ "6.bmp", IMAGE_NUMBER ],
            [ "7.bmp", IMAGE_NUMBER ],
            [ "8.bmp", IMAGE_NUMBER ],
            [ "9.bmp", IMAGE_NUMBER ],
            [ "reset.bmp", IMAGE_SCREEN ],
            [ "reset_success.bmp", IMAGE_SCREEN ],
            [ "reset_error.bmp", IMAGE_SCREEN ],
            [ "reserved", IMAGE_RESERVED ],
            [ "reserved", IMAGE_RESERVED ],
            ]

    bitsPerPixel = 4
    imageSizes = {}

    def __init__(self, sw = 1280, sh = 720, nw = 12, nh = 31):
        self.screenWidth = sw
        self.screenHeight = sh
        self.numberWidth = nw
        self.numberHeight = nh
        self.screenSize = self.bitsPerPixel * sw * sh
        self.numberSize = self.bitsPerPixel * nw * nh
        self.imageSizes[self.IMAGE_SCREEN] = self.screenSize
        self.imageSizes[self.IMAGE_NUMBER] = self.numberSize

    def printImageList(self):
        print "%dx%d, %dx%d, %d" % (
                self.screenWidth,
                self.screenHeight,
                self.numberWidth,
                self.numberHeight,
                self.bitsPerPixel)

        for image in self.hiddenPartitionImages:
            print image
            
    def verifyRawImageSize(self, imageType, imageFileName):
        imageSize = os.path.getsize(imageFileName)
        if imageSize == self.imageSizes[imageType]:
            return self.OK
        return self.NOK

if __name__ == '__main__':
    image = HiddenImage(800, 480, 11, 21)
    image.printImageList()
    image.verifyRawImageSize(image.IMAGE_SCREEN, "hello")

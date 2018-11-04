#!/usr/bin/python 

import os
import sys
import shutil

def checkArgs(args):
    if 3 != len(args):
        print args[0] + " [file contain list to copy] [dst dir]"
        return False

    if not os.path.isfile(args[1]):
        print args[1] + " is not a file"
        return False

    if os.path.isdir(args[2]):
        print args[2] + " exists"
        return False

    return True

class CopyTool:
    def __init__(self, listfile, dstdir):
        self.listfile = listfile
        self.dstdir = dstdir
        self.curdir = os.getcwd()
        self.readFilesToCopy()
        self.copyFiles()

    def getDirToCopy(self, file):
        if os.path.isfile(file):
            return '/'.join([self.dstdir, os.path.dirname(file)])
        else:
            return '/'.join([self.dstdir, file])

    def readFilesToCopy(self):
        self.filesToCopy = {}
        with open(self.listfile) as f:
            for file in f.readlines():
                file = file.replace('\n', '')
                if '' == file:
                    continue

                if not os.path.exists(file):
                    continue

                self.filesToCopy[os.path.abspath(file)] = os.path.abspath(self.getDirToCopy(file))

    def copyFiles(self):
        for s, d in self.filesToCopy.items():
            try:
                if os.path.isfile(s):
                    if not os.path.exists(d):
                        os.makedirs(d)
                    shutil.copy2(s, d)
                else:
                    shutil.copytree(s, d)
            except OSError as e:
                print e
                print 'while copying ' + s


if __name__ == "__main__":
    if not checkArgs(sys.argv):
        exit(1)

    ct = CopyTool(sys.argv[1], sys.argv[2])


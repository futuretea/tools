#!/usr/bin/env python
import sys
import itchat


if __name__ == "__main__":
    argv = sys.argv
    argc = len(argv)
    if argc == 2:
        itchat.auto_login(hotReload=True)
        itchat.send_file(fileDir=str(argv[1]), toUserName='filehelper')
    else:
        print("usage:")
        print(" filehelper.py file")

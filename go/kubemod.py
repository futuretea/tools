#!/usr/bin/env python
# -*- coding: UTF-8 -*-


import subprocess
import sys
import os

import json

trans = True

def shell_exec(cmd):
    # print(cmd)
    cmd_stdout = ""
    try:
        cmd_obj = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=os.environ.copy())
        cmd_stdout = cmd_obj.stdout.read().decode('utf-8')
    except Exception as e:
        print(e)
    return cmd_stdout


def shell_exec_getlines(cmd):
    # print(cmd)
    cmd_stdout_lines = list()
    try:
        cmd_obj = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=os.environ.copy())
        cmd_stdout_lines = [line.decode('utf-8').strip()
                            for line in cmd_obj.stdout.readlines()]
    except Exception as e:
        print(e)
    return cmd_stdout_lines


# 获取go版本
def get_go_version():
    cmd = "go version | awk '{print $3}' | sed 's/go//g'"
    cmd_stdout = shell_exec(cmd)
    return cmd_stdout


# 获取mod版本
def get_mod_path_version(path_revision):
    path_revision_split = path_revision.split('@')
    path = path_revision_split[0]
    revision = path_revision_split[1]
    global trans
    if not trans:
        return path, revision
    cmd = "go mod download -json %s" % path_revision
    cmd_stdout = shell_exec(cmd)
    try:
        ret_info = json.loads(cmd_stdout)
        return ret_info["Path"], ret_info["Version"]
    except Exception as e:
        print(e)
    return path, ""


# k8s依赖
def get_kubernetes_staging_requires(kubernetes_revision):
    cmd = "curl -sS https://raw.githubusercontent.com/kubernetes/kubernetes/v%s/go.mod \
        | grep staging | awk -F \"=>\" '{print $1}'" % kubernetes_revision
    kubernetes_staging_requires = shell_exec_getlines(cmd)
    # print(kubernetes_staging_requires)
    return kubernetes_staging_requires


# k8s替换依赖
def print_kubernetes_staging_requires(kubernetes_staging_requires, kubernetes_revision):
    for kubernetes_staging_require in kubernetes_staging_requires:
        path_revision = "%s@kubernetes-%s" % (
            kubernetes_staging_require, kubernetes_revision)
        _, mod_version = get_mod_path_version(path_revision)
        if mod_version == "":
            replace_stmt = "\t//%s v0.0.0 => %s kubernetes-%s //download error" % (
                kubernetes_staging_require, kubernetes_staging_require, kubernetes_revision)
        else:
            replace_stmt = "\t%s v0.0.0 => %s %s" % (
                kubernetes_staging_require, kubernetes_staging_require, mod_version)
        print(replace_stmt)


if __name__ == '__main__':

    argv = sys.argv
    argc = len(argv)
    if argc != 2:
        print("usage:")
        print(" kubemod.py kubernetes_version")
        exit(1)

    kubernetes_version = str(argv[1])
    kubernetes_staging_requires = get_kubernetes_staging_requires(
        kubernetes_version)
    print_kubernetes_staging_requires(
        kubernetes_staging_requires, kubernetes_version)

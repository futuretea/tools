#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import json
import subprocess
import sys
import os

debug = os.environ["DEBUG"]
trans = True

direct_repo_dict = dict()
indirect_repo_dict = dict()
direct_list = list()
indirect_list = list()

require_direct_list = list()
require_indirect_list = list()

global_kubernetes_revision = ""
k8s_replace_15 = """
    k8s.io/api => k8s.io/api v0.0.0-20190620084959-7cf5895f2711
    k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.0.0-20190620085554-14e95df34f1f
    k8s.io/apimachinery => k8s.io/apimachinery v0.0.0-20190612205821-1799e75a0719
    k8s.io/apiserver => k8s.io/apiserver v0.0.0-20190620085212-47dc9a115b18
    k8s.io/cli-runtime => k8s.io/cli-runtime v0.0.0-20190620085706-2090e6d8f84c
    k8s.io/client-go => k8s.io/client-go v0.0.0-20190620085101-78d2af792bab
    k8s.io/cloud-provider => k8s.io/cloud-provider v0.0.0-20190620090043-8301c0bda1f0
    k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.0.0-20190620090013-c9a0fc045dc1
    k8s.io/code-generator => k8s.io/code-generator v0.0.0-20190612205613-18da4a14b22b
    k8s.io/component-base => k8s.io/component-base v0.0.0-20190620085130-185d68e6e6ea
    k8s.io/cri-api => k8s.io/cri-api v0.0.0-20190531030430-6117653b35f1
    k8s.io/csi-translation-lib => k8s.io/csi-translation-lib v0.0.0-20190620090116-299a7b270edc
    k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.0.0-20190620085325-f29e2b4a4f84
    k8s.io/kube-controller-manager => k8s.io/kube-controller-manager v0.0.0-20190620085942-b7f18460b210
    k8s.io/kube-proxy => k8s.io/kube-proxy v0.0.0-20190620085809-589f994ddf7f
    k8s.io/kube-scheduler => k8s.io/kube-scheduler v0.0.0-20190620085912-4acac5405ec6
    k8s.io/kubelet => k8s.io/kubelet v0.0.0-20190620085838-f1cb295a73c9
    k8s.io/legacy-cloud-providers => k8s.io/legacy-cloud-providers v0.0.0-20190620090156-2138f2c9de18
    k8s.io/metrics => k8s.io/metrics v0.0.0-20190620085625-3b22d835f165
    k8s.io/sample-apiserver => k8s.io/sample-apiserver v0.0.0-20190620085408-1aef9010884e
"""


def shell_exec_lines(cmd):
    global debug
    if debug:
        print(cmd)
    cmd_stdout_lines = list()
    try:
        cmd_obj = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=os.environ.copy())
        cmd_stdout_lines = [line.decode('utf-8').strip()
                            for line in cmd_obj.stdout.readlines()]
    except Exception as e:
        print(e)
    return cmd_stdout_lines


def shell_exec(cmd):
    global debug
    if debug:
        print(cmd)
    cmd_stdout = ""
    try:
        cmd_obj = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=os.environ.copy())
        cmd_stdout = cmd_obj.stdout.read().decode('utf-8')
    except Exception as e:
        print(e)
    return cmd_stdout


# 获取go版本
def get_go_version():
    cmd = "go version | awk '{print $3}' | sed 's/go//g'"
    cmd_stdout = shell_exec(cmd)
    return cmd_stdout


# 获取mod版本
def get_mod_path_version(path_revision):
    global trans
    if not trans:
        path_revision_split = path_revision.split('@')
        return path_revision_split[0], path_revision_split[1]
    cmd = "go mod download -json %s" % path_revision
    cmd_stdout = shell_exec(cmd)
    try:
        ret_info = json.loads(cmd_stdout)
        return ret_info["Path"], ret_info["Version"]
    except Exception as e:
        print(e)
    return "", ""


# 获取对应的git仓库
def get_repo_path(path):
    format2list = ["google.golang.org", "k8s.io"]
    paths = path.split('/')
    repo_path = "/".join(paths[:3])
    for url in format2list:
        if path.startswith(url):
            repo_path = "/".join(paths[:2])
    return repo_path


# 获取完整路径
def get_path_revision(origin, path, revision, repo_path):
    # 获取已记录的版本
    if origin:
        exist_revision = indirect_repo_dict.get(repo_path)
    else:
        exist_revision = direct_repo_dict.get(repo_path)
    # 没有已记录的仓库版本则添加
    if not exist_revision:
        return "%s@%s" % (repo_path, revision)
    # 和已有仓库版本一致则跳过
    if exist_revision and (exist_revision == revision):
        return ""
    # 和已有仓库版本不一致则保留自身的路径
    if exist_revision and (exist_revision != revision):
        return "%s@%s" % (path, revision)


# 解析单个package
def parse_package(package):
    # 如果是vendor依赖时有这个字段
    origin = package.get("origin")
    # commit版本
    revision = package.get("revision")
    # 如果没有指定版本则跳过
    if revision == "":
        return
    # 包路径
    path = package["path"]
    # 对应仓库路径
    repo_path = get_repo_path(path)
    # 完整路径
    path_revision = get_path_revision(origin, path, revision, repo_path)
    if path_revision == "":
        return
    if origin:
        indirect_list.append(path_revision)
        indirect_repo_dict[repo_path] = revision
    else:
        direct_list.append(path_revision)
        direct_repo_dict[repo_path] = revision


# 解析vendor.json文件
def parser_vendor_json(vendor_json_path):
    with open(vendor_json_path) as f:
        vendor = json.load(f)

    packages = vendor["package"]
    for package in packages:
        parse_package(package)

    return vendor["rootPath"]


# 直接依赖
def get_require_direct_list(direct_list, comment=""):
    global global_kubernetes_revision
    for path_revision in direct_list:
        mod_path, mod_version = get_mod_path_version(path_revision)
        if mod_path == "k8s.io/kubernetes":
            global_kubernetes_revision = path_revision.split("@")[1]
        if mod_path == "" and mod_version == "":
            require_direct = path_revision
        else:
            require_direct = "%s %s%s" % (mod_path, mod_version, comment)
        print("\t%s" % require_direct)
        require_direct_list.append(require_direct)


# vendor依赖
def get_require_indirect_list(indirect_list):
    for path_revision in indirect_list:
        require_indirect = path_revision
        print("\t//%s // vendor" % require_indirect)
        require_direct_list.append(require_indirect)


# k8s依赖
def get_staging_k8s_list(kubernetes_revision):
    cmd = "curl -sS https://raw.githubusercontent.com/kubernetes/kubernetes/%s/go.mod \
        | grep staging | awk -F \"=>\" '{print $1}'" % kubernetes_revision
    staging_k8s_list = shell_exec_lines(cmd)
    global debug
    if debug:
        print(staging_k8s_list)
    return staging_k8s_list


# k8s替换依赖
def get_replace_k8s_list(staging_k8s_list, kubernetes_revision):
    replace_k8s_list = list()
    for staging_k8s in staging_k8s_list:
        path_revision = "%s@%s" % (staging_k8s, kubernetes_revision)
        mod_path, mod_version = get_mod_path_version(path_revision)
        if mod_path == "" and mod_version == "":
            replace_k8s = "%s v0.0.0 => %s %s" % (
                staging_k8s, staging_k8s, kubernetes_revision)
        else:
            replace_k8s = "%s v0.0.0 => %s %s" % (
                staging_k8s, mod_path, mod_version)
        print("\t%s" % replace_k8s)
        replace_k8s_list.append(replace_k8s)


if __name__ == '__main__':

    argv = sys.argv
    argc = len(argv)
    if argc != 2:
        print("usage:")
        print(" gomx.py vendor.json")
        exit(1)
    module_name = parser_vendor_json(str(argv[1]))
    print("module %s" % module_name)
    print("go %s" % get_go_version())
    print("require (")
    get_require_direct_list(direct_list)
    get_require_indirect_list(indirect_list)
    print(")")
    print("replace (")
    global debug
    if debug:
        print(g_kubernetes_revision)
    if global_kubernetes_revision == "e8462b5b5dc2584fdcd18e6bcfe9f1e4d970a529":
        print(k8s_replace_15)
    # staging_k8s_list = get_staging_k8s_list(global_kubernetes_revision)
    # get_replace_k8s_list(staging_k8s_list, global_kubernetes_revision)
    print(")")

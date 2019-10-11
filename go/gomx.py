#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import json
import subprocess
import sys
import os

debug = os.environ.get("DEBUG")
trans = True

direct_repos_dict = dict()
vendor_repos_dict = dict()

direct_requires = list()
vendor_requires = list()

direct_requires_dict = dict()
vendor_requires_dict = dict()


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
# [global] vendor_repos_dict
# [global] direct_repos_dict
def get_path_revision(origin, path, revision, repo_path):
    # 获取已记录的版本
    if origin:
        exist_revision = vendor_repos_dict.get(repo_path)
    else:
        exist_revision = direct_repos_dict.get(repo_path)
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
# [global] vendor_requires
# [global] vendor_repos_dict
# [global] direct_requires
# [global] direct_repos_dict
def parse_package(package, path_key, revision_key, origin_key):
    # 如果是vendor依赖时有这个字段
    origin = package.get(origin_key)
    # commit版本
    revision = package.get(revision_key)
    # 如果没有指定版本则跳过
    if revision == "":
        return
    # 包路径
    path = package[path_key]
    # 对应仓库路径
    repo_path = get_repo_path(path)
    # 完整路径
    # print(origin, path, revision, repo_path)
    path_revision = get_path_revision(origin, path, revision, repo_path)
    if path_revision == "":
        return
    if origin:
        vendor_requires.append(path_revision)
        vendor_repos_dict[repo_path] = revision
    else:
        direct_requires.append(path_revision)
        direct_repos_dict[repo_path] = revision


# 直接依赖
def print_direct_requires(direct_requires, comment=""):
    for path_revision in direct_requires:
        mod_path, mod_version = get_mod_path_version(path_revision)
        if mod_version == "":
            direct_require_stmt = "\t//%s //download error" % path_revision
        else:
            direct_require_stmt = "\t%s %s%s" % (
                mod_path, mod_version, comment)
            direct_requires_dict[mod_path] = mod_version
        print(direct_require_stmt)


# vendor依赖
def print_vendor_requires(vendor_requires):
    for path_revision in vendor_requires:
        vendor_require_stmt = "\t//%s // vendor" % path_revision
        print(vendor_require_stmt)


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


def get_kubernetes_version(direct_requires_dict):
    for mod_path, mod_version in direct_requires_dict.items():
        if mod_path == "k8s.io/kubernetes":
            kubernetes_version = mod_version.lstrip("v")
            return kubernetes_version

def get_json_keys(mode):
    if mode == "govendor":
        return "rootPath", "package", "path", "revision", "origin"
    elif mode == "godeps":
        return "ImportPath", "Deps", "ImportPath", "Rev", None
    print("unsupport mode")
    exit(1)

if __name__ == '__main__':

    argv = sys.argv
    argc = len(argv)
    if argc != 3:
        print("usage:")
        print(" gomx.py vendor_json_path mode")
        exit(1)

    vendor_json_path = str(argv[1])
    mode = str(argv[2])
    name_key, package_key, path_key, revision_key, origin_key = get_json_keys(mode)
    with open(vendor_json_path) as f:
        vendor = json.load(f)
    module_name = vendor[name_key]
    packages = vendor[package_key]
    for package in packages:
        parse_package(package, path_key, revision_key, origin_key)

    print("module %s" % module_name)
    print("go %s" % get_go_version())
    print("require (")
    print_direct_requires(direct_requires)
    print_vendor_requires(vendor_requires)
    print(")")
    print("replace (")
    kubernetes_version = get_kubernetes_version(direct_requires_dict)
    kubernetes_staging_requires = get_kubernetes_staging_requires(
        kubernetes_version)
    print_kubernetes_staging_requires(
        kubernetes_staging_requires, kubernetes_version)
    print(")")

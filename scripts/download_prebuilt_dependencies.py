#!/usr/bin/python
#
# copyright Guillaume Dumont (2016)

import os
import sys
import urllib
import hashlib
import argparse
import tarfile

from download_model_binary import reporthook

WIN_DEPENDENCIES_URLS = dict(
    v120=("https://github.com/willyd/caffe-builder/releases/download/v1.0.0/libraries_v120_x64_1.0.0.tar.bz2",
          "e8e92d1d19e99f0a52e0fde23a99249b435d5d8b")
)

# function for checking SHA1.
def model_checks_out(filename, sha1):
    with open(filename, 'rb') as f:
        return hashlib.sha1(f.read()).hexdigest() == sha1


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Download prebuilt dependencies for windows.')
    parser.add_argument('--msvc_version', default='v120', choices=['v120',])
    args = parser.parse_args()

    # get the appropriate url
    try:
        url, sha1 = WIN_DEPENDENCIES_URLS[args.msvc_version]
    except KeyError:
        print('ERROR: Could not find url for MSVC version = {}.'.format(args.msvc_version))
        sys.exit(1)

    dep_filename = os.path.split(url)[1]
    # Download binaries
    print("Downloading dependencies. Please wait...")
    urllib.urlretrieve(url, dep_filename, reporthook)
    if not model_checks_out(dep_filename, sha1):
        print('ERROR: dependencies did not download correctly! Run this again.')
        sys.exit(1)
    print("\nDone.")

    # Extract the binaries from the tar file
    tar = tarfile.open(dep_filename, 'r:bz2')
    print("Extracting dependencies. Please wait...")
    tar.extractall()
    print("Done.")
    tar.close()


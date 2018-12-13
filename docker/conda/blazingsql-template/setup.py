# Copyright (c) 2018, BlazingDB

from setuptools import setup, find_packages
import os

os.system("echo 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'")

setup(
    name='blazingsql',
    version='1.0',
    description='BlazingDB SQL',
    author='BlazingDB',
    author_email='blazing@blazingdb',
    packages=find_packages(include=['blazingsql', 'blazingsql.*']),
    install_requires=['flatbuffers'],
    zip_safe=False
)



os.system("echo 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'")


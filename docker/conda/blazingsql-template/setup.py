#=============================================================================
# Copyright 2018 BlazingDB, Inc.
#     Copyright 2018 Percy Camilo Triveño Aucahuasi <percy@blazingdb.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================

from setuptools import setup, find_packages
from setuptools.command.install import install
import os

# TODO percy clean prints


# NOTE important always use --single-version-externally-managed to install libgdf_cffi and cudf packages
class cudf_installer(install):

    def run(self):
        print("RUN ###############################")
        self._install_custrings()
        self._install_libgdf_cffi()
        self._install_cudf_python()

        install.run(self)

    def _install_custrings(self):
        print("CUSTRINGS ###############################")
        blazingsql_dir = os.path.dirname(os.path.realpath(__file__))
        os.system("ls -la " + blazingsql_dir)
        pypkg = blazingsql_dir + "/nvstrings-src/python/"
        print("pypkg:", pypkg)
        os.chdir(pypkg)

        #print("Install cmake_setuptools")
        #os.system("pip install cmake_setuptools==0.1.3")

        nvstrings_lib_dir = blazingsql_dir + "/nvstrings-build/"
        nvstrings_include_dir = blazingsql_dir + "/nvstrings-src/cpp/include/"
        env_vars = 'LD_LIBRARY_PATH=%s NVSTRINGS_INCLUDE=%s' % (nvstrings_lib_dir, nvstrings_include_dir)
        print("### ENV_VARS: ", env_vars)
        libnvstrings_install_cmd = "%s python %s/setup.py" % (env_vars, pypkg)
        print("### CMD: ", libnvstrings_install_cmd)
        print("CUSTRINGS Install ###############################")
        os.system(libnvstrings_install_cmd)

    def _install_libgdf_cffi(self):

        print("YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY")
        print(str(self.prefix))
        print(str(self.install_base))
        print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA Installing custom libgdf for BlazingSQL ...")
        blazingsql_dir = os.path.dirname(os.path.realpath(__file__))
        # patch_libgdf_cmd = "sed -i 's/..\/..\//%s\/cudf\/cpp\//g' cudf/cpp/python/libgdf_cffi/libgdf_build.py" % blazingsql_dir
        # patch_librmm_cmd = "sed -i 's/..\/..\//%s\/cudf\/cpp\//g' cudf/cpp/python/librmm_cffi/librmm_build.py" % blazingsql_dir
        # print(patch_libgdf_cmd)
        # os.system(patch_libgdf_cmd)
        # print(patch_librmm_cmd)
        # os.system(patch_libgdf_cmd)

        # TODO percy add ld path library del runtime/lib antes de buold insalarlo

        runtime_dir = self.prefix + "/lib/python3.7/site-packages/blazingsql/runtime"
        pypkg = blazingsql_dir + "/cudf/cpp/python/"
        # libgdf_install_cmd = "pip install --target=%s %s" % (runtime_dir, pypkg)

        cudf_lib_dir = blazingsql_dir + "/cudf/cpp/install/lib"

        env_vars = 'LD_LIBRARY_PATH=%s' % cudf_lib_dir
        libgdf_install_cmd = "%s python %s/setup.py build_ext --inplace" % (env_vars, pypkg)
        print(libgdf_install_cmd)
        working_dir = os.getcwd()

        # NOTE this dir is super important here we need to run the libgdf_cffi installer
        os.chdir(blazingsql_dir + "/cudf/cpp/build/python")
        os.system(libgdf_install_cmd)

        print("INSTALLLLLLLLLLLL")
        ai = "python %s/setup.py install --prefix=%s --single-version-externally-managed --record=record.txt" % (pypkg, runtime_dir)
        os.system(ai)

        os.chdir(working_dir)
        print("Custom libgdf for BlazingSQL installed!")

    def _install_cudf_python(self):
        print("Installing custom cudf for BlazingSQL ...")
        blazingsql_dir = os.path.dirname(os.path.realpath(__file__))
        cudf_include_dir = blazingsql_dir + "/cudf/cpp/include"
        cudf_lib_dir = blazingsql_dir + "/cudf/cpp/install/lib"
        env_vars = 'CFLAGS="-I%s" CXXFLAGS="-I%s" LDFLAGS="-L%s"' % (cudf_include_dir, cudf_include_dir, cudf_lib_dir)
        runtime_dir = self.prefix + "/lib/python3.7/site-packages/blazingsql/runtime"
        pypkg = blazingsql_dir + "/cudf/python/"
        cudf_pip_cmd = "python %s/setup.py install --prefix=%s --single-version-externally-managed --record=record.txt" % (pypkg, runtime_dir)
        cudf_install_cmd = "%s %s" % (env_vars, cudf_pip_cmd)
        print(cudf_install_cmd)
        working_dir = os.getcwd()
        os.chdir(blazingsql_dir + "/cudf/python")

        os.system(cudf_install_cmd)
        print("Custom cudf for BlazingSQL installed!")

        os.chdir(working_dir)


def package_files(directory):
    paths = []
    for (path, directories, filenames) in os.walk(directory):
        for filename in filenames:
            paths.append(os.path.join('..', path, filename))
    return paths


# TODO percy when nvstrings can support more python distributions then try to improve this
nvstrings_python_lib_dir = os.path.dirname(os.path.realpath(__file__)) + "/blazingsql/runtime/lib/python3.7"
nvstrings_python_lib_files = package_files(nvstrings_python_lib_dir)

# Add supervisord files
supervisord_conf_dir = os.path.dirname(os.path.realpath(__file__)) + "/blazingsql/runtime/supervisord"
supervisord_conf_files = package_files(supervisord_conf_dir)

blazingsql_runtime_bin_lib_files = [
    'runtime/bin/BlazingCalcite.jar',
    'runtime/bin/blazingdb_orchestator_service',
    'runtime/bin/testing-libgdf',
    'runtime/lib/libcudf.so',
    'runtime/lib/librmm.so',
    'runtime/lib/libNVStrings.so',
    'runtime/lib/libNVCategory.so'
]

blazingsql_files = supervisord_conf_files + nvstrings_python_lib_files + blazingsql_runtime_bin_lib_files

setup(
    name = 'blazingsql',
    version = '1.0',
    description = 'BlazingDB SQL',
    author = 'BlazingDB',
    author_email = 'blazing@blazingdb',
    packages = find_packages(include = ['blazingsql', 'blazingsql.*']),
    package_data = {'blazingsql': blazingsql_files},
    include_package_data = True,
    install_requires = [
        'cmake_setuptools'
    ],
    cmdclass = {'install': cudf_installer},
    zip_safe = False,
    scripts = ['blazingsql/runtime/bin/blazingsql', 'blazingsql/runtime/bin/pyblazing']
)

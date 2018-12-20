#!/bin/bash

blazingsql_files_tar_gz_path=$1
#TODO percy make this easy to use in local (avoid hardcode)
conda_recipes_dir=/home/jupyter/recipes/
output_dir=$2

source activate user

blazingsql_dir=$output_dir/blazingsql
blazingsql_pkg=$blazingsql_dir/blazingsql

working_directory=$PWD

temp_dir=/tmp
blazingsql_files_dir_name=blazingsql-files
working_space_name=_safe_to_remove_
working_space=/tmp/"$blazingsql_files_dir_name$working_space_name"
blazingsql_files_dir=$working_space/$blazingsql_files_dir_name

mkdir -p $working_space

echo "Decompressing blazingsql-files.tar.gz ..."
# TODO percy uncomment this when finish this script
tar xf $blazingsql_files_tar_gz_path -C $working_space
echo "blazingsql-files.tar.gz was decompressed at $working_space"

# Creating the blazingsql python package using the template
mkdir -p $blazingsql_pkg
cp -r blazingsql-template/* $blazingsql_dir

# Copy the binaries
mkdir -p $blazingsql_dir/cudf
mkdir -p $blazingsql_pkg/blazingdb
mkdir -p $blazingsql_pkg/pyblazing
mkdir -p $blazingsql_pkg/runtime/bin
mkdir -p $blazingsql_pkg/runtime/lib

blazingdb_ral_artifact_name=testing-libgdf
blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
blazingdb_calcite_artifact_name=BlazingCalcite.jar

cp $blazingsql_files_dir/$blazingdb_ral_artifact_name $blazingsql_pkg/runtime/bin
cp $blazingsql_files_dir/$blazingdb_orchestrator_artifact_name $blazingsql_pkg/runtime/bin
cp $blazingsql_files_dir/$blazingdb_calcite_artifact_name $blazingsql_pkg/runtime/bin

chmod +x $blazingsql_pkg/runtime/bin/*

# Copy the blazingdb-protocol/python and pyblazing
cp -r $blazingsql_files_dir/blazingdb-protocol/python/blazingdb/* $blazingsql_pkg/blazingdb
cp -r $blazingsql_files_dir/pyBlazing/pyblazing/* $blazingsql_pkg/pyblazing

# Copy cudf and change cudf* names to blazingdb_cudf* 
cp -r $blazingsql_files_dir/cudf/* $blazingsql_dir/cudf

# NOTE This is super important: the lines creates the folder to build & install libgdf_cffi & librmm_cffi
mkdir -p $blazingsql_dir/cudf/cpp/build/python
cp -r $blazingsql_files_dir/cudf/cpp/python/* $blazingsql_dir/cudf/cpp/build/python

# Copy cudf libs into the runtime
cp -r $blazingsql_files_dir/cudf/cpp/install/lib/* $blazingsql_pkg/runtime/lib

chmod +x $blazingsql_pkg/runtime/lib/*

# Compress the python package
cd $output_dir
echo "Compress the python package ..."
tar zcf blazingsql.tar.gz blazingsql
echo "$output_dir/blazingsql.tar.gz python package is ready!"

#cd $blazingsql_dir
#pip install -v .

# Generate the conda package
cd $conda_recipes_dir
FILE_TAR=/home/jupyter/output/blazingsql.tar.gz conda build --no-test --debug blazingsql
cp $HOME/.conda/envs/user/conda-bld/linux-64/blazingsql-1.0-py35_0.tar.bz2 /home/jupyter/output

#conda install --offline /full/path/to/my_package-....tar.bz2

#anaconda upload blazingsql-0.1-py35_0.tar.bz2

cd $working_directory
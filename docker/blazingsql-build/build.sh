#!/bin/bash

workspace_dir=/home/builder/workspace

working_directory=$PWD
blazingsql_build_properties=blazingsql-build.properties

cd $workspace_dir

# Clean the FAILED file (in case exists)
rm -rf FAILED 

# Load the build properties file
source $blazingsql_build_properties

#BEGIN check mandatory arguments

if [ -z "$cudf_branch" ]; then
    echo "Error: Need the 'cudf_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$blazingdb_protocol_branch" ]; then
    echo "Error: Need the 'blazingdb_protocol_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$blazingdb_ral_branch" ]; then
    echo "Error: Need the 'blazingdb_ral_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$blazingdb_orchestrator_branch" ]; then
    echo "Error: Need the 'blazingdb_orchestrator_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$blazingdb_calcite_branch" ]; then
    echo "Error: Need the 'blazingdb_calcite_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$pyblazing_branch" ]; then
    echo "Error: Need the 'pyblazing_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

#END check mandatory arguments

#BEGIN set default optional arguments for parallel build

if [ -z "$cudf_parallel" ]; then
    cudf_parallel=4
fi

if [ -z "$blazingdb_protocol_parallel" ]; then
    blazingdb_protocol_parallel=4
fi

if [ -z "$blazingdb_ral_parallel" ]; then
    blazingdb_ral_parallel=4
fi

if [ -z "$blazingdb_orchestrator_parallel" ]; then
    blazingdb_orchestrator_parallel=4
fi

if [ -z "$blazingdb_calcite_parallel" ]; then
    blazingdb_calcite_parallel=4
fi

#END set default optional arguments for parallel build

#BEGIN set default optional arguments for tests

if [ -z "$cudf_tests" ]; then
    cudf_tests=false
fi

if [ -z "$blazingdb_protocol_tests" ]; then
    blazingdb_protocol_tests=false
fi

if [ -z "$blazingdb_ral_tests" ]; then
    blazingdb_ral_tests=false
fi

if [ -z "$blazingdb_orchestrator_tests" ]; then
    blazingdb_orchestrator_tests=false
fi

if [ -z "$blazingdb_calcite_tests" ]; then
    blazingdb_calcite_tests=false
fi

if [ -z "$pyblazing_tests" ]; then
    pyblazing_tests=false
fi

#END set default optional arguments for tests

#BEGIN functions

#usage: replace_str "hi jack :)" "jack" "mike" ... result "hi mike :)" 
function replace_str() {
    input=$1
    replace=$2
    with=$3
    result=${input/${replace}/${with}}
    echo $result
}

# converts string feature/branchx to feature_branchx
function normalize_branch_name() {
    branch_name=$1
    result=$(replace_str $branch_name "/" "_")
    echo $result
}

#END functions

#BEGIN main

cudf_branch_name=$(normalize_branch_name $cudf_branch)
blazingdb_protocol_branch_name=$(normalize_branch_name $blazingdb_protocol_branch)
blazingdb_ral_branch_name=$(normalize_branch_name $blazingdb_ral_branch)
blazingdb_orchestrator_branch_name=$(normalize_branch_name $blazingdb_orchestrator_branch)
blazingdb_calcite_branch_name=$(normalize_branch_name $blazingdb_calcite_branch)
pyblazing_branch_name=$(normalize_branch_name $pyblazing_branch)

cd $workspace_dir

if [ ! -d dependencies ]; then
    mkdir dependencies
fi

#BEGIN nvstrings

cd dependencies

nvstrings_package=nvstrings-0.0.3-cuda9.2_py35_0
nvstrings_url=https://anaconda.org/nvidia/nvstrings/0.0.3/download/linux-64/"$nvstrings_package".tar.bz2

if [ ! -d $nvstrings_package ]; then
    wget $nvstrings_url
    mkdir $nvstrings_package
    tar xvf "$nvstrings_package".tar.bz2 -C $nvstrings_package
fi

nvstrings_install_dir=$workspace_dir/dependencies/$nvstrings_package

#END nvstrings

#BEGIN cudf

cd $workspace_dir

if [ ! -d cudf_project ]; then
    mkdir cudf_project
fi

cudf_project_dir=$workspace_dir/cudf_project

cd $cudf_project_dir

if [ ! -d $cudf_branch_name ]; then
    mkdir $cudf_branch_name
    cd $cudf_branch_name
    git clone git@github.com:BlazingDB/cudf.git
    cd cudf
    git checkout $cudf_branch
fi

cudf_current_dir=$cudf_project_dir/$cudf_branch_name/

cd $cudf_current_dir/cudf
git submodule update --init --recursive
git pull

libgdf_install_dir=$cudf_current_dir/install

#TODO change this to cpp for cudf >= 0.3.0
libgdf_dir=libgdf
cd $libgdf_dir

if [ ! -d build ]; then
    mkdir build
    cd build
    NVSTRINGS_ROOT=$nvstrings_install_dir cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$libgdf_install_dir ..
fi

cd $cudf_current_dir/cudf/$libgdf_dir/build/
NVSTRINGS_ROOT=$nvstrings_install_dir cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$libgdf_install_dir ..
make -j$cudf_parallel install

#END cudf

#BEGIN blazingdb-protocol

cd $workspace_dir

if [ ! -d blazingdb-protocol_project ]; then
    mkdir blazingdb-protocol_project
fi

blazingdb_protocol_project_dir=$workspace_dir/blazingdb-protocol_project

cd $blazingdb_protocol_project_dir

if [ ! -d $blazingdb_protocol_branch_name ]; then
    mkdir $blazingdb_protocol_branch_name
    cd $blazingdb_protocol_branch_name
    git clone git@github.com:BlazingDB/blazingdb-protocol.git
    cd blazingdb-protocol
    git checkout $blazingdb_protocol_branch
fi

blazingdb_protocol_current_dir=$blazingdb_protocol_project_dir/$blazingdb_protocol_branch_name/

cd $blazingdb_protocol_current_dir/blazingdb-protocol
git pull

cd cpp

blazingdb_protocol_install_dir=$blazingdb_protocol_current_dir/install

if [ ! -d build ]; then
    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$blazingdb_protocol_install_dir ..
fi

cd $blazingdb_protocol_current_dir/blazingdb-protocol/cpp/build/
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$blazingdb_protocol_install_dir ..
make -j$blazingdb_protocol_parallel install

cd $blazingdb_protocol_current_dir/blazingdb-protocol/java
mvn clean install -Dmaven.test.skip=true

#END blazingdb-protocol

#BEGIN blazingdb-ral

cd $workspace_dir

if [ ! -d blazingdb-ral_project ]; then
    mkdir blazingdb-ral_project
fi

blazingdb_ral_project_dir=$workspace_dir/blazingdb-ral_project

cd $blazingdb_ral_project_dir

if [ ! -d $blazingdb_ral_branch_name ]; then
    mkdir $blazingdb_ral_branch_name
    cd $blazingdb_ral_branch_name
    git clone git@github.com:BlazingDB/blazingdb-ral.git
    cd blazingdb-ral
    git checkout $blazingdb_ral_branch
fi

blazingdb_ral_current_dir=$blazingdb_ral_project_dir/$blazingdb_ral_branch_name/

cd $blazingdb_ral_current_dir/blazingdb-ral
git submodule update --init --recursive
git pull

blazingdb_ral_install_dir=$blazingdb_ral_current_dir/install

if [ ! -d build ]; then
    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DNVSTRINGS_HOME=$nvstrings_install_dir -DLIBGDF_HOME=$libgdf_install_dir -DBLAZINGDB_PROTOCOL_HOME=$blazingdb_protocol_install_dir ..
fi

cd $blazingdb_ral_current_dir/blazingdb-ral/build/
cmake -DCMAKE_BUILD_TYPE=Release -DNVSTRINGS_HOME=$nvstrings_install_dir -DLIBGDF_HOME=$libgdf_install_dir -DBLAZINGDB_PROTOCOL_HOME=$blazingdb_protocol_install_dir ..
make -j$blazingdb_ral_parallel

#END blazingdb-ral

#BEGIN blazingdb-orchestrator

cd $workspace_dir

if [ ! -d blazingdb-orchestrator_project ]; then
    mkdir blazingdb-orchestrator_project
fi

blazingdb_orchestrator_project_dir=$workspace_dir/blazingdb-orchestrator_project

cd $blazingdb_orchestrator_project_dir

if [ ! -d $blazingdb_orchestrator_branch_name ]; then
    mkdir $blazingdb_orchestrator_branch_name
    cd $blazingdb_orchestrator_branch_name
    git clone git@github.com:BlazingDB/blazingdb-orchestrator.git
    cd blazingdb-orchestrator
    git checkout $blazingdb_orchestrator_branch
fi

blazingdb_orchestrator_current_dir=$blazingdb_orchestrator_project_dir/$blazingdb_orchestrator_branch_name/

cd $blazingdb_orchestrator_current_dir/blazingdb-orchestrator
git pull

blazingdb_orchestrator_install_dir=$blazingdb_orchestrator_current_dir/install

if [ ! -d build ]; then
    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DBLAZINGDB_PROTOCOL_HOME=$blazingdb_protocol_install_dir ..
fi

cd $blazingdb_orchestrator_current_dir/blazingdb-orchestrator/build/
cmake -DCMAKE_BUILD_TYPE=Release -DBLAZINGDB_PROTOCOL_HOME=$blazingdb_protocol_install_dir ..
make -j$blazingdb_orchestrator_parallel

#END blazingdb-orchestrator

echo "alla"



cd $working_directory

#END main

exit


# this function build the stack
function build_blazingsql() {
	



    cd ${workspace}

    # cudf
    if [ -d cudf ]; then
    fi

    git clone git@github.com:BlazingDB/cudf.git
    cd cudf
    git checkout develop

    # blazingdb-protocol
    git clone git@github.com:BlazingDB/blazingdb-protocol.git
    cd ${workspace}/blazingdb-protocol && git checkout develop
    cd ${workspace}/blazingdb-protocol/java && mvn clean install

    # blazingdb-ral
    cd ${workspace}
    git clone git@github.com:BlazingDB/blazingdb-ral.git
    cd  ${workspace}/blazingdb-ral && git checkout develop
    mkdir ${workspace}/blazingdb-ral/build && cd ${workspace}/blazingdb-ral/build
    cmake .. && make

    # blazingdb-orchestrator
    cd ${workspace}
    git clone git@github.com:BlazingDB/blazingdb-orchestrator.git
    cd  ${workspace}/blazingdb-orchestrator && git checkout develop
    mkdir ${workspace}/blazingdb-orchestrator/build && cd ${workspace}/blazingdb-orchestrator/build
    cmake .. && make -j8

    # blazingdb-calcite
    cd ${workspace}
    git clone git@github.com:BlazingDB/blazingdb-calcite.git
    cd ${workspace}/blazingdb-calcite && git checkout develop
    mvn clean install -Dmaven.test.skip=true

    # PyBlazing
    cd ${workspace}
    git clone git@github.com:BlazingDB/pyBlazing.git
    cd ${workspace}/pyBlazing && git checkout develop
    
    
}

function zip_cpp_project() {
    workspace=$1
    output=$2
    project=$3
    binary=$4

    if [ -f $workspace/$project/build/$binary ]; then
        cp $workspace/$project/build/$binary $output
    elif [ -f $workspace/$project/$binary ]; then # in-source build cmake (e.g. eclipse generator)
        cp $workspace/$project/$binary $output
    else
        echo "Could not find $project/$binary, please check again!"
        exit 1
    fi
}

# this function just read the content of /home/builder/src and copy the binary files
function zip_files() {
    workspace=/home/builder/src
    output=/home/builder/output/blazingsql-files

    mkdir -p ${output}/libgdf_cffi
    mkdir -p ${output}/blazingdb-protocol/python/

    # Package blazingdb-ral
    zip_cpp_project $workspace $output "blazingdb-ral" "testing-libgdf"

    #TODO fix cmake files, build first libgdf and bz-protocol then pass the paths
    # Package libgdf and libgdf_cffi from blazingdb-ral
    build_directory="build"
    if [ -f $workspace/blazingdb-ral/CMakeFiles/thirdparty/libgdf-install/lib/libgdf.so ]; then
        build_directory=""
    fi
    cp -r $workspace/blazingdb-ral/$build_directory/CMakeFiles/thirdparty/libgdf-src/libgdf/python/* $output/libgdf_cffi/
    cp -r $workspace/blazingdb-ral/$build_directory/CMakeFiles/thirdparty/libgdf-install/* $output/libgdf_cffi/
    cp -r $workspace/blazingdb-ral/$build_directory/CMakeFiles/thirdparty/libgdf-src/libgdf/include/*.h $output/libgdf_cffi/include/
    rm -rf $output/libgdf_cffi/lib/libgdf.a

    # Package blazingdb-orchestrator
    zip_cpp_project $workspace $output "blazingdb-orchestrator" "blazingdb_orchestator_service"

    # Package blazingdb-calcite
    cp $workspace/blazingdb-calcite/blazingdb-calcite-application/target/BlazingCalcite.jar ${output}

    # Package blazingdb-protocol/python
    cp -r $workspace/blazingdb-protocol/python/* $output/blazingdb-protocol/python/

    # Package PyBlazing
    echo "### PyBlazing ###"
    cp -r $workspace/pyBlazing/ ${output}/
    rm -rf ${output}/pyBlazing/.git/

    # Cudf
    echo "### Cudf ###"
    mkdir -p ${workspace}/cudf/conda-recipes/cudf/ && \
    cp -r ${workspace}/cudf/ ${output}/
    rm -rf ${output}/cudf/.git/

    # compress files and delete temp folder
    cd /home/builder/output/ && tar czvf blazingsql-files.tar.gz blazingsql-files/
    rm -rf ${output}
}

#BEGIN MAIN

# if the user did'nt mount /home/builder/src then build inside the container
if [ -z "$(ls -A /home/builder/src)" ]; then
    build_blazingsql
    zip_files
else
    zip_files
fi

#END MAIN

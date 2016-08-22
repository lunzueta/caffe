@echo off

:: Set python 2.7 with conda as the default python
set PATH=C:\Miniconda-x64;C:\Miniconda-x64\Scripts;C:\Miniconda-x64\Library\bin;%PATH%
:: Check that we have the right python version
python --version
:: Add the required channels
conda config --add channels conda-forge
conda config --add channels willyd
:: Update conda
conda update conda -y
:: Create an environment
conda create -n caffe --yes caffe-build-dependencies cmake ninja
:: Activate the environement
call activate caffe

:: Call this script to set the right cmake variables
call set_cmake_vars

:: Create build directory and configure cmake
mkdir build
pushd build
:: Setup the environement for VS 2013 x64
call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" amd64
cmake -GNinja ^
      -DBLAS=Open ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DBUILD_SHARED_LIBS=OFF ^
      -DCMAKE_MODULE_PATH=%CMAKE_MODULE_PATH% ^
      -DCMAKE_PREFIX_PATH=%CMAKE_PREFIX_PATH% ^
      ..\

:: Build the library and tools
cmake --build .

:: Build and exectute the tests
cmake --build . --target runtest

:: Lint
cmake --build . --target lint
popd
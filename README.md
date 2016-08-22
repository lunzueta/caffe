# Windows Caffe

**This is an experimental, Microsoft-led branch by Pavle Josipovic (@pavlejosipovic). It is a work-in-progress.**

This branch of Caffe ports the framework to Windows.

[![Travis Build Status](https://api.travis-ci.org/BVLC/caffe.svg?branch=windows)](https://travis-ci.org/BVLC/caffe) Travis (Linux build)

[![Build status](https://ci.appveyor.com/api/projects/status/128eg95svel2a2xs?svg=true)]
(https://ci.appveyor.com/project/pavlejosipovic/caffe-v45qi) AppVeyor (Windows build)

[![Windows CMake Build status](https://ci.appveyor.com/api/projects/status/lc0pdvlv89a9i9ae?svg=true)](https://ci.appveyor.com/project/willyd/caffe) AppVeyor (Windows CMake build)


## Windows Setup (with CMake)
**Requirements**:
 - Visual Studio 2013
 - CMake 3.4+
 - Python 2.7 Anaconda x64 (or Miniconda)

### Install caffe dependencies

This cmake build relies on the `conda` package manager to retreive the dependencies. First you should configure conda to use non default channels to retreive packages:
```
> conda config --add channels conda-forge
> conda config --add channels willyd
```
Now update conda to have at least conda 4.1.11:
```
> conda update conda --yes
```
and install the caffe build dependencies in a new environment:
```
> conda create -n caffe caffe-build-dependencies
```
and activate it:
```
> activate caffe
```
you can also choose to install the `caffe-dependencies` meta package instead of `caffe-build-dependencies` to get other required runtime dependencies such `h5py`, `python-leveldb`, etc.

### TODO

CPU_ONLY, cuda, nocuda, cuDNN.

### Build caffe

Setup the msvc compiler using:
```
> "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" amd64
```
Setup cmake variables based on your active environment:
```
> set_cmake_vars
```
Configure using CMake:
```
> mkdir build
> cd build
> cmake -GNinja -DBLAS=Open -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_MODULE_PATH=%CMAKE_MODULE_PATH% -DCMAKE_PREFIX_PATH=%CMAKE_PREFIX_PATH% -DCMAKE_INSTALL_PREFIX=<install_path> ..\
> ninja
> ninja install
```
It is also possible to use the `Visual Studio 12 2013 Win64` generator instead of the `Ninja generator`. Please note however that Visual Studio will not parallelize the build of the CUDA files which results in much longer build times.

### Building a shared library

CMake can be used to build a shared library instead of the default static library. To do so follow the above procedure and use `-DBUILD_SHARED_LIBS=ON`. Please note however, that some tests (more specifically the solver related tests) will fail since both the test exectuable and caffe library do not share static objects contained in the protobuf library.


## Windows Setup (without CMake)
**Requirements**: Visual Studio 2013

### Pre-Build Steps
Copy `.\windows\CommonSettings.props.example` to `.\windows\CommonSettings.props`

By defaults Windows build requires `CUDA` and `cuDNN` libraries.
Both can be disabled by adjusting build variables in `.\windows\CommonSettings.props`.
Python support is disabled by default, but can be enabled via `.\windows\CommonSettings.props` as well.
3rd party dependencies required by Caffe are automatically resolved via NuGet.

### CUDA
Download `CUDA Toolkit 7.5` [from nVidia website](https://developer.nvidia.com/cuda-toolkit).
If you don't have CUDA installed, you can experiment with CPU_ONLY build.
In `.\windows\CommonSettings.props` set `CpuOnlyBuild` to `true` and set `UseCuDNN` to `false`.

### cuDNN
Download `cuDNN v3` or `cuDNN v4` [from nVidia website](https://developer.nvidia.com/cudnn).
Unpack downloaded zip to %CUDA_PATH% (environment variable set by CUDA installer).
Alternatively, you can unpack zip to any location and set `CuDnnPath` to point to this location in `.\windows\CommonSettings.props`.
`CuDnnPath` defined in `.\windows\CommonSettings.props`.
Also, you can disable cuDNN by setting `UseCuDNN` to `false` in the property file.

### Python
To build Caffe Python wrapper set `PythonSupport` to `true` in `.\windows\CommonSettings.props`.
Download Miniconda 2.7 64-bit Windows installer [from Miniconda website] (http://conda.pydata.org/miniconda.html).
Install for all users and add Python to PATH (through installer).

Run the following commands from elevated command prompt:

```
conda install --yes numpy scipy matplotlib scikit-image pip
pip install protobuf
```

#### Remark
After you have built solution with Python support, in order to use it you have to either:
* set `PythonPath` environment variable to point to `<caffe_root>\Build\x64\Release\pycaffe`, or
* copy folder `<caffe_root>\Build\x64\Release\pycaffe\caffe` under `<python_root>\lib\site-packages`.

### Matlab
To build Caffe Matlab wrapper set `MatlabSupport` to `true` and `MatlabDir` to the root of your Matlab installation in `.\windows\CommonSettings.props`.

#### Remark
After you have built solution with Matlab support, in order to use it you have to:
* add the generated `matcaffe` folder to Matlab search path, and
* add `<caffe_root>\Build\x64\Release` to your system path.

### Build
Now, you should be able to build `.\windows\Caffe.sln`





## Further Details

Refer to the BVLC/caffe master branch README for all other details such as license, citation, and so on.

# Windows Caffe

This branch of Caffe is a fusion between the CMake-based [willyd-led Caffe](https://github.com/willyd/caffe) and [Microsoft-led Caffe](https://github.com/microsoft/caffe) for Windows, which extends [BVLC-led Caffe](https://github.com/BVLC/caffe) by adding Windows support and other functionalities commonly used by Microsoft's researchers, such as managed-code wrapper, [Faster-RCNN](https://papers.nips.cc/paper/5638-faster-r-cnn-towards-real-time-object-detection-with-region-proposal-networks.pdf), [R-FCN](https://arxiv.org/pdf/1605.06409v2.pdf), etc. Additionally, this branch contains other functionalities available in other Caffe forks, such as [DetectNet](https://github.com/NVIDIA/DIGITS/tree/master/examples/object-detection) from [NVIDIA-led Caffe](https://github.com/NVIDIA/caffe).

## Windows Setup
**Requirements**:
 - Visual Studio 2013
 - CMake 3.4+
 - Python 2.7 Anaconda x64 (or Miniconda)

you may also like to try the [ninja](https://ninja-build.org/) cmake generator as the build times can be much lower on multi-core machines. ninja can be installed easily with the `conda` package manager by adding the conda-forge channel with:
```cmd
> conda config --add channels conda-forge
> conda install ninja --yes
```
When working with ninja you don't have the Visual Studio solutions as ninja is more akin to make. An alternative is to use [Visual Studio Code](https://code.visualstudio.com) with the CMake extensions and C++ extensions.

### Install the caffe dependencies

The easiest and recommended way of installing the required depedencies is by downloading the pre-built libraries using the `%CAFFE_ROOT%\scripts\download_prebuilt_dependencies.py` file. The following command should download and extract the prebuilt dependencies to your current working directory:

```cmd
> python scripts\download_prebuilt_dependencies.py
```

This will create a folder called `libraries` containing all the required dependencies. Alternatively you can build them yourself by following the instructions in the [caffe-builder](https://github.com/willyd/caffe-builder) [README](https://github.com/willyd/caffe-builder/blob/master/README.md). For the remaining of these instructions we will assume that the libraries folder is in a folder defined by the `%CAFFE_DEPENDENCIES%` environment variable.

### Build caffe

If you are using the Ninja generator you need to setup the MSVC compiler using:
```
> call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" amd64
```
then from the caffe source folder you need to configure the cmake build
```
> set CMAKE_GENERATOR=Ninja
> set CMAKE_CONFIGURATION=Release
> mkdir build
> cd build
> cmake -G%CMAKE_GENERATOR% -DBLAS=Open -DCMAKE_BUILD_TYPE=%CMAKE_CONFIGURATION% -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=<install_path> -C %CAFFE_DEPENDENCIES%\caffe-builder-config.cmake  ..\
> cmake --build . --config %CMAKE_CONFIGURATION%
> cmake --build . --config %CMAKE_CONFIGURATION% --target install
```
In the above command `CMAKE_GENERATOR` can be either `Ninja` or `"Visual Studio 12 2013 Win64"` and `CMAKE_CONFIGURATION` can be `Release` or `Debug`. Please note however that Visual Studio will not parallelize the build of the CUDA files which results in much longer build times.

In case on step in the above procedure is not working please refer to the appveyor build scripts in `%CAFFE_ROOT%\scripts\appveyor` to see the most up to date build procedure.

### Use cuDNN

To use cuDNN you need to define the CUDNN_ROOT cache variable to point to where you unpacked the cuDNN files. For example, the build command above would become:

```
> set CMAKE_GENERATOR=Ninja
> set CMAKE_CONFIGURATION=Release
> mkdir build
> cd build
> cmake -G%CMAKE_GENERATOR% -DBLAS=Open -DCMAKE_BUILD_TYPE=%CMAKE_CONFIGURATION% -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=<install_path> -DCUDNNROOT=<path_to_cudnn> -C %CAFFE_DEPENDENCIES%\caffe-builder-config.cmake  ..\
> cmake --build . --config %CMAKE_CONFIGURATION%
> cmake
```
Make sure to use forward slashes (`/`) in the path. You will need to add the folder containing the cuddn DLL to your PATH.

### Building only for CPU

If CUDA is not installed Caffe will default to a CPU_ONLY build. If you have CUDA installed but want a CPU only build you maybe use the CMake option `-DCPU_ONLY=1`.

### Using the Python interface

If Python is installed the default is to build the python interface and python layers. If you wish to disable the python layers or the python build use the CMake options `-DBUILD_python_layer=0` and `-DBUILD_python=0` respectively. In order to use the python interface you need to either add the `%CAFFE_ROOT%\python` folder to your python path of copy the `%CAFFE_ROOT%\python\caffe` folder to your `site_packages` folder. Also, you need to edit your `PATH` or copy the required DLLs next to the `caffe.pyd` file.

### Using the MATLAB interface

TODO

### Building a shared library

CMake can be used to build a shared library instead of the default static library. To do so follow the above procedure and use `-DBUILD_SHARED_LIBS=ON`. Please note however, that some tests (more specifically the solver related tests) will fail since both the test exectuable and caffe library do not share static objects contained in the protobuf library.

### Running the tests or the caffe exectuable

To run the tests or any caffe exectuable you will have to update your `PATH` to include the directories where the depedencies dlls are located:
```
:: Prepend to avoid conflicts with other libraries with same name
> set PATH=%CAFFE_DEPENDENCIES%\bin;%CAFFE_DEPENDENCIES%\lib;%CAFFE_DEPENDENCIES%\x64\vc12\bin;%PATH%
```
then the tests can be run from the build folder:
```
cmake --build . --target runtest --config %CMAKE_CONFIGURATION%
```

### TODOs
- Visual Studio 2015

## Previous Visual Studio based build

The previous windows build based on Visual Studio project files is now deprecated. However, it is still available in the `windows` folder. Please see the `README.md` in there for details.

## Known issues

- The `GPUTimer` related test cases always fail on Windows. This seems to be a difference between UNIX and Windows.
- Shared library (DLL) build will have failing tests.

## Further Details

Refer to the BVLC/caffe master branch README for all other details such as license, citation, and so on.

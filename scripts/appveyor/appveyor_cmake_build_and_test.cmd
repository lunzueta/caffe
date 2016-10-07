@echo off

:: Set python 2.7 with conda as the default python
set PATH=C:\Miniconda-x64;C:\Miniconda-x64\Scripts;C:\Miniconda-x64\Library\bin;%PATH%
:: Check that we have the right python version
python --version
:: Add the required channels
conda config --add channels conda-forge
:: Update conda
conda update conda -y
:: Create an environment
conda install --yes cmake ninja numpy

:: Create build directory and configure cmake
mkdir build
pushd build
:: Download dependencies from VS 2013 x64
python ..\scripts\download_model_binary.py --msvc_version v120
:: Add the dependencies to the PATH
set PATH=%PATH%;%cd%\libraries\bin;%cd%\libraries\lib;%cd%\libraries\x64\vc12\bin
:: Setup the environement for VS 2013 x64
call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" amd64
:: Configure using cmake and using the caffe-builder dependencies
cmake -G"%CMAKE_GENERATOR%" ^
      -DBLAS=Open ^
      -DCMAKE_BUILD_TYPE=%CMAKE_CONFIG% ^
      -DBUILD_SHARED_LIBS=%CMAKE_BUILD_SHARED_LIBS% ^
      -C libraries\caffe-builder-config.cmake
      ..\

:: Build the library and tools
cmake --build . --config %CMAKE_CONFIG%

if ERRORLEVEL 1 (
  echo Build failed
  exit /b 1
)

:: Build and exectute the tests
if "%CMAKE_BUILD_SHARED_LIBS%"=="OFF" (
  :: Run the tests only for static lib as the shared lib is causing an issue.
  cmake --build . --target runtest --config %CMAKE_CONFIG%

  if ERRORLEVEL 1 (
    echo Tests failed
    exit /b 1
  )
)

:: Lint
cmake --build . --target lint  --config %CMAKE_CONFIG%

if ERRORLEVEL 1 (
  echo Lint failed
  exit /b 1
)

popd
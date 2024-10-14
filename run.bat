set BUILD_MODE=%1
set BUILD_START_DIR=%CD%

@REM 2024.10.14，已安装 python 3.9.13， MinGW 12.2.0
@REM echo 环境变量：%PATH%
@REM echo 当前路径：%CD%

@REM 参数配置
set INSTALL_PREFIX=D:\Dev
set _qt_major_ver=6.8
set _qt_minor_ver=0
set _cmake_ver=3.30.5

@REM 各个路径
set _qt_ver=%_qt_major_ver%.%_qt_minor_ver%
set _pkgfn=qt-everywhere-src-%_qtver%

set LLVM_DIR=%BUILD_START_DIR%\llvm-project
set CLAZY_SRC=%BUILD_START_DIR%\clazy

set QT_BASE_DIR=%INSTALL_PREFIX%\Qt
set QT_INSTALL_DIR=%QT_BASE_DIR%\%_qt_ver%\qt
set CLANG_INSTALL_DIR=%INSTALL_PREFIX%\libclang

: clazy安装目录与clang相同
set CLAZY_INSTALL_DIR=%CLANG_INSTALL_DIR%

@REM cd \
@REM mkdir bb 
set ROOT=%BUILD_START_DIR%
set QT_SRC=%ROOT%\qt-everywhere-src-%QT_VER%

@REM 下载7zr用于解压7z安装包
curl -L -o 7zr.exe https://www.7-zip.org/a/7zr.exe
curl -L -o 7zip.exe https://www.7-zip.org/a/7z2408-x64.exe
@REM 下载cmake、ninja、qt、perl和MinGW
curl -L -o cmake.zip https://github.com/Kitware/CMake/releases/download/v%_cmake_ver%/cmake-%_cmake_ver%-windows-x86_64.zip
curl -L -o ninja-win.zip https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-win.zip
curl -L -o "%_pkgfn%.tar.xz" "https://download.qt.io/official_releases/qt/%_qt_major_ver%/%_qtver%/single/%_pkgfn%.tar.xz"
curl -L -o strawberry-perl.zip https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54001_64bit_UCRT/strawberry-perl-5.40.0.1-64bit-portable.zip
@REM curl -L -o openssl-3.tar.gz "https://github.com/openssl/openssl/releases/download/openssl-3.3.2/openssl-3.3.2.tar.gz"
@REM curl -L -o MingW.7z https://github.com/niXman/mingw-builds-binaries/releases/download/14.2.0-rt_v12-rev0/x86_64-14.2.0-release-posix-seh-ucrt-rt_v12-rev0.7z

curl -L -o openssl.7z https://github.com/njuFerret/qt-mingw64/releases/download/build_tools/openssl_3.3.2_mingw-x86_64-13.1.7z
curl -L -o MinGW.7z https://github.com/njuFerret/qt-mingw64/releases/download/build_tools/MinGW-x86_64-13.1.0-release-posix-seh-ucrt-rt_v11-rev1.7z

@REM @REM 下载LLVM
@REM git clone https://github.com/llvm/llvm-project

@REM cd \
@REM mkdir Dev
@REM cd Dev
@REM echo 当前路径：%CD%

@REM python -V
@REM g++ -v

@REM cmake解压后根目录为文件名, 类似 cmake-3.30.5-windows-x86_64
@REM ninja-win为单文件, 需要创建文件夹, 这里创建ninja文件夹
@REM MinGW解压后根目录为 mingw64 


7zr x 7zip.exe -o7zip
7z x cmake.zip
7z x ninja-win.zip -oninja
7z x MingW.7z
7z x openssl.7z -o%QT_BASE_DIR%

@REM echo %PATH%
@REM 7z x "%_pkgfn%.tar.xz"

set PATH=%ROOT%7zip;%ROOT%cmake-%_cmake_ver%-windows-x86_64\bin;%ROOT%ninja;%ROOT%mingw64\bin;%PATH%

git clone https://github.com/llvm/llvm-project %LLVM_DIR%
cd %LLVM_DIR%
git checkout llvmorg-19.1.1

cd %BUILD_START_DIR%
git clone https://github.com/KDE/clazy %CLAZY_SRC%
cd %CLAZY_SRC%
git checkout v1.12

cd %BUILD_START_DIR%

@REM 编译clang
@REM : libclang配置为静态库，启用clang和clang-tools-extra（包含clangd和clang-tidy），不包括zlib
cmake -GNinja -DBUILD_SHARED_LIBS:BOOL=OFF -DLIBCLANG_BUILD_STATIC:BOOL=ON -DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%CLANG_INSTALL_DIR% %LLVM_DIR%/llvm -B%LLVM_DIR%/build
@REM : 编译
cmake --build %LLVM_DIR%/build --parallel 
@REM : 安装
cmake --build %LLVM_DIR%/build --parallel --target install  

@REM 编译clazy
cmake -DCMAKE_INSTALL_PREFIX=%CLAZY_INSTALL_DIR% -DCLANG_LIBRARY_IMPORT="%CLANG_INSTALL_DIR%/lib/libclang.a" -DCMAKE_BUILD_TYPE=Release -G "Ninja" -B"%CLAZY_SRC%"/build" -S"%CLAZY_SRC%"
cmake --build "%CLAZY_SRC%/build" --parallel
cmake --build "%CLAZY_SRC%/build" --parallel --target install


@REM @REM 测试各个工具
@REM cmake --version
@REM ninja --version
@REM g++ --version
cd %CLANG_INSTALL_DIR%\bin
clang-format --version



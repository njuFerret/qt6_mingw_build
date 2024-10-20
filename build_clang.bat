set _llvm_ver=%1
set mingw=%2
set BUILD_MODE=%3
set BUILD_START_DIR=%CD%

@REM 2024.10.14，已安装 python 3.9.13， MinGW 12.2.0
@REM echo 环境变量：%PATH%
@REM echo 当前路径：%CD%

@REM 参数配置
set INSTALL_PREFIX=D:\Dev
@REM set _qt_major_ver=6.8
@REM set _qt_minor_ver=0
set _cmake_ver=3.30.5
@REM set _llvm_ver=19.1.1
@REM set _clazy_tag_ver=v1.12
@REM set mingw=MinGW-x86_64-13.1.0-release-posix-seh-ucrt-rt_v11-rev1

@REM 各个路径
set _qt_ver=%_qt_major_ver%.%_qt_minor_ver%
set _pkgfn=qt-everywhere-src-%_qtver%
set _llvm_tag_ver=llvmorg-%_llvm_ver%

set LLVM_DIR=%BUILD_START_DIR%\llvm-project
@REM set CLAZY_SRC=%BUILD_START_DIR%\clazy

set QT_BASE_DIR=%INSTALL_PREFIX%\Qt
@REM set QT_INSTALL_DIR=%QT_BASE_DIR%\%_qt_ver%\qt
set CLANG_INSTALL_DIR=%INSTALL_PREFIX%\libclang

@REM : clazy安装目录与clang相同
@REM set CLAZY_INSTALL_DIR=%CLANG_INSTALL_DIR%

@REM cd \
@REM mkdir bb 
set ROOT=%BUILD_START_DIR%
@REM set QT_SRC=%ROOT%\qt-everywhere-src-%QT_VER%

@REM 下载7zr用于解压7z安装包
echo **********************    下载7zip    ****************************
curl -L -o 7zr.exe https://www.7-zip.org/a/7zr.exe
curl -L -o 7zip.exe https://www.7-zip.org/a/7z2408-x64.exe

@REM 下载cmake、ninja、qt、perl和MinGW
echo **********************    下载cmake v%_cmake_ver%   ****************************
curl -L -o cmake.zip https://github.com/Kitware/CMake/releases/download/v%_cmake_ver%/cmake-%_cmake_ver%-windows-x86_64.zip
echo **********************    下载ninja    ****************************
curl -L -o ninja-win.zip https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-win.zip
@REM curl -L -o "%_pkgfn%.tar.xz" "https://download.qt.io/official_releases/qt/%_qt_major_ver%/%_qtver%/single/%_pkgfn%.tar.xz"
echo ***********************    下载 perl ************************************
curl -L -o strawberry-perl.zip https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54001_64bit_UCRT/strawberry-perl-5.40.0.1-64bit-portable.zip
@REM curl -L -o openssl-3.tar.gz "https://github.com/openssl/openssl/releases/download/openssl-3.3.2/openssl-3.3.2.tar.gz"
@REM curl -L -o MingW.7z https://github.com/niXman/mingw-builds-binaries/releases/download/14.2.0-rt_v12-rev0/x86_64-14.2.0-release-posix-seh-ucrt-rt_v12-rev0.7z
echo **********************    下载openssl & MinGW    ****************************
curl -L -o openssl.7z https://github.com/njuFerret/qt6_mingw_build/releases/download/deps/openssl_3.3.2_mingw-x86_64-13.1.7z
curl -L -o MinGW.7z https://github.com/njuFerret/qt6_mingw_build/releases/download/deps/%mingw%.7z


@REM cmake解压后根目录为文件名, 类似 cmake-3.30.5-windows-x86_64
@REM ninja-win为单文件, 需要创建文件夹, 这里创建ninja文件夹
@REM MinGW解压后根目录为 mingw64 

echo **********************    解压7zip    ****************************
7zr x 7zip.exe -o7zip
echo **********************    解压cmake   ****************************
7z x cmake.zip
echo **********************    解压ninja   ****************************
7z x ninja-win.zip -oninja
echo **********************    解压MingW   ****************************
7z x MingW.7z
if exist %ROOT%\mingw64 (
    move %ROOT%\mingw64 %ROOT%\MinGW
)
echo **********************    解压openssl ****************************
7z x openssl.7z -o%QT_BASE_DIR%
echo **********************    解压完成    ****************************

@REM echo %PATH%
@REM 7z x "%_pkgfn%.tar.xz"

@REM set PATH=%ROOT%\7zip;%ROOT%\cmake-%_cmake_ver%-windows-x86_64\bin;%ROOT%\ninja;%ROOT%\mingw64\bin;%PATH%
set PATH=%ROOT%\7zip;%ROOT%\cmake-%_cmake_ver%-windows-x86_64\bin;%ROOT%\ninja;%ROOT%\MinGW\bin;%PATH%

echo **********************    g++ 版本信息   ****************************
g++ -v

echo ********************** 克隆 llvm-project ****************************
git clone https://github.com/llvm/llvm-project.git %LLVM_DIR%
cd %LLVM_DIR%
echo **********************切换当前版本为 %_llvm_tag_ver% ****************************
git checkout %_llvm_tag_ver%

curl -L -o clean_llvm_platform.patch https://github.com/njuFerret/qt6_mingw_build/releases/download/deps/clean_llvm_platform.patch
curl -L -o fix_shared_build.patch https://github.com/njuFerret/qt6_mingw_build/releases/download/deps/fix_shared_build.patch
echo ***************************** 开始应用补丁 *************************************
echo 应用补丁：
git apply clean_llvm_platform.patch
echo **********************  验证补丁是否已经应用 ****************************
git diff --stat

@REM echo ********************** 克隆 CLAZY ****************************
@REM cd %BUILD_START_DIR%
@REM git clone https://github.com/KDE/clazy.git %CLAZY_SRC%
@REM cd %CLAZY_SRC%
@REM echo **********************切换当前版本为 %_llvm_tag_ver% ****************************
@REM git checkout %_clazy_tag_ver%

cd %BUILD_START_DIR%

dir
set build_name=libclang-%_llvm_ver%-%mingw%_%BUILD_MODE%

@REM 编译clang
if "%BUILD_MODE%"=="static" (
    echo ********************** 编译 LLVM 静态库 ****************************
    @REM : libclang配置为静态库，启用clang和clang-tools-extra（包含clangd和clang-tidy），不包括zlib
    cmake -GNinja -DBUILD_SHARED_LIBS:BOOL=OFF -DLIBCLANG_BUILD_STATIC:BOOL=ON -DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%CLANG_INSTALL_DIR% %LLVM_DIR%/llvm -B%LLVM_DIR%/build
) else if "%BUILD_MODE%"=="shared" (
    echo ********************** 编译 LLVM 动态库 ****************************

    echo **********************   应用动态库补丁  *****************************    
    cd %LLVM_DIR%
    git apply fix_shared_build.patch
    echo **********************  动态库补丁是否已经应用 ****************************
    git diff --stat    
    cd %BUILD_START_DIR% 

    @REM 配置为动态库，启用clang和clang-tools-extra（包含clangd和clang-tidy）
    @REM @REM libclang 16.0.6编译通过，但19.1.2无法通过编译，这里直接关闭clang-tool-extra的test模块
    @REM cmake -GNinja -DBUILD_SHARED_LIBS:BOOL=ON -DLIBCLANG_LIBRARY_VERSION=%_llvm_ver% -DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%LLVM_INSTALL_DIR% %LLVM_DIR%/llvm -B%LLVM_DIR%/build
    cmake -GNinja -Wno-dev -Wno-deprecated -Wno-dangling-pointer -DBUILD_SHARED_LIBS:BOOL=ON -DCLANG_TOOLS_EXTRA_INCLUDE_DOCS:BOOL=OFF -DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%CLANG_INSTALL_DIR% %LLVM_DIR%/llvm -B%LLVM_DIR%/build
)
@REM : 编译
cmake --build %LLVM_DIR%/build --parallel 
@REM : 安装
cmake --build %LLVM_DIR%/build --parallel --target install  

@REM echo ********************** 编译 CLAZY  ****************************

@REM @REM 编译clazy
@REM cmake -DCMAKE_INSTALL_PREFIX=%CLAZY_INSTALL_DIR% -DCLANG_LIBRARY_IMPORT="%CLANG_INSTALL_DIR%/lib/libclang.a" -DCMAKE_BUILD_TYPE=Release -G "Ninja" -B"%CLAZY_SRC%"/build -S"%CLAZY_SRC%"
@REM cmake --build build --parallel
@REM cmake --build build --parallel --target install
MKDIR %CLANG_INSTALL_DIR%
echo. >  %CLANG_INSTALL_DIR%\%build_name%.txt
echo   ********************** libclang ver. %_llvm_ver% **************************** >>  %CLANG_INSTALL_DIR%\%build_name%.txt
echo. >>  %CLANG_INSTALL_DIR%\%build_name%.txt
echo   ********************** mingw version info **************************** >>  %CLANG_INSTALL_DIR%\%build_name%.txt
g++ -v >> %CLANG_INSTALL_DIR%\%build_name%.txt 2>&1

echo ********************** 打包 libclang  ****************************
cd %BUILD_START_DIR%
7z a libclang.7z %CLANG_INSTALL_DIR%
@REM move %CLANG_INSTALL_DIR% %BUILD_START_DIR%
dir


@REM @REM 测试各个工具
@REM cmake --version
@REM ninja --version
@REM g++ --version

@REM clang-format --version



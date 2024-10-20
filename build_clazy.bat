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
set _llvm_ver=19.1.1
set _clazy_tag_ver=v1.12
set mingw=MinGW-x86_64-13.1.0-release-posix-seh-ucrt-rt_v11-rev1

@REM 各个路径
set _qt_ver=%_qt_major_ver%.%_qt_minor_ver%
set _pkgfn=qt-everywhere-src-%_qtver%
set _llvm_tag_ver=llvmorg-%_llvm_ver%


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
curl -L -o MinGW.7z https://github.com/njuFerret/qt-mingw64/releases/download/build_tools/%mingw%.7z

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

@REM set PATH=%ROOT%\7zip;%ROOT%\cmake-%_cmake_ver%-windows-x86_64\bin;%ROOT%\ninja;%ROOT%\mingw64\bin;%PATH%
set PATH=%ROOT%\7zip;%ROOT%\cmake-%_cmake_ver%-windows-x86_64\bin;%ROOT%\ninja;%ROOT%\MinGW\bin;%PATH%

@REM echo **********************    g++ 版本信息   ****************************
@REM g++ -v

@REM echo ********************** 克隆 llvm-project ****************************
@REM git clone https://github.com/llvm/llvm-project.git %LLVM_DIR%
@REM cd %LLVM_DIR%
@REM echo **********************切换当前版本为 %_llvm_tag_ver% ****************************
@REM git checkout %_llvm_tag_ver%

@REM curl -L -o clean_llvm_platform.patch https://github.com/njuFerret/qt-mingw64/releases/download/build_tools/clean_llvm_platform.patch
@REM echo ***************************** 开始应用补丁 *************************************
@REM echo 应用补丁前：
@REM git diff --stat
@REM git apply clean_llvm_platform.patch
@REM echo **********************  验证补丁是否已经应用 ****************************
@REM git diff --stat

echo ********************** 克隆 CLAZY ****************************
cd %BUILD_START_DIR%
git clone https://github.com/KDE/clazy.git %CLAZY_SRC%
cd %CLAZY_SRC%
@REM echo **********************切换当前版本为 %_llvm_tag_ver% ****************************
@REM git checkout %_clazy_tag_ver%

cd %BUILD_START_DIR%

dir


@REM @REM 编译clang
@REM if "%BUILD_MODE%"=="static" (
@REM     echo ********************** 静态编译 LLVM  ****************************
@REM     set build_name=libclang_%_llvm_ver%-%mingw%-static
@REM     @REM : libclang配置为静态库，启用clang和clang-tools-extra（包含clangd和clang-tidy），不包括zlib
@REM     cmake -GNinja -DBUILD_SHARED_LIBS:BOOL=OFF -DLIBCLANG_BUILD_STATIC:BOOL=ON -DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%CLANG_INSTALL_DIR% %LLVM_DIR%/llvm -B%LLVM_DIR%/build
@REM ) else if "%BUILD_MODE%"=="shared" (
@REM     echo ********************** 静态编译 LLVM  ****************************
@REM     set build_name=libclang_%_llvm_ver%-%mingw%-shared
@REM     @REM 配置为动态库，启用clang和clang-tools-extra（包含clangd和clang-tidy）
@REM     cmake -GNinja -DBUILD_SHARED_LIBS:BOOL=ON -DLIBCLANG_LIBRARY_VERSION=%_llvm_ver% -DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%LLVM_INSTALL_DIR% %LLVM_DIR%/llvm -B%LLVM_DIR%/build
@REM )
@REM @REM : 编译
@REM cmake --build %LLVM_DIR%/build --parallel 
@REM @REM : 安装
@REM cmake --build %LLVM_DIR%/build --parallel --target install  

@REM MKDIR %INSTALL_PREFIX%
@REM cd %INSTALL_PREFIX%
@REM curl -L -o libclang.7z "https://productionresultssa4.blob.core.windows.net/actions-results/5509b7e1-99f1-4c63-860d-f377ba0d6f51/workflow-job-run-832b0204-66bc-5239-0b20-d0854358b9c1/artifacts/2e66ca7c1d4a3d57f615363dbc4f6520bfcaf4e3f6aaf2f11c868c754fa54df5.zip?rscd=attachment%3B+filename%3D%22libclang-static.7z.zip%22&se=2024-10-16T03%3A19%3A59Z&sig=9%2FbBDrYoMBSJJT4JtqSR0qojfkmA2EgPcVYEvTAw4xM%3D&ske=2024-10-16T12%3A34%3A31Z&skoid=ca7593d4-ee42-46cd-af88-8b886a2f84eb&sks=b&skt=2024-10-16T00%3A34%3A31Z&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skv=2024-08-04&sp=r&spr=https&sr=b&st=2024-10-16T03%3A09%3A54Z&sv=2024-08-04"
@REM 7z x libclang.7z
@REM dir
@REM cd libclang
@REM dir




echo ********************** 编译 CLAZY  ****************************

@REM 编译clazy
cmake -DCMAKE_INSTALL_PREFIX=%CLAZY_INSTALL_DIR% -DCLANG_LIBRARY_IMPORT="%CLANG_INSTALL_DIR%/lib/libclang.a" -DCMAKE_BUILD_TYPE=Release -GNinja -B"%CLAZY_SRC%"/build -S"%CLAZY_SRC%"
cmake --build "%CLAZY_SRC%"/build --parallel
cmake --build "%CLAZY_SRC%"/build --parallel --target install


MKDIR %CLANG_INSTALL_DIR%
echo. >  %CLANG_INSTALL_DIR%\%build_name%.txt
echo   ********************** libclang ver. %_llvm_ver% **************************** >>  %CLANG_INSTALL_DIR%\%build_name%.txt
echo. >>  %CLANG_INSTALL_DIR%\%build_name%.txt
echo   ********************** mingw version info **************************** >>  %CLANG_INSTALL_DIR%\%build_name%.txt
g++ -v >> %CLANG_INSTALL_DIR%\%build_name%.txt 2>&1

echo ********************** 打包 libclang  ****************************
cd %BUILD_START_DIR%
7z a libclang.7z %CLANG_INSTALL_DIR%

dir
@REM @REM 测试各个工具
@REM cmake --version
@REM ninja --version
@REM g++ --version

@REM clang-format --version



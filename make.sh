#! /bin/sh

function check_file_exist()
{
	if [ ! -f "$1" ]; then
		echo $1 no found, exit!!!
		exit 0
	fi
}

home=`pwd`

#从源代码中取版本号
check_file_exist "${home}/KBDTestTool/RecordTest/KeyClass/RecordTestHeader.h"
sdk_version=`grep '#define KBD_VERSION (@' ${home}/KBDTestTool/RecordTest/KeyClass/RecordTestHeader.h | head -1`
sdk_version=`echo $sdk_version | sed 's/#define KBD_VERSION (@"//g' | sed 's/")//g'`

#开始编译
echo make KBDTestTool ${sdk_version}
rm -rf ${home}/build
iphoneos_sdk_version=`xcodebuild -sdk -version | grep "(iphoneos"`
iphoneos_sdk_version=`echo $iphoneos_sdk_version|cut -d '(' -f2|cut -d ')' -f1`
iphonesimulator_sdk_version=`xcodebuild -sdk -version | grep "(iphonesimulator"`
iphonesimulator_sdk_version=`echo $iphonesimulator_sdk_version|cut -d '(' -f2|cut -d ')' -f1`
xcodebuild -target KBDTestTool -sdk $iphonesimulator_sdk_version
xcodebuild -target KBDTestTool -sdk $iphoneos_sdk_version

release_iphoneos_path="${home}/build/Release-iphoneos/KBDTestTool.framework"
release_iphonesimulator_path="${home}/build/Release-iphonesimulator/KBDTestTool.framework"

check_file_exist "${release_iphoneos_path}/KBDTestTool"
check_file_exist "${release_iphonesimulator_path}/KBDTestTool"
check_file_exist "${home}/readme.pdf"

#开始打包
cd ${home}/build

mkdir out
cp -r ${release_iphoneos_path} out/
cp ${release_iphonesimulator_path}/KBDTestTool out/
cp ${home}/readme.pdf out/

cd out
lipo -create KBDTestTool.framework/KBDTestTool KBDTestTool -output KBDTestTool.framework/KBDTestTool
rm KBDTestTool
cd KBDTestTool.framework
rm -rf Info.plist Modules _CodeSignature
cd ..
today=`date +%Y%m%d`
echo $sdk_version > ver_${today}.txt
tar -zcvf KBDTestTool.v${sdk_version}.tar.gz ver_${today}.txt readme.pdf KBDTestTool.framework



cd ${home}

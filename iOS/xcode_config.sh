#!/bin/bash
# homepage: https://github.com/Panway/PandaDevTools.git

# ┌─────────────────────────────┐
# │  update plist file's value  │
# └─────────────────────────────┘
# 修改plist文件某个key对应的value
# 参数1是key, 参数2是value, 参数3是文件相对路径
# 使用方法 Usage:
# bash xcode_config.sh updatePlistValue "CFBundleInfoDictionaryVersion" "6.0" WeChat/Info.plist
# 上述使用效果：修改的是 CFBundleInfoDictionaryVersion 所在位置的第二行
# <key>CFBundleInfoDictionaryVersion</key>
# <string>6.0</string>
updatePlistValue() {
	key=$1
	# echo '两个参数分别为 $1 和 $2 (单引号会保留原字符串！)'
	sed -i "" "/${key}/{ n; s/<string>.*<\/string>/<string>$2<\/string>/; }" $3
	echo -e "update $1 's value to \033[1;31m $2 \033[0m success"
}

# ------------------------------String 字符串方法------------------------------
# ┌──────────────────────────────────────────────────┐
# │ Replace all contents of the matching string line │
# └──────────────────────────────────────────────────┘
# 作用：匹配到的字符串所在的一整行全换成参数2
# 参数1是要被换掉的字符串
# 参数2是想要的(更新后的)目标的字符串
# 参数3是文件路径
# 使用方法 Usage:
# bash xcode_config.sh replaceWholeLineOfPattern "before" "after" PPJava.md
# 或者: bash xcode_config.sh replaceWholeLineOfPattern 'before' 'after' 'PPJava.md'
# Tips:单引号''里面需要转义的字符集有[/]
replaceWholeLineOfPattern() {
	echo "文件 [$3] 的<$1>所在行被更换为<$2>"
	sed -i "" "s/.*$1.*/$2/" $3
	# sed -i "" "s/$1/c\\$2/" "PPJava.md"
}

replaceString() {
	echo "文件 [$3] 的<$1>被更换为<$2>"
	sed -i "" "s/$1/$2/g" $3
}
# -------------------在匹配到的行前加前缀-------------------
# 使用方法:
# bash xcode_config.sh addPrefixToMatchedLine 'begin' 'PREFIX' test.txt
addPrefixToMatchedLine() {
	echo "文件 [$3] 中以[$1]开头的行前面增加前缀：<$2>"
	sed -i '' "s/^$1/$2/" $3
}

PROJECT_DIR=$(
	cd $(dirname $0)
	pwd
)
echo "[Debug] current project path(当前工程路径):$PROJECT_DIR"

#如果把shell脚本放到了/usr/local/bin/目录下，那么需要修改当前iOS工程路径：
if [[ $PROJECT_DIR == *"/usr/local/bin"* ]]; then
	iOSProjectPath=$(PWD)
	echo "[Debug] 当前工程路径字符串包含/usr/local/bin"
	PROJECT_DIR=$iOSProjectPath
	echo $PROJECT_DIR
fi
PROJECT_NAME=(*.xcworkspace)
echo "[Debug] project name is $PROJECT_NAME"

# you can set your own target name
TARGET_NAME=""
# get default target name(获取默认Target) https://stackoverflow.com/a/918931/4493393
IFS='.' read -ra ADDR <<<"$PROJECT_NAME"
for i in "${ADDR[@]}"; do
	if [[ ${#param2} < 1 ]]; then
		TARGET_NAME=$i
	fi
	break
done
echo "[Debug] target name is $TARGET_NAME"

INFOPLIST_FILE="$TARGET_NAME/Info.plist"
pbxproj_file_path="${PROJECT_DIR}${TARGET_NAME}.xcodeproj/project.pbxproj"
nowDate=$(date +%Y%m%d%H%M%S)

: '
This is a
very neat comment
in bash
这是一个多行注释
'

param1=$1
param2=$2
COMMAND="${1-}"
echo "[Debug] param1 is $param1 param2 is $param2"

# 彩色输出，用法：colorfulPrint "helloworld" 31
# 参数2可选项:reset = 0, black = 30, red = 31, green = 32, yellow = 33, blue = 34, magenta = 35, cyan = 36, and white = 37
colorfulPrint() {
	echo -e "\033[1;$2m $1 \033[0m"
}

# 修改plist文件的build number
if [ "$COMMAND" = "set_build_number" ]; then
	# get old build number
	buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PROJECT_DIR}/${INFOPLIST_FILE}")
	if [[ ${#param2} < 1 ]]; then
		echo "[Debug] no specific build number, build number will +1.(未指定build号，build号将加一) you can use: "
		echo -e "\033[1;32m bash xcode_config.sh set_build_number 202107 \033[0m"
		echo "buildNumber:$buildNumber"
		if [[ $buildNumber == *"CURRENT_PROJECT_VERSION"* ]]; then
			# Preventing the following errors:
			# /Users/xxx/Library/Developer/Xcode/DerivedData/xxx/Build/Intermediates.noindex/xxx.build/Debug-iphoneos/xxx.build/Script-xxx.sh: line 7: $(CURRENT_PROJECT_VERSION) + 1: syntax error: operand expected (error token is "$(CURRENT_PROJECT_VERSION) + 1")
			colorfulPrint "WARNING 警告" "33"
			echo "build bumber in Info.plist changed from CURRENT_PROJECT_VERSION to $nowDate"
			echo "$pbxproj_file_path 's CURRENT_PROJECT_VERSION is no longer effective"
			buildNumber=$nowDate
		fi
		buildNumber=$(($buildNumber + 1))
	else
		buildNumber=${param2}
	fi
	# set a new build number
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${PROJECT_DIR}/${INFOPLIST_FILE}"
	echo "[Debug] current build number is $buildNumber"
elif [[ "$COMMAND" = "add_gitignore" ]]; then
	objc_gitignore_url="https://raw.githubusercontent.com/github/gitignore/master/Objective-C.gitignore"
	# 如果不存在curl，就尝试使用wget
	if ! command -v curl &>/dev/null; then
		# 如果不存在wget，就提示错误
		if ! command -v wget &>/dev/null; then
			echo "[Error]: curl and wget command not found. you should install curl or wget first."
			exit
		else
			wget $objc_gitignore_url -O .gitignore
		fi
	else
		curl $objc_gitignore_url -o .gitignore
	fi
	# install to /usr/local/bin/xcode_config 把sh文件变成可执行命令
elif [[ "$COMMAND" = "install_to_local" ]]; then
	cp -v ./xcode_config.sh /usr/local/bin/xcode_config
	chmod +x /usr/local/bin/xcode_config
else
	# read VAR
	echo "[Error] parameters required. (未获取到参数) you can use: \nbash xcode_config.sh set_build_number"
fi

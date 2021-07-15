#!/bin/bash
# home: https://github.com/Panway/PandaDevTools.git

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

# -------------------匹配到的字符串所在的一整行全换成参数2-------------------
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

: '
This is a
very neat comment
in bash
'

param1=$1
param2=$2
COMMAND="${1-}"
echo "[Debug] param1 is $param1 param2 is $param2"

if [ "$COMMAND" = "set_build_number" ]; then
	buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PROJECT_DIR}/${INFOPLIST_FILE}")
	if [[ ${#param2} < 1 ]]; then
		echo "[Debug] no specific build number, build number will +1.(未指定build号，build号将加一) you can use: "
		echo -e "\033[1;32m bash xcode_config.sh set_build_number 202107 \033[0m"
		# If your project's CFBundleVersion is $(CURRENT_PROJECT_VERSION), you'd better use another way,
		# otherwise your `$(CURRENT_PROJECT_VERSION)` will be `10`、`11`...
		if [[ $buildNumber == *"CURRENT_PROJECT_VERSION"* ]]; then
			# Preventing the following errors:
			# /Users/xxx/Library/Developer/Xcode/DerivedData/xxx/Build/Intermediates.noindex/xxx.build/Debug-iphoneos/xxx.build/Script-xxx.sh: line 7: $(CURRENT_PROJECT_VERSION) + 1: syntax error: operand expected (error token is "$(CURRENT_PROJECT_VERSION) + 1")
			echo "build bumber is CURRENT_PROJECT_VERSION"
			buildNumber=$CURRENT_PROJECT_VERSION
		fi
		buildNumber=$(($buildNumber + 1))
		/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${PROJECT_DIR}/${INFOPLIST_FILE}"
	else
		buildNumber=${param2}
		/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${PROJECT_DIR}/${INFOPLIST_FILE}"
	fi
	echo "[Debug] current build number is $buildNumber"
elif [[ "$COMMAND" = "add_gitignore" ]]; then
	objc_gitignore_url="https://raw.githubusercontent.com/github/gitignore/master/Objective-C.gitignore"
	if ! command -v curl &>/dev/null; then
		if ! command -v wget &>/dev/null; then
			echo "[Error]: curl and wget command not found. you should install curl or wget first."
			exit
		else
			wget $objc_gitignore_url -O .gitignore
		fi
	else
		curl $objc_gitignore_url -o .gitignore
	fi
else
	# read VAR
	echo "[Error] parameters required. (未获取到参数) you can use: bash xcode_config.sh set_build_number"
fi

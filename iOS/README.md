# iOS Developer Tools

## Install or download 安装或下载

方式一：

您可以使用curl或者wget下载 [xcode_config.sh](https://raw.githubusercontent.com/Panway/PandaDevTools/main/iOS/xcode_config.sh) 脚本到您项目的根目录，然后参考下一节的使用说明。

```bash
curl https://raw.githubusercontent.com/Panway/PandaDevTools/main/iOS/xcode_config.sh -o xcode_config.sh
```

or

```bash
wget https://raw.githubusercontent.com/Panway/PandaDevTools/main/iOS/xcode_config.sh
```

方式二：

下载到`/usr/local/bin`，在任意iOS工程根目录都能使用：

```bash
# 下载并改名为xcode_config，增加可执行权限
wget https://raw.githubusercontent.com/Panway/PandaDevTools/main/iOS/xcode_config.sh -O /usr/local/bin/xcode_config && chmod +x /usr/local/bin/xcode_config
# 在任意iOS根目录使用：
xcode_config set_build_number 2022
```



## Usage 使用

如果安装上面的方法安装到`/usr/local/bin`,以下的`sh xcode_config.sh`可以换成`xcode_config`

execute shell script 执行脚本命令

```bash
sh xcode_config.sh <command_name>
```

or

```bash
# 这种方式首次需要增加可执行权限：chmod +x xcode_config.sh
./xcode_config.sh <command_name>
```

## command_name 命令名

- build号+1

```bash
# +1
bash xcode_config.sh set_build_number
# specific number
bash xcode_config.sh set_build_number 202107
```

- 在当前目录增加`.gitignore`文件

```bash
bash xcode_config.sh set_build_number
```
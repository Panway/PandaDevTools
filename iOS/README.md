iOS Developer Tools

# Usage 使用

```bash
bash xcode_config.sh <command_name>
```

or

```bash
# only first time 仅首次
chmod +x xcode_config.sh
# execute shell script 执行脚本命令
./xcode_config.sh <command_name>
```

# command_name命令名

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
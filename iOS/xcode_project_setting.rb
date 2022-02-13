# 使用方法：cd到脚本所在目录，终端运行`ruby xcode_project_setting.rb set_app_version 2.5.0 等`
require "xcodeproj"
require "json"
# require 'scanf'
# require "timeout"

# project name,eg: TikTok.xcodeproj
project_name = ""
# target name,eg: TikTok
target_name = ""
# 从 `TikTok.xcodeproj` 获取--> `TikTok`
fileList = Dir.entries(".")
fileList.each do |file_name|
  if file_name.end_with?(".xcodeproj")
    project_name = "#{file_name}"
    target_name = file_name.sub! ".xcodeproj", ""
  end
end

project_path = "#{Dir.pwd}/#{project_name}"
puts "project_name: #{project_name.bold}, target_name: #{target_name}"

# 命令行带参数的话
param0 = ARGV[0]
param1 = ARGV[1]
param2 = ARGV[2]
param3 = ARGV[3]
# puts "---------- param list ----------"
# puts param0
# puts param1
# puts param2

order_name = -1
if param0.instance_of? String
  #如果带参数了
  order_name = param0
else
  # 等待用户输入
  # order_name = gets
  order_name = "2" #写死成2
  # puts "Hi,#{order_name}! You know what?"
  # puts order_name.class#(.class方法返回当前数据类型)
  # 指令转换成整数
  order_num = order_name.to_i(base = 10)
  if order_num == 3
    puts "请输入build号（仅限数字）："
    param1 = gets
    param1 = param1.to_i()
    param0 = "set_build_version"
  elsif order_num == 4
    param0 = "build_version_increase"
  end
end

project_extension_name = ".xcodeproj"
full_proj_path = Dir.pwd
full_proj_path << "/" #字符串拼接
full_proj_path << project_name
project_path = full_proj_path    # 工程的全路径
# global variable
project = Xcodeproj::Project.open(project_path)

# ---------- method list ----------
# sample https://github.com/CocoaPods/Xcodeproj/blob/master/spec/project/object/build_configuration_spec.rb
# 这样定义方法才能访问project这个变量
define_method :modifyProject do |*arg|
  # def modifyProject(configKey, configValue)
  configKey = arg[0]
  configValue = arg[1]
  # 如果值为 JSON 对象，则不要将其修改为字符串。if value is JSON Object, don't modify it as string
  begin
    configValue = JSON.parse(arg[1])
  rescue JSON::ParserError => e
    # puts "Parse_JSON_Error"
  end
  # puts "Modifying #{configKey} to #{configValue}"
  if configValue == nil
    puts "第二个参数不能为空。second param can't be nil!"
    return
  end
  project.targets.each do |target|
    target.build_configurations.each do |config|
      # modify when param2 is nil or param2 == config.name
      if target.name == target_name && (param2 == nil || param2 == "all" || param2.downcase == config.name.downcase)
        if config.build_settings[configKey] == nil
          keyNotExistTips(configKey)
          if param3 != "-f"
            return
          end
        end
        if param1 == "plus_one"
          config.build_settings[configKey] = config.build_settings[configKey].to_i() + 1
        else
          config.build_settings[configKey] = configValue
        end
        puts "`#{configKey.to_s.bold}` has been modified to `#{configValue.to_s.green}` for #{config.name}"
      end
    end
  end
  project.save
end

define_method :keyNotExistTips do |configKey|
  puts "
警告: WARNING
#{configKey}不存在，如果想新增，请使用-f标识作为第四个参数！ 
#{configKey} is not exist! If you still want to add, please use -f as the 4th param!
eg:
ruby xcode_project_setting.rb GOOD 12345 release -f
or:
ruby xcode_project_setting.rb GOOD 12345 all -f
"
end

# 将终端文本输出着色 colorize the text output to a terminal https://stackoverflow.com/a/16363159/4493393
class String
  def red; "\e[31m#{self}\e[0m" end
  def green; "\e[32m#{self}\e[0m" end
  def yellow; "\e[33m#{self}\e[0m" end
  def blue; "\e[34m#{self}\e[0m" end
  def pink; "\e[35m#{self}\e[0m" end
  def cyan; "\e[36m#{self}\e[0m" end
  def bold; "\e[1m#{self}\e[22m" end
end

# ---------- main ----------
if param0.eql? "set_app_version"
  modifyProject("MARKETING_VERSION", param1)
  puts "App版本已修改"
elsif param0.eql? "DEVELOPMENT_TEAM"
  modifyProject("DEVELOPMENT_TEAM", param1)
elsif param0.eql? "set_build_version"
  buildNumber = param1
  if param1 == nil
    # 不指定就用当前时间
    current_time = Time.now.strftime("%Y%m%d%H%M")
    buildNumber = "#{current_time}"
  end
  modifyProject("CURRENT_PROJECT_VERSION", buildNumber)
  puts "App Build号已修改为：#{buildNumber}"
elsif param0.eql? "set_app_bundleid"
  #修改App BundleID
  modifyProject("PRODUCT_BUNDLE_IDENTIFIER", param1)
  puts "修改 App BundleID成功"
elsif param0.eql? "set_app_icon"
  #修改App桌面AppIcon
  modifyProject("ASSETCATALOG_COMPILER_APPICON_NAME", param1)
  puts "App Icon 已修改"
elsif param0.eql? "set_app_profile"
  #修改App打包所需描述文件 modify provisioning profile
  modifyProject("PROVISIONING_PROFILE_SPECIFIER", param1)
  puts "打包配置文件已修改"
elsif param0.eql? "build_version_plus_one"
  modifyProject("CURRENT_PROJECT_VERSION", "plus_one")
else
  # 常用设置：DEVELOPMENT_TEAM、CODE_SIGN_IDENTITY、CODE_SIGN_STYLE
  # 实际起作用的代码
  # config.build_settings["CODE_SIGN_IDENTITY"] = "iPhone Distribution"
  # config.build_settings["CODE_SIGN_STYLE"] = "Manual"
  # config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = ['$(inherited)', 'PUBLIC_PROJECT=1','USE_POLYVSDK=0']
  # 脚本用法
  # ruby xcode_project_setting.rb GCC_PREPROCESSOR_DEFINITIONS '["$(inherited)", "PUBLIC_PROJECT=1", "USE_POLYVSDK=0"]'
  puts "不支持的命令:<#{param0} #{param1} #{param2}>，已帮您尝试设置`#{param0.bold}`的值。 \nunsupported command, try to set `#{param0.bold}`'s value."
  modifyProject(param0, param1)
end

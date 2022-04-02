## nodejs 工具

处理字符串：

```js
//字符串替换
node string_tool.js replaceString './src/index.js' 'oldString' 'newString'
//字符串正则匹配替换
node string_tool.js replaceString "config.js" "const debugMode = .{1,6};" "const debugMode = false;"
```

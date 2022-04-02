var fs = require("fs");
const readline = require("readline");
const { exec } = require("child_process");

// https://stackoverflow.com/a/32599033/4493393
async function processLineByLine(path) {
  const fileStream = fs.createReadStream(path);

  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity,
  });
  // Note: we use the crlfDelay option to recognize all instances of CR LF
  // ('\r\n') in input.txt as a single line break.
  let resultArray = [];
  for await (const line of rl) {
    resultArray.push(line);
    // Each line in input.txt will be successively available here as `line`.
    // console.log(`[Line]: ${line}`);
  }
  return resultArray;
}

//Replace a string in a file https://stackoverflow.com/a/14181136/4493393
function replaceTextInFile(filePath, oldText, newText) {
  fs.readFile(filePath, "utf8", function (err, data) {
    if (err) {
      return console.log(err);
    }
    console.log(oldText, "--->", newText);
    var reg = new RegExp(oldText, "g");
    // var result = data.replace(/"oldText"/g, newText);
    var result = data.replace(reg, newText);
    fs.writeFile(filePath, result, "utf8", function (err) {
      if (err) return console.log(err);
    });
  });
}

/**
 * 同步读取和替换文件里的字符串
 * @param {string} filePath 文件路径
 * @param {string} oldText 旧的文本或正则表达式
 * @param {string} newText 新的文本
 */
function replaceTextInFileSync(filePath, oldText, newText) {
  let data = fs.readFileSync(filePath, "utf8");
  var reg = new RegExp(oldText, "g");
  var result = data.replace(reg, newText);
  console.log(oldText, "-->", newText);
  fs.writeFileSync(filePath, result, "utf8", function (err) {
    if (err) return console.log(err);
  });
}

/**
 * execute Linux's like command 执行像Linux一样的命令
 * @param {string} command your git command, eg: git pull
 */
function executeCommand(command) {
  if (!command) {
    console.warn("command can not be empty");
  }
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.log(`error: ${error.message}`);
      return;
    }
    if (stderr) {
      console.log(`stderr: ${stderr}`);
      return;
    }
    console.log(`stdout: ${stdout}`);
  });
}

// print process.argv
let param2 = process.argv[2];
let param3 = process.argv[3];
let param4 = process.argv[4];
let param5 = process.argv[5];

if (param2 == "replaceString") {
  replaceTextInFileSync(param3, param4, param5);
} else {
  console.log(
    "请输入正确的参数，例如：node devtool.js replaceString ./src/index.js 'oldString' 'newString'"
  );
}

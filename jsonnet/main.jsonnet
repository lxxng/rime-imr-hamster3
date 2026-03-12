local iPhonePinyin = import 'Components/iPhonePinyin.libsonnet';
local temp26KeyLayout = import 'Components/Temp26KeyLayout.libsonnet';
local iPhoneAlphabetic = import 'Components/iPhoneAlphabetic.libsonnet';
local iPhoneNumeric = import 'Components/iPhoneNumeric.libsonnet';
local iPhoneNumericRowEn = import 'Components/iPhoneNumericRowEn.libsonnet';
local panel = import 'Components/Panel.libsonnet';
local settings = import 'Settings.libsonnet';

local nameToComponent = {
  pinyin: iPhonePinyin,
  alphabetic: iPhoneAlphabetic,
  numeric: iPhoneNumeric,
  panel: panel,
  [if !std.startsWith(settings.keyboardLayout, '26') then 'temp26Key']: temp26KeyLayout,
  [if settings.numericLayout == 'row' then 'numericRowEn']: iPhoneNumericRowEn,
};

local getFileName(componentName, isPortrait) =
  componentName + (if isPortrait then 'Portrait' else 'Landscape');

local config = {
  [name]: {
    iPhone: {
      portrait: getFileName(name, isPortrait=true),
      landscape: getFileName(name, isPortrait=false),
    },
    iPad: {
      portrait: getFileName(name, isPortrait=true),
      landscape: getFileName(name, isPortrait=false),
      floating: getFileName(name, isPortrait=true),
    },
  } for name in std.objectFields(nameToComponent)
};

// std.toString 生成的内容紧凑，生成速度快，但不易阅读，适合发布时使用
// std.manifestYamlDoc 生成的内容格式化良好，易于阅读，但生成速度慢，也更占用内存，适合在电脑上调试时使用
// 如果想让 debug=true，需要在命令行中使用 --tla-code debug=true 参数传入
function(debug=false)
  local toString =
    if debug then
      function(x) std.manifestYamlDoc(x, indent_array_in_object=false, quote_keys=false)
    else
      function(x) std.toString(x);
{
  'config.yaml': std.manifestYamlDoc(config, indent_array_in_object=true, quote_keys=false),
}
// 键盘布局文件: light/dark × portrait/landscape
+ std.foldl(function(acc, x) acc + x, [
  {
    [theme + '/' + getFileName(name, isPortrait=isPortrait) + '.yaml']:
      toString(nameToComponent[name].new(isDark=(theme == 'dark'), isPortrait=isPortrait))
    for name in std.objectFields(nameToComponent)
  }
  for theme in ['light', 'dark']
  for isPortrait in [true, false]
], {})

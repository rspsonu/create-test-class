var fs = require('fs');

//File path
fs.readFile('../force-app/main/default/classes/patientCareClass.cls', 'utf8', (err, data) => {
  if (err) throw err;

  //Total lines
  var totalLines = 0;
  //Class description variables
  var className;
  var constructorNames;
  var methodParamMap = new Map();
  var methodReturnMap = new Map();
  //Flags to keep track of lines
  var start = 0;
  var end = 0;

  //Processing the class
  for (index in data) {
    //Finding end of a line
    if (data[index] == '\n') {
      end = index;
      //Processing the first line
      if (start == 0) {
        var firstLine = data.substring(start, end).split(' ');
        className = firstLine[firstLine.indexOf('{') - 1];
      }
      else {
        var line = data.substring(start, end);
        //Processing method lines
        if (line.includes('public') || line.includes('private') || line.includes('protected') || line.includes('global')) {
          var line = data.substring(start, end).trim();
          var methodDelcaration = line.split('(');

          //Getting method name and return type
          var methodAttributes = methodDelcaration[0].split(' ');
          var methodName = methodAttributes[methodAttributes.length - 1];

          //Handling constructor
          if (methodName == className) {
            constructorNames = methodName;
          }
          //Handling methods
          else {
            //Getting method parameters
            var methodParameters = line.substring(line.indexOf('(') + 1, line.indexOf(')')).split(',');
            if (methodParameters == '') {
              methodParameters = 'No parameters';
            }
            //Getting method return type
            var returnType = methodAttributes[methodAttributes.length - 2];
            if (returnType == '[]') {
              returnType = 'List<' + methodAttributes[methodAttributes.length - 3] + '>';
            }
            //Populating method maps
            methodParamMap.set(methodName, methodParameters);
            methodReturnMap.set(methodName, returnType);
          }
        }
      }
      start = end;
      totalLines++;
    }
  }
  console.log('Class Name: ' + className);
  console.log('\nConstructor: ' + constructorNames);
  console.log('\nMethod parameter map:');
  for (var [key, value] of methodParamMap) {
    console.log(key + ' -> ' + value);
  }
  console.log('\nMethod return type map:');
  for (var [key, value] of methodReturnMap) {
    console.log(key + ' -> ' + value);
  }
  console.log('\nMethods:');
  for (var method of methodParamMap.keys()) {
    console.log(method);
  }
  console.log('\nParamteres:');
  for (var parameter of methodParamMap.values()) {
    console.log(parameter);
  }

  console.log('\nTotal lines: ' + totalLines);
});

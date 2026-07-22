const fs = require('fs');
const path = require('path');

function processDir(dir) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      processDir(fullPath);
    } else if (fullPath.endsWith('.dart')) {
      let content = fs.readFileSync(fullPath, 'utf8');
      
      // Match something like `e.response?.data['message']` or `res.data['message']`
      // Group 1 captures the variable/expression before `['message']`
      const regex = /([a-zA-Z0-9_\.\?]+)\['message'\]/g;
      
      const newContent = content.replace(regex, (match, expr) => {
        return `(${expr} is Map ? ${expr}['message'] : null)`;
      });
      
      if (content !== newContent) {
        fs.writeFileSync(fullPath, newContent);
        console.log('Fixed', fullPath);
      }
    }
  }
}

processDir(path.join(__dirname, 'frontend/lib'));
console.log('Done');

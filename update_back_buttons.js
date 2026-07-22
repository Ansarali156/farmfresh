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
      if (content.includes('Icons.chevron_left')) {
        content = content.replace(/Icons\.chevron_left/g, 'Icons.arrow_back');
        fs.writeFileSync(fullPath, content);
        console.log('Updated back button in:', fullPath);
      }
    }
  }
}

processDir(path.join(__dirname, 'frontend/lib/features'));
console.log('Done updating back buttons.');

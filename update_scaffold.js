const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    const dirPath = path.join(dir, f);
    const isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? walkDir(dirPath, callback) : callback(path.join(dir, f));
  });
}

walkDir(path.join(__dirname, 'lib/screens'), (filePath) => {
  if (filePath.endsWith('.dart')) {
    let content = fs.readFileSync(filePath, 'utf8');
    let changed = false;

    // Check if the file contains AppDrawer
    if (content.includes('AppDrawer()') && content.includes('return Scaffold(')) {
      
      // Calculate relative path for import
      // filePath is something like lib/screens/dashboard/dashboard_screen.dart
      // target is lib/widgets/core/blurred_drawer_scaffold.dart
      const dirPath = path.dirname(filePath);
      let relativePath = path.relative(dirPath, path.join(__dirname, 'lib/widgets/core/blurred_drawer_scaffold.dart')).replace(/\\/g, '/');
      
      const newImport = `import '${relativePath}';\n`;
      
      if (!content.includes('blurred_drawer_scaffold.dart')) {
        const lastImportIndex = content.lastIndexOf('import ');
        const endOfLastImport = content.indexOf('\n', lastImportIndex);
        content = content.slice(0, endOfLastImport + 1) + newImport + content.slice(endOfLastImport + 1);
      }
      
      content = content.replace(/return Scaffold\(/g, 'return BlurredDrawerScaffold(');
      changed = true;
    }

    if (changed) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`Updated ${filePath}`);
    }
  }
});

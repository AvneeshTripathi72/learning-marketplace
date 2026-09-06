const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    const dirPath = path.join(dir, f);
    const isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? walkDir(dirPath, callback) : callback(path.join(dir, f));
  });
}

walkDir(path.join(__dirname, 'backend/src'), (filePath) => {
  if (filePath.endsWith('.controller.ts')) {
    let content = fs.readFileSync(filePath, 'utf8');
    let changed = false;

    // Replace imports
    if (content.includes('RolesGuard') || content.includes('@Roles')) {
      content = content.replace(/import \{ Roles \} from '\.\.\/auth\/decorators\/roles\.decorator';\n?/, '');
      content = content.replace(/import \{ RolesGuard \} from '\.\.\/auth\/guards\/roles\.guard';\n?/, '');
      
      const newImports = `import { RequirePermissions } from '../auth/decorators/permissions.decorator';\nimport { AccessControlGuard } from '../auth/guards/access-control.guard';\n`;
      // Find last import
      const lastImportIndex = content.lastIndexOf('import ');
      const endOfLastImport = content.indexOf('\n', lastImportIndex);
      content = content.slice(0, endOfLastImport + 1) + newImports + content.slice(endOfLastImport + 1);
      
      changed = true;
    }

    // Replace @UseGuards(RolesGuard)
    if (content.includes('@UseGuards(RolesGuard)')) {
      content = content.replace(/@UseGuards\(RolesGuard\)/g, '@UseGuards(AccessControlGuard)');
      changed = true;
    }

    // Replace @Roles(UserRole.ADMIN) etc.
    const rolesRegex = /@Roles\(([^)]+)\)/g;
    let match;
    while ((match = rolesRegex.exec(content)) !== null) {
      const roles = match[1];
      // Get module name from filename (e.g., youtube.controller.ts -> youtube)
      const moduleName = path.basename(filePath).split('.')[0];
      const newDecorator = `@RequirePermissions({ module: '${moduleName}', action: 'ALL', roles: [${roles}] })`;
      content = content.replace(match[0], newDecorator);
      changed = true;
    }

    if (changed) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`Updated ${filePath}`);
    }
  }
});

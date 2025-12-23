# Extension Icons

The extension requires PNG icons in three sizes:
- icon16.png (16x16)
- icon48.png (48x48)  
- icon128.png (128x128)

## Quick Setup Option 1: Use Existing Icons

Copy icons from the LinkedIn extension:

```powershell
Copy-Item "..\linkedin-chrome-extension\icons\*" "." -Force
```

## Option 2: Convert SVG to PNG

Use an online converter or local tool to convert `icon.svg` to PNG at each size:

### Online Converters
- https://svgtopng.com/
- https://cloudconvert.com/svg-to-png

### Using Chrome DevTools
1. Open `icon.svg` in Chrome
2. Right-click → Inspect
3. Console: 
   ```javascript
   const canvas = document.createElement('canvas');
   canvas.width = 128; canvas.height = 128;
   const ctx = canvas.getContext('2d');
   const img = new Image();
   img.onload = () => {
     ctx.drawImage(img, 0, 0, 128, 128);
     const link = document.createElement('a');
     link.download = 'icon128.png';
     link.href = canvas.toDataURL();
     link.click();
   };
   img.src = 'icon.svg';
   ```
4. Repeat for 48x48 and 16x16

### Using PowerShell + ImageMagick (if installed)
```powershell
magick icon.svg -resize 128x128 icon128.png
magick icon.svg -resize 48x48 icon48.png
magick icon.svg -resize 16x16 icon16.png
```

## Option 3: Temporary Placeholders

For testing, create solid color PNG files (extension will load but with plain icons).

## Design Elements

The SVG icon features:
- Purple gradient background (#667eea to #764ba2)
- White cloud symbol (Salesforce)
- Plus sign (Create action)
- Person icon (Candidate)

Colors match the extension's UI theme.

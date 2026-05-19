# Pixel Label Manager (ArkOS 2.0) by ColtonMyers1995
       Custom-Collection Label-Maker for es-theme-PIXEL-OS

A controller-friendly tool for creating custom system-view labels for the PIXEL OS theme.
The tool operates within ArkOS, giving users a full label-making toolkit.
The created labels can be applied directly to custom-collections per view (icons, logos, images)

## Working Systems
R36S, R36H, R46S, R46H
(R50S, R45S and R40S will be tested for compatability in the near future)

## Features
- Create logos, icons and images
- Multiple logo type-sets
- Access massive 900+ icon library
- Grid-based text input (controller-based)
- Font library
- Color library
- Automatic PNG generation and exporting
- Built-in tool and theme updater
- Restore art folders (erase all created labels)
- HOW TO USE section for beginners

## Installation
Copy the scripts to:
```
/roms/tools/
```

Make executable if needed (not needed for ArkOS 2.0):
```
chmod +x Custom-Collection Label-Maker.sh
chmod +x Pixel-Label Dependency-Installer.sh
```

## Usage
- Run the label-maker dependency installer from Tools section
- Launch label-maker tool from Tools section
- Design your logo/icon/image (choose style, color, sizes, text, image, padding, spacing, type (logo, icon, image))

## Additional Info
- The 3 label styles are paired to the view types in PIXEL OS; to see created icons, set to icons, etc
- Logos are more complex than icons/images, offering MANY customization options and multiple styles
- Logos are automatically pushed to icon and image views if no custom icon or image PNG exists
  (create a separate 'icon' and/or 'image' style PNG(s) to avoid created logos appearing in icon/image views)
- The user must be connected to internet to update or restore the theme/tool

## Designed for
https://github.com/ColtonMyers1995/es-theme-PIXEL-OS

## Legalities
This tool is open source and is free to be altered/converted/repurposed for other themes or uses


## Simple Walkthrough of tool
0. Install tool
1. Open tool from tools menu
2. Create logo/icon/image PNG
3. Create custom-collection with same name as PNG you made
4. Enable the custom collection
5. Turn off "group unthemed custom collections"
6. Restart ES with quit-menu or toolkit
7. Find your custom-collection in system list
   (make sure you are using the same view as the label style you made (logo/icon/image) in theme settings)
8. Label is applied and visible
9. [OPTIONAL] Use the tool to recreate the image again if you want to change parts of the label you created.
   (recreating a label after step 8 does not require restarting ES or remaking a custom-collection to apply)

## Additional
[R46S Information]
If you are using the stock ArkOS image that came with R46S, use the R46S version.
Alternatively, the regular version of this tool works with the RGB30 ArkOS patch on R46S.
The patch-tool is available at:
https://github.com/ColtonMyers1995/R46S-from-RGB30

[Controller Carry-Over]
Exiting the tool without restarting ES from within the toolkit will result in false controller outputs in ES.
Restarting your system will restore regular controller outputs, but using the toolkit option is advised.



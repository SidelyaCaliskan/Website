# 🎃 SpookEdit - Sticker Assets Guide

## Where to Add PNG Stickers

### Directory Structure
```
assets/stickers/
├── ghosts/           # Ghost stickers
├── pumpkins/         # Pumpkin & jack-o'-lantern stickers
├── bats/             # Bat stickers
├── witches/          # Witch hats, brooms, cauldrons
├── monsters/         # Zombies, vampires, Frankenstein
├── spiders/          # Spiders and webs
├── skulls/           # Skulls and skeletons
├── candy/            # Halloween candy
├── text/             # Text overlays (BOO!, etc.)
└── misc/             # Moons, cats, coffins, etc.
```

## How to Add PNG Assets

### 1. **Download or Create PNG Stickers**

**Requirements:**
- Format: PNG with transparent background
- Recommended size: 512x512px (will be scaled in app)
- Naming: lowercase_with_underscores.png

### 2. **Place Files in Correct Folder**

Example:
```
assets/stickers/ghosts/cute_ghost.png
assets/stickers/pumpkins/jack_o_lantern.png
assets/stickers/bats/flying_bat.png
```

### 3. **Update sticker_categories.json**

Open `/assets/data/sticker_categories.json` and add the `assetPath` field:

**Before (emoji only):**
```json
{
  "id": "ghost_1",
  "name": "Cute Ghost",
  "emoji": "👻"
}
```

**After (with PNG asset):**
```json
{
  "id": "ghost_1",
  "name": "Cute Ghost",
  "emoji": "👻",
  "assetPath": "assets/stickers/ghosts/cute_ghost.png"
}
```

### 4. **Complete Example**

```json
{
  "id": "ghosts",
  "name": "Ghosts",
  "icon": "👻",
  "stickers": [
    {
      "id": "ghost_1",
      "name": "Cute Ghost",
      "emoji": "👻",
      "assetPath": "assets/stickers/ghosts/cute_ghost.png"
    },
    {
      "id": "ghost_2",
      "name": "Scary Ghost",
      "emoji": "😱",
      "assetPath": "assets/stickers/ghosts/scary_ghost.png"
    }
  ]
}
```

## 🎁 Where to Find FREE Halloween Stickers

### 1. **Flaticon** (Free with attribution)
- https://www.flaticon.com/search?word=halloween
- Download as PNG, 512px size
- Offers thousands of Halloween icons

### 2. **Freepik** (Free with attribution)
- https://www.freepik.com/search?format=search&query=halloween%20stickers
- High-quality Halloween graphics
- PNG format available

### 3. **Vecteezy** (Free)
- https://www.vecteezy.com/free-vector/halloween-stickers
- Free Halloween sticker packs
- Export as PNG

### 4. **OpenMoji** (Open source)
- https://openmoji.org/
- Search for "halloween", "ghost", "pumpkin"
- Free for commercial use

### 5. **Icons8** (Free with link)
- https://icons8.com/icons/set/halloween
- Download PNG with transparent background
- Multiple styles available

### 6. **Create Your Own**
- Use **Canva** (free): https://www.canva.com/
- Use **Adobe Express** (free): https://www.adobe.com/express/
- Use **Figma** (free): https://www.figma.com/

## 📝 Quick Start Example

### Example: Adding a Ghost Sticker

1. **Download a ghost PNG** from any source above
2. **Save as**: `cute_ghost.png`
3. **Move to**: `/assets/stickers/ghosts/cute_ghost.png`
4. **Update JSON**:

```json
{
  "id": "ghost_1",
  "name": "Cute Ghost",
  "emoji": "👻",
  "assetPath": "assets/stickers/ghosts/cute_ghost.png"
}
```

5. **Hot reload** the app - your sticker is now available!

## 🎨 Recommended Sticker Pack Structure

For a complete Halloween sticker pack, consider adding:

**Ghosts (5-10 stickers)**
- cute_ghost.png
- scary_ghost.png
- friendly_ghost.png
- ghost_with_chain.png

**Pumpkins (5-10 stickers)**
- happy_pumpkin.png
- scary_pumpkin.png
- classic_jack_o_lantern.png
- angry_pumpkin.png

**Bats (3-5 stickers)**
- flying_bat.png
- upside_down_bat.png
- bat_swarm.png

**Witches (5-8 stickers)**
- witch_hat.png
- witch_broom.png
- cauldron.png
- magic_wand.png

**Text Overlays (5-10 stickers)**
- boo_text.png
- happy_halloween_text.png
- trick_or_treat_text.png
- eek_text.png

## 🔧 Troubleshooting

**Sticker not showing?**
- Check file path is correct in JSON
- Make sure PNG has transparent background
- Verify file is in assets/stickers/ folder
- Hot reload or restart the app

**Image quality issues?**
- Use 512x512px or larger
- Export as PNG-24 with transparency
- Avoid JPG format (no transparency)

## ✨ Pro Tips

1. **Consistent sizing**: Keep all stickers at 512x512px for consistency
2. **Transparent backgrounds**: Always use PNG with transparency
3. **File naming**: Use descriptive, lowercase names with underscores
4. **Test in app**: Add one sticker first to test before batch adding
5. **Organize by theme**: Keep similar stickers in the same category

---

**Ready to get started?** Download some stickers from the sources above and add them to your app!
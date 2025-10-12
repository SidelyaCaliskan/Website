# Sticker Assets Structure

This directory contains Halloween-themed sticker assets for the SpookEdit app.

## Directory Structure

```
stickers/
├── ghosts/          # Ghost-themed stickers
├── pumpkins/        # Pumpkin and jack-o'-lantern stickers
├── bats/            # Bat stickers
├── witches/         # Witch hats, brooms, cauldrons
├── monsters/        # Frankenstein, mummies, zombies
├── spiders/         # Spider and web stickers
├── skulls/          # Skull and skeleton stickers
├── candy/           # Candy and treats
├── text/            # Halloween text and phrases
└── misc/            # Other Halloween elements
```

## Asset Requirements

- **Format**: PNG with transparency
- **Size**: 512x512px recommended (will be scaled in app)
- **Background**: Transparent
- **Color**: Full color or monochrome
- **Naming**: lowercase_with_underscores.png

## Example Filenames

- `ghosts/cute_ghost.png`
- `pumpkins/jack_o_lantern_smile.png`
- `bats/flying_bat.png`
- `witches/witch_hat.png`
- `text/boo.png`

## Placeholder Assets

Until real assets are added, the app will use emoji-based placeholders defined in `sticker_categories.json`.

## Adding New Stickers

1. Place PNG files in appropriate category folder
2. Update `sticker_categories.json` if adding new categories
3. Restart app to reload assets

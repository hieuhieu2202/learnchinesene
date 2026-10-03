"""Check that both clients can resolve and decode their production artwork.

Run from any directory: python scripts/validate_game_assets.py
Requires Pillow: python -m pip install Pillow
"""
from pathlib import Path
import re
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets' / 'images'
paths = set()
for source in (ROOT / 'lib').rglob('*.dart'):
    paths.update(re.findall(r"assets/images/([a-z_/]+\.png)", source.read_text()))
for source in (ROOT / 'app/src/main/java').rglob('*.kt'):
    paths.update(re.findall(r'"((?:backgrounds|characters|foods|icons)/[a-z_]+\.png)"', source.read_text()))

for relative in sorted(paths):
    path = ASSETS / relative
    assert path.is_file(), f'Missing asset: {relative}'
    with Image.open(path) as image:
        image.load()
        assert image.format == 'PNG', f'Unexpected format: {relative}'
        assert min(image.size) >= 256, f'Placeholder resolution: {relative}'
        if relative.startswith(('characters/', 'foods/')):
            assert image.mode == 'RGBA', f'Missing alpha channel: {relative}'
            low, high = image.getchannel('A').getextrema()
            assert low == 0 and high > 200, f'Invalid transparency: {relative}'
        print(f'{relative}: {image.width}x{image.height} {image.mode}')

with Image.open(ASSETS / 'backgrounds/boss_battle_bg.png') as arena:
    assert arena.width > arena.height, 'Native arena must be landscape'
with Image.open(ASSETS / 'backgrounds/boss_battle_portrait_bg.png') as arena:
    assert arena.height > arena.width, 'Flutter fullscreen arena must be portrait'
assert len({(ASSETS / f'foods/{name}.png').read_bytes() for name in ('noodles','rice','dumplings')}) == 3, 'Food options must have distinct artwork'
print(f'PASS: {len(paths)} referenced production assets decode correctly.')

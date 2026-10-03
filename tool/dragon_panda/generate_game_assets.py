import os
import subprocess
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(description='Legacy placeholder generator. Never use for production artwork.')
parser.add_argument('--output-dir', required=True, help='Separate scratch folder outside the repository assets directory')
args = parser.parse_args()
output = Path(args.output_dir).resolve()
production = (Path(__file__).resolve().parents[1] / 'assets').resolve()
if output == production or production in output.parents or output in production.parents:
    parser.error('Output must be outside the production assets directory.')
output.mkdir(parents=True, exist_ok=True)
os.chdir(output)

def run_cmd(cmd):
    subprocess.run(cmd, shell=True, check=True)

os.makedirs('assets/images/backgrounds', exist_ok=True)
os.makedirs('assets/images/characters', exist_ok=True)
os.makedirs('assets/images/effects', exist_ok=True)
os.makedirs('assets/images/foods', exist_ok=True)
os.makedirs('assets/images/icons', exist_ok=True)

# 1. Backgrounds (720x1560)
bg_specs = {
    'home_bg.png': ('#3b82f6', '#ff7a00', '#f59e0b'),
    'game_hub_bg.png': ('#0f172a', '#1e3a8a', '#3b82f6'),
    'boss_intro_bg.png': ('#450a0a', '#b91c1c', '#f97316'),
    'boss_battle_bg.png': ('#2e0815', '#7a1c24', '#c2410c'),
    'victory_bg.png': ('#78350f', '#d97706', '#fef08a'),
    'defeat_bg.png': ('#180816', '#3b0728', '#581c87'),
    'radical_builder_bg.png': ('#042f2e', '#0f766e', '#5eead4'),
    'tone_ninja_bg.png': ('#090d16', '#1e1b4b', '#4338ca'),
    'restaurant_bg.png': ('#451a03', '#9a3412', '#ea580c'),
    'quick_answer_bg.png': ('#0f172a', '#312e81', '#7c3aed'),
}

for name, (c1, c2, c3) in bg_specs.items():
    out = os.path.join('assets/images/backgrounds', name)
    cmd = (
        f'convert -size 720x1560 gradient:"{c1}"-"{c2}" '
        f'-fill "{c3}" -draw "circle 520,380 520,240" '
        f'-fill "rgba(0,0,0,0.35)" -draw "polygon 0,1100 240,860 480,1020 720,780 720,1560 0,1560" '
        f'-fill "rgba(0,0,0,0.55)" -draw "polygon 0,1260 180,1120 360,1200 540,1080 720,1180 720,1560 0,1560" '
        f'"{out}"'
    )
    run_cmd(cmd)

# 2. Characters (512x512 Transparent PNG)
char_specs = {
    'panda_archer.png': ('#1d4ed8', '#f59e0b'),
    'dragon_fire.png': ('#dc2626', '#f59e0b'),
    'panda_chef.png': ('#ea580c', '#ffffff'),
    'panda_ninja.png': ('#1e1b4b', '#38bdf8'),
    'panda_avatar.png': ('#f59e0b', '#ffffff'),
    'panda_dizzy.png': ('#475569', '#cbd5e1'),
}

for name, (c1, c2) in char_specs.items():
    out = os.path.join('assets/images/characters', name)
    cmd = (
        f'convert -size 512x512 xc:none '
        f'-fill "{c1}" -draw "circle 256,256 256,80" '
        f'-fill "{c2}" -draw "circle 256,200 256,120" '
        f'"{out}"'
    )
    run_cmd(cmd)

# 3. Effects (256x256 Transparent PNG)
effects = [
    'arrow.png', 'arrow_trail.png', 'fire_core.png', 'fire_particle.png',
    'smoke.png', 'spark.png', 'hit_flash.png', 'coin.png'
]
for eff in effects:
    out = os.path.join('assets/images/effects', eff)
    cmd = (
        f'convert -size 256x256 xc:none '
        f'-fill "#f59e0b" -draw "circle 128,128 128,40" '
        f'"{out}"'
    )
    run_cmd(cmd)

# 4. Foods (256x256 Transparent PNG)
foods = ['noodles.png', 'rice.png', 'dumplings.png']
for name in foods:
    out = os.path.join('assets/images/foods', name)
    cmd = (
        f'convert -size 256x256 xc:none '
        f'-fill "#f97316" -draw "circle 128,128 128,30" '
        f'"{out}"'
    )
    run_cmd(cmd)

# 5. Icons (256x256 Rounded Icon Thumbs)
icons = [
    'boss_battle_thumb.png', 'radical_builder_thumb.png', 'tone_ninja_thumb.png',
    'restaurant_thumb.png', 'quick_answer_thumb.png'
]
for ic in icons:
    out = os.path.join('assets/images/icons', ic)
    cmd = (
        f'convert -size 256x256 xc:"#1e293b" '
        f'-fill "#f59e0b" -draw "circle 128,128 128,40" '
        f'"{out}"'
    )
    run_cmd(cmd)

print("ALL_GAME_ASSETS_GENERATED_SUCCESSFULLY")


develop: themes/dotfiles/assets/css/colors.css
	nix develop --command hugo server -D --bind 0.0.0.0

build:
	nix build .

MAKEFLAGS += --check-symlink-times
themes/dotfiles/assets/css/colors.css: flake.nix flake.lock
	nix build .#colors -o ./themes/dotfiles/assets/css/colors.css

new:
	@DATE=$(shell date +%Y-%m-%d); \
	SLUG=$(shell read -p "slug? " slug; echo $$slug); \
	hugo new "posts/$$DATE-$$SLUG"

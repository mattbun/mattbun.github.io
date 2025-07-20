develop: themes/dotfiles/assets/css/colors.css
	nix develop --command hugo server -D --bind 0.0.0.0

build:
	nix build .

themes/dotfiles/assets/css/colors.css: flake.nix flake.lock
	nix build .#colors
	cp result ./themes/dotfiles/assets/css/colors.css
	chmod 644 ./themes/dotfiles/assets/css/colors.css

new:
	@DATE=$(shell date +%Y-%m-%d); \
	SLUG=$(shell read -p "slug? " slug; echo $$slug); \
	hugo new "posts/$$DATE-$$SLUG"

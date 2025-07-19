develop:
	hugo server -D --bind 0.0.0.0

build:
	hugo

new:
	@DATE=$(shell date +%Y-%m-%d); \
	SLUG=$(shell read -p "slug? " slug; echo $$slug); \
	hugo new "posts/$$DATE-$$SLUG"

develop:
	hugo server -D

build:
	hugo

new:
	@DATE=$(shell date +%Y-%m-%d); \
	SLUG=$(shell read -p "slug? " slug; echo $$slug); \
	hugo new "posts/$$DATE-$$SLUG"

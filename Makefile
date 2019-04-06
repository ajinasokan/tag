
size:
	@find . -name "*.dart" | xargs cat | wc -c
	@echo "    5120"

client:
	flutter run -d ZX1B33CDZM

server:
	flutter run -d ZY223XZKGH

shellc:
	adb -s ZX1B33CDZM shell

shells:
	adb -s ZY223XZKGH shell	
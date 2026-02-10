INNO_VERSION=6.7.0

innoinstall:
	powershell -Command "Invoke-WebRequest -Uri 'https://github.com/jrsoftware/issrc/releases/download/is-6_7_0/innosetup-6.7.0.exe' -OutFile 'build\inno-installer.exe'"
	.uild\inno-installer.exe /verysilent /allusers /dir=build\iscc

inno:
	powershell .\build\iscc\iscc.exe .\windows-setup-script.iss
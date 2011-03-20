# Batch Builder for RAGen Installer
#
# Set Global Variables First
SET InstallerName=v104
SET RAGen=1.0.4.92
SET Dev=0.8.5.13

# Compile Installer
"C:\Program Files\NSIS\makensis" /DINSTALLER_NAME=%InstallerName% /DRAGEN_VERSION=%RAGen% /DDEV_LIB_VERSION=%Dev% /Obuildlog.txt /HDRINFO RAGenInstaller.nsi
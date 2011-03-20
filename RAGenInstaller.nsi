/*
RAGenInstaller - Installer for ReefAngel Generator
Copyright (C) 2011 Curt Binder

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

# Installer File
#
# 2 Components will be able to be installed
#   1. ReefAngel Generator
#   2. ReefAngel Dev Libraries
#
# ReefAngel Generator will have the option to be uninstalled.

!include "MUI2.nsh"

;------------------------------------------
; Command Line Arguments
;
; These must be defined on the command line when building this installer
; /DINSTALLER_NAME=
; /DRAGEN_VERSION=
; /DDEV_LIB_VERSION=

;------------------------------------------
; Define statements
# Possibly have these be an include file
# Consider in future having this read from a website XML file
# and have it be a network install
!define VERSION 					"1.0.0.0"
!ifdef STATIC
!define RAGEN_VERSION_DIR			"${INSTALLER_NAME}-static"
!else
!define RAGEN_VERSION_DIR			"${INSTALLER_NAME}"
!endif ; ifdef STATIC
!define RAGEN_REG_KEY				"Software\Curt Binder\RAGen"
!define RAGEN_UNINSTALL_KEY			"Software\Microsoft\Windows\CurrentVersion\Uninstall\RAGen"
!define DEV_LIB_KEY					"DevelopmentLibraries"

;------------------------------------------
; Global Variables
Var InstallLibDir
Var InstallLibDirBackup
Var AppName
Var AppExeName

;------------------------------------------
; Set some defaults
Name $AppName
OutFile "RAGen-${INSTALLER_NAME}_Installer.exe"
BrandingText "CurtBinder"
RequestExecutionLevel user
SetCompressor /SOLID lzma

;------------------------------------------
; Installation Types
InstType "Full"
InstType "RAGen Only"

;------------------------------------------
; Interface Configurations
!define MUI_ICON "images\BluePackageCD.ico"
!define MUI_UNICON "images\BluePackageUninstall.ico"
# size is 150x57
!define MUI_HEADERIMAGE_BITMAP "images\header.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "images\header.bmp"
# size is 164x314
!define MUI_WELCOMEFINISHPAGE_BITMAP "images\logo.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "images\logo.bmp"
!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "Are you sure you want to cancel the installation?"

;------------------------------------------
; Pages for installer, list in order
!define MUI_PAGE_HEADER_TEXT "$AppName Installer"
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of $AppName.$\n$\nIf you are upgrading it, it is recommended that you close out the program before you proceed.$\n$\nClick Next to continue."
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "license.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!define MUI_FINISHPAGE_NOAUTOCLOSE
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\$AppExeName"
!define MUI_FINISHPAGE_RUN_TEXT "Run $AppName"
!insertmacro MUI_PAGE_FINISH

# Pages for the uninstaller, list in order

;------------------------------------------
; Set languages to include
!insertmacro MUI_LANGUAGE "English"

;------------------------------------------
; Functions
Function .onInit
	StrCpy $InstallLibDir "$DOCUMENTS\Arduino\libraries\"
	StrCpy $InstallLibDirBackup "$DOCUMENTS\Arduino\libraries-backup\"
	StrCpy $AppName "ReefAngel Generator"
	StrCpy $AppExeName "RAGen.exe"
	StrCpy $INSTDIR "$PROGRAMFILES\$AppName\"
FunctionEnd

;------------------------------------------
; Installer Component Sections
Section "RAGen" SectionRAGen
	# Installs to Program Files\ReefAngel Generator
	# Order of install
	# 1. Install VC++ runtime libraries
	# 2. Create folder and copies files into it
	# 3. Set Registry key for RAGen to start in Development Mode
	SectionIn 1 2
	DetailPrint "Installing $AppName..."
	SetOutPath $INSTDIR
	SetOverwrite On
	File /r "..\RAGenVersions\RAGen-${RAGEN_VERSION_DIR}\*.*"
	File /r "..\RAGenVersions\CommonFiles\*.*"
	SetOverwrite Off
	;DetailPrint "Installing VC++ 2005 Redistributable files..."
	;ExecWait '"$INSTDIR\vcredist_x86.exe" /Q'
	;Delete $INSTDIR\vcredist_x86.exe
	WriteRegDWORD HKCU "${RAGEN_REG_KEY}" "${DEV_LIB_KEY}" 1
SectionEnd

SectionGroup /e "Libraries"
Section "Backup Existing" SectionBackup
	SectionIn 1
	DetailPrint "Backing up existing libraries..."
	Delete $InstallLibDirBackup
	Rename $InstallLibDir $InstallLibDirBackup
	CreateDirectory $InstallLibDir
SectionEnd
Section "Dev Libraries" SectionDevLibs
	# Installs to My Documents\Arduino\libraries
	# Order of the install
	# 1. Backup existing folder to libraries-backup, if present
	# 2. Create new folder
	SectionIn 1
	DetailPrint "Installing ReefAngel Development Libraries..."
	DetailPrint "Copying new libraries..."
	SetOutPath $InstallLibDir
	SetOverwrite On
	File /r /x *.gitignore /x TODO.txt "..\RADevLibs\v${DEV_LIB_VERSION}\*.*"
	File /r "..\RADevLibs\AdditionalLibraries\*.*"
	SetOverwrite Off
SectionEnd
SectionGroupEnd

SectionGroup /e "Shortcuts"
Section "Start Menu" SectionStartMenu
	# Installs a shortcut on the start menu
	SectionIn 1 2
	DetailPrint "Creating Start Menu shortcut..."
	CreateDirectory "$SMPROGRAMS\$AppName"
	CreateShortcut "$SMPROGRAMS\$AppName\$AppName.lnk" "$INSTDIR\$AppExeName"
SectionEnd

Section "Desktop" SectionDesktop
	# Installs a shortcut on the desktop
	SectionIn 1 2
	DetailPrint "Creating Desktop shortcut..."
	CreateShortcut "$DESKTOP\$AppName.lnk" "$INSTDIR\$AppExeName"
SectionEnd
SectionGroupEnd

;------------------------------------------
; Version Information for Installer
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "ReefAngel Generator Installer"
!ifdef STATIC
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Installation program for ReefAngel Generator (Static Build)"
VIAddVersionKey /LANG=${LANG_ENGLISH} "SpecialBuild" "Statically Linked MFC Libraries"
!else
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Installation program for ReefAngel Generator"
!endif  ; ifdef STATIC
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "(c) 2011 Curt Binder"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "ReefAngel Generator Installer Application"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "InternalName" "RAGen_Installer.exe"
VIAddVersionKey /LANG=${LANG_ENGLISH} "OriginalFilename" "RAGen_Installer.exe"
VIProductVersion "${VERSION}"

;------------------------------------------
; Set descriptions for Components page
LangString DESC_SectionRAGen ${LANG_ENGLISH} "ReefAngel Generator v${RAGEN_VERSION}"
LangString DESC_SectionDevLibs ${LANG_ENGLISH} "ReefAngel Development Libraries v${DEV_LIB_VERSION}"
LangString DESC_SectionStartMenu ${LANG_ENGLISH} "Installs a shorcut for ReefAngel Generator in the Start Menu"
LangString DESC_SectionDesktop ${LANG_ENGLISH} "Installs a shortcut for ReefAngel Generator on the Desktop"
LangString DESC_SectionBackup ${LANG_ENGLISH} "Backup existing libraries folder before installing Development Libraries"
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${SectionRAGen} $(DESC_SectionRAGen)
	!insertmacro MUI_DESCRIPTION_TEXT ${SectionDevLibs} $(DESC_SectionDevLibs)
	!insertmacro MUI_DESCRIPTION_TEXT ${SectionStartMenu} $(DESC_SectionStartMenu)
	!insertmacro MUI_DESCRIPTION_TEXT ${SectionDesktop} $(DESC_SectionDesktop)
	!insertmacro MUI_DESCRIPTION_TEXT ${SectionBackup} $(DESC_SectionBackup)
!insertmacro MUI_FUNCTION_DESCRIPTION_END


/*
Section "un.Dev Libraries"
	# If libraries-backup folder is present, attempt to uninstall
	# Order of the uninstall
	# 1. Delete folder
	# 2. Move libraries-backup to libraries
SectionEnd
*/

#Section "un.RAGen"
	# Uninstalls from Program Files\ReefAngel Generator
	# Order of uninstall
	# 1. Delete folder
	# 2. Delete Start Menu link
	# 3. Delete Desktop link
	# 4. Delete Registry Key
#SectionEnd


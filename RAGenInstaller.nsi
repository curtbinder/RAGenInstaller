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
!include "FileFunc.nsh"

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
!define CB_REG_KEY					"Software\Curt Binder\"
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
OutFile "RAGen-${INSTALLER_NAME} Installer.exe"
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
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;------------------------------------------
; Set languages to include
!insertmacro MUI_LANGUAGE "English"

;------------------------------------------
; Functions
!macro SetAppDefaultsMacro UN
Function ${UN}SetAppDefaults
	StrCpy $InstallLibDir "$DOCUMENTS\Arduino\libraries\"
	StrCpy $InstallLibDirBackup "$DOCUMENTS\Arduino\libraries-backup\"
	StrCpy $AppName "ReefAngel Generator"
	StrCpy $AppExeName "RAGen.exe"
FunctionEnd
!macroend
!insertmacro SetAppDefaultsMacro ""
!insertmacro SetAppDefaultsMacro "un."

Function .onInit
	Call SetAppDefaults
	StrCpy $INSTDIR "$PROGRAMFILES\$AppName\"
FunctionEnd

Function AddUninstallEntry
	WriteRegStr HKCU "${RAGEN_UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
	WriteRegStr HKCU "${RAGEN_UNINSTALL_KEY}" "DisplayName" "$AppName"
	WriteRegStr HKCU "${RAGEN_UNINSTALL_KEY}" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
	WriteRegStr HKCU "${RAGEN_UNINSTALL_KEY}" "Publisher" "Curt Binder"
	WriteRegStr HKCU "${RAGEN_UNINSTALL_KEY}" "RegOwner" "Curt Binder"
	WriteRegStr HKCU "${RAGEN_UNINSTALL_KEY}" "URLInfoAbout" "http://curtbinder.info/"
	WriteRegStr HKCU "${RAGEN_UNINSTALL_KEY}" "DisplayVersion" "${RAGEN_VERSION}"
	WriteRegStr HKCU "${RAGEN_UNINSTALL_KEY}" "Comments" "Generates settings and information for use with the ReefAngel controller."
	WriteRegDWORD HKCU "${RAGEN_UNINSTALL_KEY}" "NoModify" 1
	WriteRegDWORD HKCU "${RAGEN_UNINSTALL_KEY}" "NoRepair" 1
	${GetSize} "$INSTDIR" "/S=OK" $0 $1 $2
	IntFmt $0 "0x%08X" $0
	WriteRegDWORD HKCU "${RAGEN_UNINSTALL_KEY}" "EstimatedSize" "$0"
FunctionEnd

Function un.onInit
	Call un.SetAppDefaults
	# Get Registry Install Folder
	ReadRegStr $INSTDIR HKCU "${RAGEN_UNINSTALL_KEY}" "InstallLocation"
	${If} $INSTDIR == ""
		StrCpy $INSTDIR "$PROGRAMFILES\$AppName\"
	${EndIf}
FunctionEnd

;------------------------------------------
; Installer Component Sections
Section "RAGen" SectionRAGen
	# Installs to Program Files\ReefAngel Generator
	SectionIn 1 2
	DetailPrint "Installing $AppName..."
	SetOutPath $INSTDIR
	SetOverwrite on
	File /r "..\RAGenVersions\RAGen-${RAGEN_VERSION_DIR}\*.*"
	File /r "..\RAGenVersions\CommonFiles\*.*"
	SetOverwrite off
	;DetailPrint "Installing VC++ 2005 Redistributable files..."
	;ExecWait '"$INSTDIR\vcredist_x86.exe" /Q'
	;Delete $INSTDIR\vcredist_x86.exe

	# Write out uninstaller
	SetOverwrite on
	WriteUninstaller "$INSTDIR\Uninstall.exe"
	SetOverwrite off

	# Write Registry Settings
	WriteRegDWORD HKCU "${RAGEN_REG_KEY}" "${DEV_LIB_KEY}" 1
	WriteRegStr HKCU "${RAGEN_REG_KEY}" "InstallFolder" $INSTDIR
	
	# Add Add/Remove entry
	Call AddUninstallEntry
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
	SetOverwrite on
	File /r /x *.gitignore /x TODO.txt "..\RADevLibs\v${DEV_LIB_VERSION}\*.*"
	File /r "..\RADevLibs\AdditionalLibraries\*.*"
	SetOverwrite off
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


Section "Uninstall"
	# Uninstalls ReefAngel Generator
	IfFileExists $InstallLibDirBackup\*.* 0 delete_files
		DetailPrint "Deleting Dev Libraries and restoring original libraries..."
		RMDir /r $InstallLibDir
		Rename $InstallLibDirBackup $InstallLibDir
	
	delete_files:
	DetailPrint "Deleting ReefAngel Generator files..."
	Delete "$INSTDIR\Uninstall.exe"
	Delete "$INSTDIR\*.*"
	RMDir "$INSTDIR"

	# delete shortcuts
	DetailPrint "Deleting Start Menu Shortcut..."
	Delete "$SMPROGRAMS\$AppName\$AppName.lnk"
	RMDir /r "$SMPROGRAMS\$AppName"
	DetailPrint "Deleting Desktop Shortcut..."
	Delete "$DESKTOP\$AppName.lnk"
	
	# deletes registry keys
	DetailPrint "Deleting Registry keys..."
	DeleteRegKey HKCU "${RAGEN_REG_KEY}"
	DeleteRegKey HKCU "${CB_REG_KEY}"
	DeleteRegKey HKCU "${RAGEN_UNINSTALL_KEY}"
SectionEnd


; Copyright (c) 2024 Ross Demuth <rossdemuth123@gmail.com>
; license: Apache 2.0, see LICENSE for more details.

;---
; Generate a unicode installer, best set first
Unicode true

;---
; Plugins, required to compile: (included in data\nsis)
; -
; MUI2 (included in NSIS v3.0)
; UAC (included in NsisMultiUser)
; NsisMultiUser (https://github.com/Drizin/NsisMultiUser)
;---
!addplugindir /x86-unicode "nsis\Plugins\x86-unicode\"
!addincludedir "nsis\Include\"


;------------------------------
;  GENERAL

; Global
Name "FOP"
!define VERSION $%fop_ver%
!define SRC_DIR "fop-${VERSION}"
!define PRODUCT_NAME "FOP"
Outfile "${PRODUCT_NAME}-${VERSION}-setup.exe"
!define PROGEXE "fop\fop.bat"
!define LICENSE_FILE "LICENSE"

; Compression
SetCompressor /FINAL /SOLID lzma


;------------------------------
;  SETTINGS

; Multi User Settings (must come before the NsisMultiUser script)
!define MULTIUSER_INSTALLMODE_DEFAULT_ALLUSERS 1
!define MULTIUSER_INSTALLMODE_64_BIT 1

; Modern User Interface v2 Settings
!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
;!define MUI_FINISHPAGE_NOAUTOCLOSE  ;allows users to check install log before continuing
!define MUI_FINISHPAGE_RUN_TEXT "Start ${PRODUCT_NAME}"
!define MUI_FINISHPAGE_RUN_NOTCHECKED


;------------------------------
;  SCRIPTS

; NsisMultiUser - all settings need to be set before including the NsisMultiUser.nsh header file.
; thanks to Richard Drizin https://github.com/Drizin/NsisMultiUser
!include NsisMultiUser.nsh
!include UAC.nsh
!include MUI2.nsh


;------------------------------
;  PAGES

; Installer
!insertmacro MUI_PAGE_LICENSE "${LICENSE_FILE}"
!insertmacro MULTIUSER_PAGE_INSTALLMODE
; this will show the 2 install options, unless it's an elevated inner process
; (in that case we know we should install for all users)
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstaller
!insertmacro MULTIUSER_UNPAGE_INSTALLMODE
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES


;------------------------------
;  LANGUAGES

; MUIv2 macros (must be after scripts and pages)
!insertmacro MUI_LANGUAGE "English"
!insertmacro MULTIUSER_LANGUAGE_INIT


;------------------------------
;  INSTALLER SECTIONS

; Install Types
InstType "Base"

;----------------
; Main Section

Section "!FOP" SecMain

    SectionIN 1

    ; Install Files
    SetOutPath "$INSTDIR"
    SetOverwrite on
    File /a /r "${SRC_DIR}\*.*"

    ; Create uninstaller
    WriteUninstaller "$INSTDIR\${UNINSTALL_FILENAME}"

    ; add registry keys
    !insertmacro MULTIUSER_RegistryAddInstallInfo

SectionEnd


;------------------------------
;  UNINSTALLER SECTIONS
;
; All section names prefixed by "Un" will be in the uninstaller

; Settings
UninstallText "This will uninstall ${PRODUCT_NAME}."

; Main Uninstall Section

Section "Uninstall" SecUnMain
    ; Remove registry keys
    !insertmacro MULTIUSER_RegistryRemoveInstallInfo
    SetOutPath $TEMP
    RMDir /r "$INSTDIR"
SectionEnd


;------------------------------
;  CALLBACK FUNCTIONS

; On Initializing
Function .onInit
    ; Initialize the NsisMultiUser plugin
    !insertmacro MULTIUSER_INIT
FunctionEnd

; On Initializing the uninstaller
Function un.onInit
    ; Initialize the NsisMultiUser plugin
    !insertmacro MULTIUSER_UNINIT
FunctionEnd

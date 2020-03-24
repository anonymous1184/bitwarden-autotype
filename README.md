# Bitwarden Auto-Type
A simple script written in [AutoHotkey](https://www.autohotkey.com/) that provides up to 2 hotkeys for Auto-Type in Windows applications (_similar_ to [KeePass](https://keepass.info/help/base/autotype.html)).

## Instructions
- Download [Bitwarden CLI](https://github.com/bitwarden/cli) >= `1.9.0`
- Update accordingly the configuration.
- **Add** to your login entries:
  - An `winapp://` or `app://` URL\*.
  - **Optionally**, specify a custom typing sequence in the `Auto-Type Sequence` field (name can be changed in `[AUTOTYPE]` section of configuration).

\* Why `(win)app://`? both are [currently unused](https://github.com/bitwarden/jslib/blob/master/src/models/view/loginUriView.ts#L9). `winapp://` is consistent with `(ios|android)app://`. `app://` is OS agnostic (an Auto-Type for MacOS/Linux could make use of it). Protocols can be [iconified](https://github.com/bitwarden/jslib/blob/master/src/angular/components/icon.component.ts#L80) (`app://`, `macapp://`, `linuxapp://` and `winapp://`).

## Format
- By executable name:
  - `(win)app://thunderbird.exe` - matches by .exe name.
- By window title:
  - `(win)app://Mail Server Password Required` - matches by window title.
  - `(win)app://?title=Mail Server Password Required` - matches by window title.
- By window class:
  - `(win)app://?class=MozillaDialogClass` - matches by window class.

## What it does
- Provides Auto-Type based on the current window executable/title.
- Passwords skips clipboard manager (thus history and cloud syncronization).

## What it does NOT
- Replace Bitwarden application or browser extension.
- Provide in-memory protection mechanisms (_à la_ KeePass).

## OTP generation
TOTP (RFC-6238) generation is optional. Following the example in Bitwarden products, it is coppied to clipboard.
- Download [oathtool](https://download.multiotp.net/tools/oathtool_2.6.2_windows/) | [7z](https://mega.nz/#!jot1QbJa!cNHICLMI1LOSTtI6wbIoy0JatkcFHJ6p0VQIUTWcmoY) | [zip](https://mega.nz/#!zglDQD5Q!1S3H3MYvG1SD2sk0pShsGUCHJvHr4eivkpTBPF9JBWU).
- Update accordingly the configuration.

## Caveats
- UAC issues:
  - Run the Auto-Type executable/script elevated.
- UIPI issues:
  - Use Auto-Type as script with AutoHotkey istalled and UIA enabled. **_OR_**
  - Create/import a certificate, sign the executable and place it accordingly.
- Login/unlock/sync feels sluggish. One or more of:
  - Slow CPU.
  - Big vault.
  - Number of iterations of Key Derivation.

## TODO
- Less fatal errors.
- Rewrite as Class for integration.
- ~~TOTP (3rd party tool or write [RFC-6238](https://tools.ietf.org/html/rfc6238) compilant).~~ ✔

## Out of Scope
- x86 version: bw.exe is 64bit.
- Any kind of GUI: it's a script.
- Fine-grained URL-based in-browser auto-typing: extension's job.

## Remember
- This is a script, not a full-fledged enterprise-ready application (_i.e._ YMMV).
- No monkey business. Since is AutoHotkey, the source in the .exe can be read with Notepad (almost at the end of the file), or with [Resource Hacker](http://angusj.com/resourcehacker/) (plus, you can always use the bare script).

## Help
- [Forums](https://community.bitwarden.com/) are a good starting point.
- GitHub issues for code-specific stuff.

## Thanks to
- **Kyle Spearring** for his incredible dedication to Bitwarden and its community.
- **Chris Mallett** and **Steve Gray** for AutoHotkey that had helped me to automate Windows stuff for over 10 years.

## Licence
- [WTFPL](http://www.wtfpl.net/about/)

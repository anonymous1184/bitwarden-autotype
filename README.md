# ![icon](assets/icon.png) Bitwarden Auto-Type

A script-based, small (~1mb), Open Source Application written in [AutoHotkey][01] that provides keyboard shortcuts to auto-type usernames, passwords and Time-based One-Time Passwords\* ([TOTP][02]) for applications ***and*** websites, it borrows the concepts coined by [KeePass][03] but with [Bitwarden][04] as "backend".

It does NOT replace Bitwarden application as entries can't be added/edited. They can run side-by-side but is not required.

<sup>_\* Even for the free version, but please support bitwarden development by buying a Premium subscription._</sup>

## Security

Some people feel uneasy to trust their passwords to 3rd parties, and of course that's the way it should be. Why trust this small application? Because its 100% transparent. Bitwarden itself is the same, relies on being completely transparent and Open Source.

While Open Source is not a silver bullet, allows anyone to audit the code. Granted, not everyone is able to do so but at least the code is here hopefully gaining enough traction to fall into the hands of capable reviewers.

Here are some highlights for the more suspicious/paranoid:

- `bw.exe` is not bundled, is retrieved from the official distribution.
- No telemetry information or usage statics of any kind are ever generated.
- There's no "dial home" as there is no home, only this public code repository.
- When installed the approximate size is about 57mb, above 98% of the size is Bitwarden's own CLI.
- The **optional** favicon retrieval, grabs a single icon from the sites (same as Bitwarden).
- The **optional** update check is done by retrieving a small file in the repository ([this][i1] file).
- Auto-type works fine if offline, blocked via firewall or with the previous options disabled.
- The source code is embedded in the executable, can be read with any text editor (better yet, with [Resource Hacker][11]).
- A build script is available in the repo if the pre-built binaries are not trusted (only a double click is needed).
- The source code can be used as a script, thus avoiding the creation of any binary by just using AutoHotkey if installed.

Please note that even if the auto-type application does not need any network connectivity, `bw.exe` does for logging and synchronization of the vault.

## Top-10 Forum Requests

The application attempts to fullfil the applicable Top-10 user requested features of the community:

- [Auto-type/Autofill for logging into other desktop apps][req01].
- [2FA when ‘unlocking’][req02]<sup>1</sup>.
- [Auto-logout after X minutes][req03].
- [Auto-fill TOTP code][req04].
- [Bitwarden Windows App - Add Autorun at System Startup][req05].
- [Auto-Sync on all platforms][req07]<sup>2</sup>.
- [Support Internet Explorer][req07]<sup>3</sup>.
- [Autofill shortcut should open login window when vault is locked][req08]
- [Improve random password generation][req09].
  - [Password Generator Should Have More Character Set][req10].

<sup>1</sup> Generates an independent Authenticator Key.\
<sup>2</sup> The synchronization is done on schedule.\
<sup>3</sup> IE 11 was tested, older versions might need to use title matching.

## Features at Glance

~~[Wiki][05]~~ details them:

- Auto-Type: with predefined and per-case sequences.
- Supports multiple accounts and window definitions per site.
- Favicons can be shown to easily distinct between sites.
- Quick custom PIN and Authenticator codes for unlocking.
- Universal Window Platform support (Microsoft Store Apps).
- Browser support: instead of insecure extensions.
- All the major browsers (plus Internet Explorer) are supported.
- TOTP generation: via Clipboard and/or hotkey and/or placeholder.
- Strong Password Generator with entropy indicator.
- Placeholder for smart detection of text input fields.
- [Two-Channel Auto-Type Obfuscation][06]: global/per-entry.

## Instructions

Installer:

- Run the setup (application can be found in the Start Menu).

Portable:

- Place [Bitwarden CLI][08] (at least version `1.11`) in the same directory.

Both:

- Update the settings accordingly.

Optional:

- Add in Bitwarden login entries "window rules" (see format below).
- Specify custom typing sequence in the `auto-type` sequence field (name can be changed in `[ADVANCED]` section of settings file).

## Format

- By URL:
  - `http://example.com`
  - `https://www.example.com/path/login.html?foo=bar`
  - It follows the "_Match Detection_" in use by Bitwarden.
- By executable name:
  - `thunderbird.exe`
  - `app://thunderbird.exe`
  - `winapp://thunderbird.exe`
- By window title (partial match):
  - `Mail Server Password`
  - `app://Mail Server Password`
  - `winapp://Mail Server Password`
- By window title (exact match):
  - `app://?title=Mail Server Password Required`
  - `winapp://?title=Mail Server Password Required`
- By window class:
  - `app://?class=MozillaDialogClass`
  - `winapp://?class=MozillaDialogClass`

Why `winapp://` or `app://`? Both are [currently unused][09]. `winapp://` is consistent with `androidapp://` and `iosapp://` which are in use. `app://` is OS agnostic (an Auto-Type for MacOS/Linux could make use of it). Protocols can be [iconified][10] (for example: `app://`, `macapp://`, `linuxapp://` and `winapp://`).

## Known limitations

- No x86 version: `bw.exe` is 64 bits only.
- TCATO can fail in specific sites/windows.
  - Temporarily disable it via tray menu.
  - Add an exception in Bitwarden Vault (field `tcato`, value `off`).
- Some applications ***might*** fail to recognize auto-type:
  - Use the installer version (recommended).
  - Run the portable version as Administrator.
- `{SmartTab}` doesn't work with Chromium-based applications.
  - Normal <kbd>Tab</kbd> is sent. For more than one <kbd>Tab</kbd> use a custom `auto-type` rule.

## TODO

- [ ] Wiki !!!
- [x] UI for settings.
- [ ] Global entry selection.

## Help

- ~~Checkout the [Wiki][05]~~.
- In Reddit look for the [/r/Bitwarden][12] sub.
- User-to-User support in Community [Forums][13].
- GitHub [Issues][14] for app-specific problems/bugs.

## Licence

[WTFPL][15]

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

[01]: https://autohotkey.com/ "AutoHotkey"
[02]: https://en.wikipedia.org/wiki/Time-based_One-time_Password_algorithm "TOTP: Time-based One-Time Password"
[03]: https://keepass.info/help/base/autotype.html "KeePass Auto-type"
[04]: https://bitwarden.com "Bitwarden"
[05]: https://github.com/anonymous1184/bitwarden-autotype/wiki "Wiki not written yet"
[06]: https://keepass.info/help/v2/autotype_obfuscation.html "TCATO: Two-Channel Auto-Type Obfuscation"

[08]: https://github.com/bitwarden/cli "Bitwarden CLI"
[09]: https://github.com/bitwarden/jslib/blob/master/src/models/view/loginUriView.ts#L9 "loginUriView.ts:9"
[10]: https://github.com/bitwarden/jslib/blob/master/src/angular/components/icon.component.ts#L80 "icon.component.ts:6"
[11]: http://angusj.com/resourcehacker/ "Resource Hacker"
[12]: https://www.reddit.com/r/Bitwarden/ "Bitwarden Subreddit"
[13]: https://community.bitwarden.com/c/support/6 "Community Forums: User-to-User Support"
[14]: https://github.com/anonymous1184/bitwarden-autotype/issues "Issues"
[15]: http://www.wtfpl.net/about/ "Do What The Fuck You Want To Public License"

[i1]: /version

[req01]: https://community.bitwarden.com/t/158
[req02]: https://community.bitwarden.com/t/353
[req03]: https://community.bitwarden.com/t/30
[req04]: https://community.bitwarden.com/t/326
[req05]: https://community.bitwarden.com/t/948
[req06]: https://community.bitwarden.com/t/355
[req07]: https://community.bitwarden.com/t/4431
[req08]: https://community.bitwarden.com/t/1494
[req09]: https://community.bitwarden.com/t/4091
[req10]: https://community.bitwarden.com/t/82

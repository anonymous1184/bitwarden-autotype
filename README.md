# Bitwarden Auto-Type

A script-based, small, Open-Source Application written in [AutoHotkey][01] that provides keyboard shortcuts to auto-type usernames, passwords and Time-based One-Time Passwords ([TOTP][02]) for applications ***and*** websites, it borrows the concepts coined by [KeePass][03] but with [Bitwarden][04] as "backend".

*This is the second release (a major rewrite), is not backwards compatible with the first release. It contains multiple improvements and doesn't require external dependencies.*

It attempts to fullfil the applicable Top-10 user-requested features of the community:

* [Auto-type/Autofill for logging into other desktop apps][req01].
* [2FA when ‘unlocking’][req02]<sup>1</sup>.
* [Auto-logout after X minutes][req03].
* [Auto-fill TOTP code][req04].
* [Bitwarden Windows App - Add Autorun at System Startup][req05].
* [Auto-Sync on all platforms][req07]<sup>2</sup>.
* [Support Internet Explorer][req07]<sup>3</sup>.
* [Autofill shortcut should open login window when vault is locked][req08]
* [Improve random password generation][req09].
  * [Password Generator Should Have More Character Set][req10].

<sup>1</sup> Uses [an entry][07] with the Authenticator Key.<br>
<sup>2</sup> The synchronization is done on schedule.<br>
<sup>3</sup> Only IE 11 was tested, use title matching for others.

## Features at glance

~~[Wiki][05]~~ details them:

* Auto-Type: with predefined and per-case sequences.
* Supports multiple accounts/windows per site.
* Favicons can be shown to easily distinct between sites.
* Quick 6-digit PIN and 2FA (TOTP) unlocking.
* Universal Window Platform support (Microsoft Store Apps).
* Browser support: instead of insecure extensions.
* TOTP generation: via Clipboard and/or hotkey and/or placeholder.
* Strong Password Generator with entropy indicator.
* Placeholder for smart detection of text input fields.
* [Two-Channel Auto-Type Obfuscation][06]: global/per-entry.

## What it does?

* Provides auto-type globally by executable/title/URL.
* Replaces the (intrinsically insecure) browser extension.
* It can use KeePass' TCATO algorithm for extra security.
* Passwords skip Clipboard (thus managers and cloud synchronization).

## What it does NOT

* Replace Bitwarden application (entries can't be added/edited).

## Instructions

Setup:

* Run the setup, edit the settings.
* Application can be found in the Start Menu.

Portable:

* Place [Bitwarden CLI][08] (at least `v1.11.0`) in the same directory.
* Update the settings (add the path to `bw.exe` if not in the same directory or if renamed).

Both:

* Add in Bitwarden login entries, *window rules* (see format below).
* **Optionally**, you can specify a custom typing sequence in the `auto-type` sequence field (name can be changed in `[SEQUENCES]` section of settings file).

## Format

* By URL:
  * `http://example.com`
  * `https://www.example.com/path/login.html?foo=bar`
  * It follows the "*Match Detection*" in use by Bitwarden.
* By executable name:
  * `thunderbird.exe`
  * `app://thunderbird.exe`
  * `winapp://thunderbird.exe`
* By window class:
  * `app://?class=MozillaDialogClass`
  * `winapp://?class=MozillaDialogClass`
* By window title (partial match):
  * `Mail Server Password`
  * `app://Mail Server Password`
  * `winapp://Mail Server Password`
* By window title (exact match):
  * `app://?title=Mail Server Password Required`
  * `winapp://?title=Mail Server Password Required`

Why `winapp://` or `app://`? Both are [currently unused][09]. `winapp://` is consistent with `androidapp://` and `iosapp://` currently used. `app://` is OS agnostic (an Auto-Type for MacOS/Linux could make use of it). Protocols can be [iconified][10] (for example: `app://`, `macapp://`, `linuxapp://` and `winapp://`).

## Known limitations

* No x86 version: `bw.exe` is 64 bits only.
* TCATO can fail in specific sites/windows
  * Temporarily disable it via tray menu
  * Add an exception in Bitwarden (field `tcato`, value `off`).
* Some applications ***might*** fail to recognize auto-type:
  * Use the setup version (recommended).
  * Run the portable version as Administrator.
* `{SmartTab}` doesn't work with Chromium-based applications
  * Normal <kbd>Tab</kbd> is sent. For more than one <kbd>Tab</kbd> use a custom `auto-type` rule.

## TODO

* Wiki !!!
* Internationalization.
* Global entry selection.
* UI for settings (perhaps).

## Help

* Checkout the ~~[Wiki][05]~~.
* In Reddit look for the [/r/Bitwarden][12] sub.
* User-to-User support in Community [Forums][13].
* GitHub [Issues][14] for app-specific problems/bugs.

## Disclaimer

This is a script-based utility; not a full-fledged, enterprise-ready application (_i.e._ YMMV).

**No monkey business**. Given the nature of AutoHotkey, the source code can be found on the executable and be read with any text editor (almost at the end of the file) or better yet, with [Resource Hacker][11]; plus, the source script can always be used instead.

## Licence

* [WTFPL][15]
* THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

[01]: https://autohotkey.com/ "AutoHotkey"
[02]: https://en.wikipedia.org/wiki/Time-based_One-time_Password_algorithm "TOTP: Time-based One-Time Password"
[03]: https://keepass.info/help/base/autotype.html "KeePass Auto-type"
[04]: https://bitwarden.com "Bitwarden"
[05]: https://github.com/anonymous1184/bitwarden-autotype/wiki "Wiki not written yet"
[06]: https://keepass.info/help/v2/autotype_obfuscation.html "TCATO: Two-Channel Auto-Type Obfuscation"
[07]: https://i.imgur.com/Qwv9oKQ.png "Entry with Authenticator Key"
[08]: https://github.com/bitwarden/cli "Bitwarden CLI"
[09]: https://github.com/bitwarden/jslib/blob/master/src/models/view/loginUriView.ts#L9 "loginUriView.ts:9"
[10]: https://github.com/bitwarden/jslib/blob/master/src/angular/components/icon.component.ts#L80 "icon.component.ts:6"
[11]: http://angusj.com/resourcehacker/ "Resource Hacker"
[12]: https://www.reddit.com/r/Bitwarden/ "Bitwarden Subreddit"
[13]: https://community.bitwarden.com/c/support/6 "Community Forums: User-to-User Support"
[14]: https://github.com/anonymous1184/bitwarden-autotype/issues "Issues"
[15]: http://www.wtfpl.net/about/ "Do What The Fuck You Want To Public License"

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

# Copy and Paste under Linux using xclip or xsel

## ClipBoards

xclip can control 4 different "clipboard"(see from xclip -h)

	-selection   selection to access ("primary", "secondary", "clipboard" or "buffer-cut")

- -sel pri ==> -selection primary
- -sel cli ==> -selection clipboard
- -sel buf ==> -selection buffer-cut

xsel comparable

-  -p, --primary         Operate on the PRIMARY selection (default)
-  -s, --secondary       Operate on the SECONDARY selection
-  -b, --clipboard       Operate on the CLIPBOARD selection

## How to use it

Default copy content into primary

	uptime | xclip
	xclip /etc/fstab

	uptime | xsel
	cat /etc/fstab | xsel

Paste from primary(keybind alt+p, config in st terminal)

	xclip -o -sel pri

	xsel

## fcitx(using clipboard first, and the primary)

- fcitx will store the clipboard content in the 1 row (Alt+v)
- fcitx will store the primary content in the 2 row (Alt+p)
- vim visual select (shift+v) will copy the context into primary(the 2nd row)

## Default shortcut

st terminal keybind

	Alt+v Paste from clipboard
	Alt+p Paste from primary

Paste content from clipboard(xclip -o -sel cli)

	Shift+Insert
	Mouse Middle Click
